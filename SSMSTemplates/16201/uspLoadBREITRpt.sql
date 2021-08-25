USE [RCS_SqlDw]
GO
CREATE PROCEDURE [hospitality_DW].[uspLoadBREITRpt] AS
BEGIN

--------------------------------
/* Create frist temp table with pivoted aggregated values from Workday (from select list for BREIT reporting) */
--------------------------------
	DECLARE @ErrorMessage [VARCHAR](MAX) = ERROR_MESSAGE()
	DECLARE @ErrorSeverity [INT] = ERROR_SEVERITY()
	DECLARE @ErrorState [INT] = ERROR_STATE()
	
	PRINT('-- Building First Temp Table')

	IF OBJECT_ID('tempdb..#temp_rcs_dw_pivot') IS NOT NULL
	BEGIN
		DROP TABLE #temp_rcs_dw_pivot
	END

	CREATE TABLE #temp_rcs_dw_pivot

	WITH
	(
		DISTRIBUTION = ROUND_ROBIN 
	,HEAP
	)
	AS 
	SELECT 
			PropertyId_AK
			,PropertyName
			,FiscalYear
			,FiscalMonth
			,RANK() OVER(PARTITION BY PropertyId_AK ORDER BY FiscalYear DESC, FiscalMonth DESC) AS YearMonthRank
			,[Full Rooms Inventory]AS WorkdayAvailableRooms
			,[Total Rooms Sold]AS WorkdayOccupiedRooms
			,[Total Room Revenue]AS WorkdayRoomRevenue
			,[Group Rooms Sold]AS WorkdayGroupPaidOccupiedRooms
			,[Retail Rooms Sold]AS WorkdayRetailPaidOccupiedRooms
			,[Negotiated Rooms Sold]AS WorkdayNegotiatedPaidOccupiedRooms
			,[Permanent Rooms Sold]AS WorkdayLeasePaidOccupiedRooms
			,[Other Rooms Sold] AS WorkdayOtherPaidOccupiedRooms
			,[Total Occupied Rooms] AS WorkdayTotalOccupiedRooms
			,CASE
				WHEN [Full Rooms Inventory] > 0 THEN ([Total Rooms Sold] / [Full Rooms Inventory])
			END AS WorkdayOccupancy
			,CASE
				WHEN [Total Rooms Sold] > 0 THEN ([Total Room Revenue] / [Total Rooms Sold])
			END AS WorkdayADR
			,CASE
				WHEN [Full Rooms Inventory] > 0 THEN ([Total Room Revenue] / [Full Rooms Inventory])
			END AS WorkdayRevPAR

		FROM (
			SELECT
				pd.PropertyId_AK
				,pd.PropertyName
				,mbaf.FiscalYear
				,mbaf.FiscalMonth
				,TRIM(rlbgm.ReportLineItem) AS ReportLineItem
				,mbaf.PeriodAmount
			FROM [hospitality_DW].[PROPERTY_DIM] pd
			JOIN [RCS_DW].[v_Company_Dim] cd
				ON cd.PropertyId_AK = pd.PropertyId_AK
				AND pd.IsCurrent = 1
				AND pd.PropertyStatus = 'Active'
			JOIN [RCS_DW].[v_GL_Monthly_Balance_Activity_Fact] mbaf
				ON mbaf.company_SK = cd.company_SK
			JOIN [RCS_DW].[v_ReportLineBaseGroupMapping] rlbgm
				ON rlbgm.ReportLineGroupId = mbaf.ReportLineGroupId
				AND TRIM(rlbgm.ReportLineItem) IN(
					'Full Rooms Inventory'
					,'Total Rooms Sold'
					,'Total Room Revenue'
					,'Group Rooms Sold'
					,'Retail Rooms Sold'
					,'Negotiated Rooms Sold'
					,'Permanent Rooms Sold'
					,'Other Rooms Sold'
					,'Total Occupied Rooms'
					) -- list of report line items
			JOIN [RCS_DW].[v_BookHierarchy_Dim] bhd
				ON mbaf.BookCode_SK = bhd.BookCode_SK
				AND bhd.BookCodeParent = 'AM Reporting' -- only care about asset management reporting
			JOIN [RCS_DW].[v_Scenario_Dim] sd1 -- actuals
				ON mbaf.scenario_SK = sd1.scenario_SK
				AND sd1.ScenarioDesc = 'Actuals'
			) rcs_dw
			PIVOT  
			(  
			SUM(PeriodAmount)  
			FOR ReportLineItem IN(
					[Full Rooms Inventory]
					,[Total Rooms Sold]
					,[Total Room Revenue]
					,[Group Rooms Sold]
					,[Retail Rooms Sold]
					,[Negotiated Rooms Sold]
					,[Permanent Rooms Sold]
					,[Other Rooms Sold]
					,[Total Occupied Rooms]
				) 
			) AS ReportLinePivot

	--------------------------------
	/* Create second temp table with "last three months" aggregated values from Workday */
	--------------------------------

	PRINT('-- Building Second Temp Table')

	IF OBJECT_ID('tempdb..#temp_rcs_dw') IS NOT NULL
	BEGIN
		DROP TABLE #temp_rcs_dw
	END

	CREATE TABLE #temp_rcs_dw

	WITH
	(
		DISTRIBUTION = ROUND_ROBIN 
	,HEAP
	)
	AS
	SELECT
		t1.PropertyId_AK
		,t1.PropertyName
		,t1.Fiscalyear
		,t1.FiscalMonth		
		,t1.WorkdayAvailableRooms
		,t1.WorkdayOccupiedRooms
		,t1.WorkdayRoomRevenue
		,t1.WorkdayGroupPaidOccupiedRooms
		,t1.WorkdayRetailPaidOccupiedRooms
		,t1.WorkdayNegotiatedPaidOccupiedRooms
		,t1.WorkdayLeasePaidOccupiedRooms
		,t1.WorkdayOtherPaidOccupiedRooms
		,t1.WorkdayTotalOccupiedRooms
		,t1.WorkdayOccupancy
		,SUM(t2.WorkdayAvailableRooms) L3M_WorkdayAvailableRooms
		,SUM(t2.WorkdayOccupiedRooms) AS L3M_WorkdayRoomsSold
		,SUM(t2.WorkdayRoomRevenue) AS L3M_WorkdayRoomRevenue
	FROM #temp_rcs_dw_pivot t1
	-- joining pivotted table on itself to pull the last	three month values for each period
	JOIN #temp_rcs_dw_pivot t2 
		ON t1.PropertyId_AK = t2.PropertyId_AK
		AND t2.YearMonthRank BETWEEN t1.YearMonthRank AND t1.YearMonthRank + 2
	GROUP BY 
		t1.PropertyId_AK
		,t1.PropertyName
		,t1.Fiscalyear
		,t1.FiscalMonth		
		,t1.WorkdayAvailableRooms
		,t1.WorkdayOccupiedRooms
		,t1.WorkdayRoomRevenue
		,t1.WorkdayGroupPaidOccupiedRooms
		,t1.WorkdayRetailPaidOccupiedRooms
		,t1.WorkdayNegotiatedPaidOccupiedRooms
		,t1.WorkdayLeasePaidOccupiedRooms
		,t1.WorkdayOtherPaidOccupiedRooms
		,t1.WorkdayTotalOccupiedRooms
		,t1.WorkdayOccupancy

	-----------------------------
	/* INSERT INTO BREIT RPT table, combining Workday and STR data */
	-----------------------------

	BEGIN TRY

		BEGIN TRANSACTION;  

			PRINT('=== TRUNCATE BREIT_RPT table')
			DELETE FROM [hospitality_DW].[BREIT_RPT];

			PRINT('=== INSERT INTO BREIT_RPT table')
			INSERT INTO [hospitality_DW].[BREIT_RPT] (
				[PropertyName]
				,[PropertyId_AK]
				,[STRID]
				,[AssetManager]
				,[Market]
				,[Region]
				,[Affiliation]
				,[ManagementCompany]
				,[WeeklyComparableStatus]
				,[MonthlyComparableStatus]
				,[Fund]
				,[Portfolio]
				,[Investment]
				,[RoomRange]
				,[NumberOfKeys]
				,[AssetCategory]
				,[AssetClass]
				,[Flag]
				,[Brand]
				,[Scale]
				,[MSA]
				,[LocationCategory]
				,[PropertyStatus]
				,[AddressLine1]
				,[AddressLine2]
				,[AddressLine3]
				,[AddressLine4]
				,[City]
				,[State]
				,[PostalCode]
				,[AssetID]
				,[InnCode]
				,[Region2]
				,[ConsolidatedStatus]
				,[YearMonth]
				,[Year]
				,[Month]
				,[Quarter]
				,[STR_Monthly_AvailableRooms]
				,[STR_Monthly_RoomsSold]
				,[STR_Monthly_RoomRevenue]
				,[STR_Monthly_GroupPaidOccupiedRooms]
				,[STR_L3M_AvailableRooms]
				,[STR_L3M_RoomsSold]
				,[STR_L3M_RoomRevenue]
				,[STR_L3M_GroupPaidOccupiedRooms]
				,[STR_Monthly_CompSetAvailableRooms]
				,[STR_Monthly_CompSetRoomsSold]
				,[STR_Monthly_CompSetRoomRevenue]
				,[STR_Monthly_Occupancy]
				,[STR_Monthly_Occupancy_Index]
				,[STR_Monthly_ADR]
				,[STR_Monthly_ADR_Index]
				,[STR_Monthly_RevPAR]
				,[STR_Monthly_RevPAR_Index]
				,[STR_Monthly_Transient_Room_Revenue]
				,[STR_Monthly_Transient_Rooms_Sold]
				,[STR_Monthly_Contract_Room_Revenue]
				,[STR_Monthly_Contract_Rooms_Sold]
				,[STR_Monthly_Group_Room_Revenue]
				,[STR_Monthly_Group_Rooms_Sold]
				,[STR_L3M_Monthly_CompSetAvailableRooms]
				,[STR_L3M_Monthly_CompSetRoomsSold]
				,[STR_L3M_Monthly_CompSetRoomRevenue]
				,[STR_L3M_Monthly_Occupancy]
				,[STR_L3M_Monthly_Occupancy_Index]
				,[STR_L3M_Monthly_ADR]
				,[STR_L3M_Monthly_ADR_Index]
				,[STR_L3M_Monthly_RevPAR]
				,[STR_L3M_Monthly_RevPAR_Index]
				,[STR_L3M_Monthly_Transient_Room_Revenue]
				,[STR_L3M_Monthly_Transient_Rooms_Sold]
				,[STR_L3M_Monthly_Contract_Room_Revenue]
				,[STR_L3M_Monthly_Contract_Rooms_Sold]
				,[STR_L3M_Monthly_Group_Room_Revenue]
				,[STR_L3M_Monthly_Group_Rooms_Sold]
				,[WorkdayAvailableRooms]
				,[WorkdayOccupiedRooms]
				,[WorkdayRoomRevenue]
				,[WorkdayGroupPaidOccupiedRooms]
				,[WorkdayRetailPaidOccupiedRooms]
				,[WorkdayNegotiatedPaidOccupiedRooms]
				,[WorkdayLeasePaidOccupiedRooms]
				,[WorkdayOtherPaidOccupiedRooms]
				,[WorkdayTotalOccupiedRooms]
				,[WorkdayOccupancy]
				,[L3M_WorkdayAvailableRooms]
				,[L3M_WorkdayRoomsSold]
				,[L3M_WorkdayRoomRevenue]
				,[L3M_WorkdayOccupancy]
				,[L3M_WorkdayADR]
				,[L3M_WorkdayRevPAR]
			)
			SELECT 
				pd.PropertyName
				,pd.PropertyId_AK
				,pd.STRID
				,pd.AssetManager
				,pd.Market
				,pd.Region
				,pd.Affiliation
				,pd.ManagementCompany
				,pd.WeeklyComparableStatus
				,pd.MonthlyComparableStatus
				,pd.Fund
				,pd.Portfolio
				,pd.Investment
				,pd.RoomRange
				,pd.NumberOfKeys
				,pd.AssetCategory
				,pd.AssetClass
				,pd.Flag
				,pd.Brand
				,pd.Scale
				,pd.MSA
				,pd.LocationCategory
				,pd.PropertyStatus
				,pd.AddressLine1
				,pd.AddressLine2
				,pd.AddressLine3
				,pd.AddressLine4
				,pd.City
				,pd.State
				,pd.PostalCode
				,pd.AssetID
				,pd.InnCode
				,pd.Region2
				,pd.ConsolidatedStatus
				,ymd.YearMonth
				,ymd.Year
				,ymd.Month
				,ymd.Quarter
				,amf.[DataPropertyAvailableRoom] AS STR_Monthly_AvailableRooms
				,amf.[DataPropertyRoomsSold] AS STR_Monthly_RoomsSold
				,amf.[DataPropertyTotalRoomRevenue] AS STR_Monthly_RoomRevenue
				,amf.[DataPropertyGroupRoomSold] AS STR_Monthly_GroupPaidOccupiedRooms
				,al3mf.[DataPropertyAvailableRoom] AS STR_L3M_AvailableRooms
				,al3mf.[DataPropertyRoomsSold] AS STR_L3M_RoomsSold
				,al3mf.[DataPropertyTotalRoomRevenue] AS STR_L3M_RoomRevenue
				,al3mf.[DataPropertyGroupRoomSold] AS STR_L3M_GroupPaidOccupiedRooms
				,amf.[CompSetAvailableRoom] AS STR_Monthly_CompSetAvailableRooms
				,amf.[CompSetRoomsSold] AS STR_Monthly_CompSetRoomsSold
				,amf.[CompSetTotalRoomRevenue] AS STR_Monthly_CompSetRoomRevenue
				,amf.[DataPropertyOccupancy] / 100 AS STR_Monthly_Occupancy
				,amf.[CompSetOccupancyIndex] / 100 AS STR_Monthly_Occupancy_Index
				,amf.[DataPropertyAverageDailyRate] AS STR_Monthly_ADR
				,amf.[CompSetAverageDailyRateIndex] / 100 AS STR_Monthly_ADR_Index
				,amf.[DataPropertyRevenuePerAvailableRoom] AS STR_Monthly_RevPAR
				,amf.[CompSetRevenuePerAvailableRoomIndex] / 100 AS STR_Monthly_RevPAR_Index
				,amf.[DataPropertyTransientRoomRevenue] AS STR_Monthly_Transient_Room_Revenue
				,amf.[DataPropertyTransientRoomSold] AS STR_Monthly_Transient_Rooms_Sold
				,amf.[DataPropertyContractRoomRevenue] AS STR_Monthly_Contract_Room_Revenue
				,amf.[DataPropertyContractRoomsSold] AS STR_Monthly_Contract_Rooms_Sold
				,amf.[DataPropertyGroupRoomRevenue] AS STR_Monthly_Group_Room_Revenue
				,amf.[DataPropertyGroupRoomSold] AS STR_Monthly_Group_Rooms_Sold
				,al3mf.[CompSetAvailableRoom] AS STR_L3M_Monthly_CompSetAvailableRooms
				,al3mf.[CompSetRoomsSold] AS STR_L3M_Monthly_CompSetRoomsSold
				,al3mf.[CompSetTotalRoomRevenue] AS STR_L3M_Monthly_CompSetRoomRevenue
				,al3mf.[DataPropertyOccupancy] / 100 AS STR_L3M_Monthly_Occupancy
				,al3mf.[CompSetOccupancyIndex] / 100 AS STR_L3M_Monthly_Occupancy_Index 
				,al3mf.[DataPropertyAverageDailyRate] AS STR_L3M_Monthly_ADR
				,al3mf.[CompSetAverageDailyRateIndex] / 100 AS STR_L3M_Monthly_ADR_Index
				,al3mf.[DataPropertyRevenuePerAvailableRoom] AS STR_L3M_Monthly_RevPAR
				,al3mf.[CompSetRevenuePerAvailableRoomIndex] / 100  AS STR_L3M_Monthly_RevPAR_Index
				,al3mf.[DataPropertyTransientRoomRevenue] AS STR_L3M_Monthly_Transient_Room_Revenue
				,al3mf.[DataPropertyTransientRoomSold] AS STR_L3M_Monthly_Transient_Rooms_Sold
				,al3mf.[DataPropertyContractRoomRevenue] AS STR_L3M_Monthly_Contract_Room_Revenue
				,al3mf.[DataPropertyContractRoomsSold] AS STR_L3M_Monthly_Contract_Rooms_Sold
				,al3mf.[DataPropertyGroupRoomRevenue] AS STR_L3M_Monthly_Group_Room_Revenue
				,al3mf.[DataPropertyGroupRoomSold] AS STR_L3M_Monthly_Group_Rooms_Sold
				,rcs_dw.WorkdayAvailableRooms
				,rcs_dw.WorkdayOccupiedRooms
				,rcs_dw.WorkdayRoomRevenue
				,rcs_dw.WorkdayGroupPaidOccupiedRooms
				,rcs_dw.WorkdayRetailPaidOccupiedRooms
				,rcs_dw.WorkdayNegotiatedPaidOccupiedRooms
				,rcs_dw.WorkdayLeasePaidOccupiedRooms
				,rcs_dw.WorkdayOtherPaidOccupiedRooms
				,rcs_dw.WorkdayTotalOccupiedRooms
				,rcs_dw.WorkdayOccupancy
				,rcs_dw.L3M_WorkdayAvailableRooms
				,rcs_dw.L3M_WorkdayRoomsSold
				,rcs_dw.L3M_WorkdayRoomRevenue
				,CASE
					WHEN L3M_WorkdayAvailableRooms > 0 THEN (rcs_dw.L3M_WorkdayRoomsSold / L3M_WorkdayAvailableRooms)
				END AS L3M_WorkdayOccupancy
				,CASE
					WHEN rcs_dw.L3M_WorkdayRoomsSold > 0 THEN (rcs_dw.L3M_WorkdayRoomRevenue / rcs_dw.L3M_WorkdayRoomsSold)
				END AS L3M_WorkdayADR
				,CASE
					WHEN rcs_dw.WorkdayAvailableRooms > 0 THEN (rcs_dw.L3M_WorkdayRoomRevenue / rcs_dw.L3M_WorkdayAvailableRooms)
				END AS L3M_WorkdayRevPAR
			FROM [hospitality_DW].[PROPERTY_DIM] pd
			JOIN [hospitality_DW].[HOTEL_DIM] hd
				ON pd.StrId = hd.StrId
				AND hd.IsCurrent = 1
				AND pd.IsCurrent = 1
				AND pd.PropertyStatus = 'Active'
			JOIN [hospitality_DW].[ANALYTICS_MONTHLY_FACT] amf
				ON hd.hotelkey = amf.hotelkey
				AND CompSetNumber = 1 -- only looking at first compset
			JOIN [hospitality_DW].[ANALYTICS_LAST_3_MONTHS_FACT] al3mf
				ON hd.hotelkey = al3mf.hotelkey
				AND amf.DataPeriod = al3mf.DataPeriod
				AND al3mf.CompSetNumber = 1 -- only looking at first compset	
			JOIN [hospitality_DW].[v_Date_YearMonth_Dim] ymd
				ON amf.DataPeriod = ymd.YearMonth
			JOIN #temp_rcs_dw rcs_dw
				ON pd.PropertyId_AK = rcs_dw.PropertyId_AK
				AND ymd.Year = rcs_dw.FiscalYear
				AND ymd.Month = rcs_dw.FiscalMonth
	
			OPTION(LABEL='CTAS:BREIT_RPT_Load');
			
		COMMIT TRANSACTION;

	END TRY

	BEGIN CATCH
		ROLLBACK TRANSACTION;
		SET @ErrorMessage = ERROR_MESSAGE()
		SET @ErrorSeverity = ERROR_SEVERITY()
		SET @ErrorState = ERROR_STATE()
		RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState)
	END CATCH

	DROP TABLE #temp_rcs_dw_pivot;
	DROP TABLE #temp_rcs_dw;

END
GO