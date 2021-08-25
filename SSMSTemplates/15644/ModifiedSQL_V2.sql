USE [RCS_SqlDw_NoView] ;
GO
-- 15 mins
--DROP TABLE RCS_DW.TEMP_ReportLineItems
--CREATE TABLE RCS_DW.TEMP_ReportLineItems
--WITH (DISTRIBUTION=REPLICATE,HEAP )
--AS

IF OBJECT_ID('[tempdb]..[#REPORTLINECALCGROUPMAPPING]') IS NOT NULL
    DROP TABLE [#REPORTLINECALCGROUPMAPPING] ;

SELECT *
INTO [#REPORTLINECALCGROUPMAPPING]
FROM [RCS_DW].[v_ReportLineCalcGroupMapping] ;

IF OBJECT_ID('[tempdb]..[#BookHierarchy_Dim]') IS NOT NULL
    DROP TABLE [#BookHierarchy_Dim] ;

SELECT *
INTO [#BookHierarchy_Dim]
FROM [RCS_DW].[v_BookHierarchy_Dim] ;

IF OBJECT_ID('[tempdb]..[#Scenario_Dim]') IS NOT NULL
    DROP TABLE [#Scenario_Dim] ;

SELECT *
INTO [#Scenario_Dim]
FROM [RCS_DW].[v_Scenario_Dim] ;

IF OBJECT_ID('[tempdb]..[#GL_Monthly_Balance_Activity_Fact]') IS NOT NULL
    DROP TABLE [#GL_Monthly_Balance_Activity_Fact] ;

SELECT *
INTO [#GL_Monthly_Balance_Activity_Fact]
FROM [RCS_DW].[v_GL_Monthly_Balance_Activity_Fact] ;

DROP TABLE IF EXISTS [RCS_DW].[TEMP_ReportLineItems] ;

SELECT
    [rlcg].[ReportLineGroupId]
  , [rlcg].[CostCenter_SK]
  , [rlcg].[ReportLineId]
  , [rli].[ReportLineItem]
  , [rlcg].[LedgerAccountName]
  , [rlcg].[CategoryDesc]
INTO [RCS_DW].[TEMP_ReportLineItems]
FROM [#REPORTLINECALCGROUPMAPPING] AS [rlcg]
INNER JOIN [RCS_DW].[ReportLineItem] AS [rli] ON [rlcg].[ReportLineItem] = [rli].[ReportLineItem] ;

DROP TABLE IF EXISTS [RCS_DW].[TEMP_GLMonthlyBalanceActivity] ;

--DROP TABLE RCS_DW.TEMP_GLMonthlyBalanceActivity
--CREATE TABLE RCS_DW.TEMP_GLMonthlyBalanceActivity
--WITH (DISTRIBUTION=HASH(ReportLineGroupId),HEAP )
--AS
SELECT *
INTO [RCS_DW].[TEMP_GLMonthlyBalanceActivity]
FROM [#GL_Monthly_Balance_Activity_Fact] ;

DROP TABLE IF EXISTS [RCS_DW].[Asset_Review_Actuals] ;

--DROP TABLE RCS_DW.Asset_Review_Actuals 
--CREATE TABLE RCS_DW.Asset_Review_Actuals
--WITH (DISTRIBUTION=ROUND_ROBIN,HEAP)
--AS
SELECT
    [pd].[PropertyID_AK]
  , [pd].[PropertyName]
  , [ccd].[CostCenterDesc]
  , [od].[OutletName]
  , CASE WHEN LEN([mbaf].[FiscalMonth]) = 1 THEN CONCAT([mbaf].[FiscalYear], '0', [mbaf].[FiscalMonth])ELSE CONCAT([mbaf].[FiscalYear], [mbaf].[FiscalMonth])END AS [AsOfDate]
  , [mbaf].[FiscalYear]
  , [mbaf].[FiscalMonth]
  , [rlbgm].[ReportLineId]
  , [rlbgm].[ReportLineGroupId]
  , [rlbgm].[ReportLineItem]
  , [rlbgm].[LedgerAccountName]
  , [rlbgm].[CategoryDesc]
  , SUM([mbaf].[PeriodAmount]) AS [PeriodAmount]
INTO [RCS_DW].[Asset_Review_Actuals]
FROM [RCS_DW].[TEMP_ReportLineItems] AS [rlbgm]
INNER JOIN [RCS_DW].[TEMP_GLMonthlyBalanceActivity] AS [mbaf] ON [rlbgm].[ReportLineGroupId] = [mbaf].[ReportLineGroupId]
INNER JOIN [RCS_DW].[Currency_Dim] AS [curd] ON [mbaf].[Currency_SK] = [curd].[Currency_SK] AND [curd].[Currency_AK] = 'USD' AND [IsCurrent] = 1
INNER JOIN [#BookHierarchy_Dim] AS [bhd] ON [mbaf].[BookCode_SK] = [bhd].[bookCode_SK] AND [bhd].[BookCodeParent] = 'AM Reporting' -- only care about asset management reporting from a reporting perspective
INNER JOIN [#Scenario_Dim] AS [sd1] ON [mbaf].[Scenario_SK] = [sd1].[Scenario_SK] AND [sd1].[ScenarioDesc] = 'Actuals'
INNER JOIN [RCS_DW].[Company_Dim] AS [cd] ON [mbaf].[Company_SK] = [cd].[Company_SK] AND [cd].[IsCurrent] = 1
INNER JOIN [hospitality_DW].[PROPERTY_DIM] AS [pd] ON [cd].[PropertyID_AK] = [pd].[PropertyID_AK] AND [pd].[IsCurrent] = 1 AND [pd].[PropertyStatus] = 'Active' -- only care about active properties
INNER JOIN [RCS_DW].[Cost_Center_Dim] AS [ccd] ON [rlbgm].[CostCenter_SK] = [ccd].[CostCenter_SK] AND [ccd].[IsCurrent] = 1
LEFT JOIN [RCS_DW].[Outlet_Dim] AS [od] ON [cd].[Company_SK] = [od].[Company_SK] AND [ccd].[CostCenter_SK] = [od].[CostCenter_SK] AND [od].[IsCurrent] = 1
GROUP BY [pd].[PropertyID_AK]
       , [pd].[PropertyName]
       , [ccd].[CostCenterDesc]
       , [od].[OutletName]
       , [mbaf].[FiscalYear]
       , [mbaf].[FiscalMonth]
       , [rlbgm].[ReportLineId]
       , [rlbgm].[ReportLineGroupId]
       , [rlbgm].[ReportLineItem]
       , [rlbgm].[LedgerAccountName]
       , [rlbgm].[CategoryDesc]
       , [sd1].[Scenario_SK] ;

DROP TABLE IF EXISTS [RCS_DW].[Asset_Review_Budget] ;

--CREATE TABLE RCS_DW.Asset_Review_Budget
--WITH (DISTRIBUTION=ROUND_ROBIN,HEAP)
--AS
SELECT
    [pd].[PropertyID_AK]
  , [pd].[PropertyName]
  , [ccd].[CostCenterDesc]
  , [od].[OutletName]
  , CASE WHEN LEN([mbaf].[FiscalMonth]) = 1 THEN CONCAT([mbaf].[FiscalYear], '0', [mbaf].[FiscalMonth])ELSE CONCAT([mbaf].[FiscalYear], [mbaf].[FiscalMonth])END AS [AsOfDate]
  , [mbaf].[FiscalYear]
  , [mbaf].[FiscalMonth]
  , [rlbgm].[ReportLineId]
  , [rlbgm].[ReportLineGroupId]
  , [rlbgm].[ReportLineItem]
  , [rlbgm].[LedgerAccountName]
  , [rlbgm].[CategoryDesc]
  , SUM([mbaf].[PeriodAmount]) AS [PeriodAmount]
INTO [RCS_DW].[Asset_Review_Budget]
FROM [RCS_DW].[TEMP_ReportLineItems] AS [rlbgm]
INNER JOIN [RCS_DW].[TEMP_GLMonthlyBalanceActivity] AS [mbaf] ON [rlbgm].[ReportLineGroupId] = [mbaf].[ReportLineGroupId]
INNER JOIN [RCS_DW].[Currency_Dim] AS [curd] ON [mbaf].[Currency_SK] = [curd].[Currency_SK] AND [curd].[Currency_AK] = 'USD' AND [curd].[IsCurrent] = 1
INNER JOIN [#BookHierarchy_Dim] AS [bhd] ON [mbaf].[BookCode_SK] = [bhd].[bookCode_SK] AND [bhd].[BookCodeParent] = 'AM Reporting' -- only care about asset management reporting from a reporting perspective
INNER JOIN [#Scenario_Dim] AS [sd1] ON [mbaf].[Scenario_SK] = [sd1].[Scenario_SK] AND [sd1].[ScenarioDesc] = 'Budget' AND [sd1].[Scenario_AK] = 'Approved'
INNER JOIN [RCS_DW].[Company_Dim] AS [cd] ON [mbaf].[Company_SK] = [cd].[Company_SK] AND [cd].[IsCurrent] = 1
INNER JOIN [hospitality_DW].[PROPERTY_DIM] AS [pd] ON [cd].[PropertyID_AK] = [pd].[PropertyID_AK] AND [pd].[IsCurrent] = 1 AND [pd].[PropertyStatus] = 'Active' -- only care about active properties
INNER JOIN [RCS_DW].[Cost_Center_Dim] AS [ccd] ON [rlbgm].[CostCenter_SK] = [ccd].[CostCenter_SK] AND [ccd].[IsCurrent] = 1
LEFT OUTER JOIN [RCS_DW].[Outlet_Dim] AS [od] ON [cd].[Company_SK] = [od].[Company_SK]
                                             AND [ccd].[CostCenter_SK] = [od].[CostCenter_SK]
                                             AND [od].[IsCurrent] = 1
GROUP BY [pd].[PropertyID_AK]
       , [pd].[PropertyName]
       , [ccd].[CostCenterDesc]
       , [od].[OutletName]
       , [mbaf].[FiscalYear]
       , [mbaf].[FiscalMonth]
       , [rlbgm].[ReportLineId]
       , [rlbgm].[ReportLineGroupId]
       , [rlbgm].[ReportLineItem]
       , [rlbgm].[LedgerAccountName]
       , [rlbgm].[CategoryDesc]
       , [sd1].[Scenario_SK] ;

DROP TABLE IF EXISTS [RCS_DW].[Asset_Review_Blend] ;

--CREATE TABLE RCS_DW.Asset_Review_Blend
--WITH (DISTRIBUTION=ROUND_ROBIN,HEAP)
--AS
SELECT
    [pd].[PropertyID_AK]
  , [pd].[PropertyName]
  , [ccd].[CostCenterDesc]
  , [od].[OutletName]
  , CASE WHEN LEN([mbaf].[FiscalMonth]) = 1 THEN CONCAT([mbaf].[FiscalYear], '0', [mbaf].[FiscalMonth])ELSE CONCAT([mbaf].[FiscalYear], [mbaf].[FiscalMonth])END AS [AsOfDate]
  , [mbaf].[FiscalYear]
  , [mbaf].[FiscalMonth]
  , [rlbgm].[ReportLineId]
  , [rlbgm].[ReportLineGroupId]
  , [rlbgm].[ReportLineItem]
  , [rlbgm].[LedgerAccountName]
  , [rlbgm].[CategoryDesc]
  , [sd1].[Scenario_AK]
  , CASE WHEN [sd1].[Scenario_AK] = 'January_Scenario' THEN 1
        WHEN [sd1].[Scenario_AK] = 'February_Scenario' THEN 2
        WHEN [sd1].[Scenario_AK] = 'March_Scenario' THEN 3
        WHEN [sd1].[Scenario_AK] = 'April_Scenario' THEN 4
        WHEN [sd1].[Scenario_AK] = 'May_Scenario' THEN 5
        WHEN [sd1].[Scenario_AK] = 'June_Scenario' THEN 6
        WHEN [sd1].[Scenario_AK] = 'July_Scenario' THEN 7
        WHEN [sd1].[Scenario_AK] = 'August_Scenario' THEN 8
        WHEN [sd1].[Scenario_AK] = 'September_Scenario' THEN 9
        WHEN [sd1].[Scenario_AK] = 'October_Scenario' THEN 10
        WHEN [sd1].[Scenario_AK] = 'November_Scenario' THEN 11
        WHEN [sd1].[Scenario_AK] = 'December_Scenario' THEN 12
    END AS [Scenario_Rank]
  , SUM([mbaf].[PeriodAmount]) AS [PeriodAmount]
INTO [RCS_DW].[Asset_Review_Blend]
FROM [RCS_DW].[TEMP_ReportLineItems] AS [rlbgm]
INNER JOIN [RCS_DW].[TEMP_GLMonthlyBalanceActivity] AS [mbaf] ON [rlbgm].[ReportLineGroupId] = [mbaf].[ReportLineGroupId]
INNER JOIN [RCS_DW].[Currency_Dim] AS [curd] ON [mbaf].[Currency_SK] = [curd].[Currency_SK] AND [curd].[Currency_AK] = 'USD' AND [curd].[IsCurrent] = 1
INNER JOIN [#BookHierarchy_Dim] AS [bhd] ON [mbaf].[BookCode_SK] = [bhd].[bookCode_SK] AND [bhd].[BookCodeParent] = 'AM Reporting' -- only care about asset management reporting from a reporting perspective
INNER JOIN [RCS_DW].[Scenario_Dim] AS [sd1] ON [mbaf].[Scenario_SK] = [sd1].[Scenario_SK]
                                           AND [sd1].[IsCurrent] = 1
                                           AND [sd1].[Scenario_AK] IN ('January_Scenario', 'February_Scenario', 'March_Scenario', 'April_Scenario'
                                                                     , 'May_Scenario', 'June_Scenario', 'July_Scenario', 'August_Scenario'
                                                                     , 'September_Scenario', 'October_Scenario', 'November_Scenario', 'December_Scenario')
INNER JOIN [RCS_DW].[Company_Dim] AS [cd] ON [mbaf].[Company_SK] = [cd].[Company_SK] AND [cd].[IsCurrent] = 1 AND [cd].[CompanyStatus] = 'Active'
INNER JOIN [hospitality_DW].[PROPERTY_DIM] AS [pd] ON [cd].[PropertyID_AK] = [pd].[PropertyID_AK] AND [pd].[IsCurrent] = 1 AND [pd].[PropertyStatus] = 'Active' -- only care about active properties
INNER JOIN [RCS_DW].[Cost_Center_Dim] AS [ccd] ON [rlbgm].[CostCenter_SK] = [ccd].[CostCenter_SK] AND [ccd].[IsCurrent] = 1
LEFT OUTER JOIN [RCS_DW].[Outlet_Dim] AS [od] ON [cd].[Company_SK] = [od].[Company_SK]
                                             AND [ccd].[CostCenter_SK] = [od].[CostCenter_SK]
                                             AND [od].[IsCurrent] = 1
GROUP BY [pd].[PropertyID_AK]
       , [pd].[PropertyName]
       , [ccd].[CostCenterDesc]
       , [od].[OutletName]
       , [mbaf].[FiscalYear]
       , [mbaf].[FiscalMonth]
       , [rlbgm].[ReportLineId]
       , [rlbgm].[ReportLineGroupId]
       , [rlbgm].[ReportLineItem]
       , [rlbgm].[LedgerAccountName]
       , [rlbgm].[CategoryDesc]
       , [sd1].[Scenario_AK] ;

-------------------------------------
DROP TABLE IF EXISTS [RCS_DW].[Asset_Review_Test]
--CREATE TABLE RCS_DW.Asset_Review_Test
--WITH (DISTRIBUTION=ROUND_ROBIN,HEAP)
--AS
;

WITH [YearMonth_Dim]
AS ( SELECT DISTINCT [Year], [YearMonth], [Month] FROM [hospitality_DW].[DATE_DIM] WHERE [Year] BETWEEN YEAR(GETDATE()) - 4 AND YEAR(GETDATE()))
SELECT *
INTO [RCS_DW].[Asset_Review_Test]
FROM( SELECT
          [acte1].[PropertyId_AK]
        , [acte1].[PropertyName]
        , [acte1].[CostCenterDesc]
        , [acte1].[OutletName]
        , [acte1].[AsOfDate]
        , 'MTD' AS [TimeSeries]
        , 'Actual_Forecast' AS [Type]
        , 'Actual' AS [Scenario]
        , [acte1].[FiscalYear]
        , [acte1].[FiscalMonth]
        , [acte1].[ReportLineId]
        , [acte1].[ReportLineGroupId]
        , [acte1].[ReportLineItem]
        , [acte1].[LedgerAccountName]
        , [acte1].[CategoryDesc]
        , [acte1].[PeriodAmount]
      FROM [RCS_DW].[Asset_Review_Actuals] AS [acte1]
      UNION ALL
      SELECT
          [acte].[PropertyId_AK]
        , [acte].[PropertyName]
        , [acte].[CostCenterDesc]
        , [acte].[OutletName]
        , [ymd].[YearMonth] AS [AsOfDate]
        , ua.[TimeSeries]
        , ua.[Type]
        , ua.[Scenario]
        , [acte].[FiscalYear]
        , [acte].[FiscalMonth]
        , [acte].[ReportLineId]
        , [acte].[ReportLineGroupId]
        , [acte].[ReportLineItem]
        , [acte].[LedgerAccountName]
        , [acte].[CategoryDesc]
        , [acte].[PeriodAmount]
      FROM [YearMonth_Dim] AS [ymd]
      INNER JOIN [RCS_DW].[Asset_Review_Actuals] AS [acte] ON [ymd].[Year] = [acte].[FiscalYear] AND [ymd].[Month] >= [acte].[FiscalMonth]
	  CROSS JOIN (SELECT 'YTD' AS [TimeSeries], 'Actual_Forecast' AS [Type] , 'Actual' AS [Scenario]
UNION ALL 
SELECT  'FY' AS [TimeSeries], 'Actual_Forecast' AS [Type], 'Actual' AS [Scenario]) ua


      UNION ALL
      SELECT
          [bcte1].[PropertyId_AK]
        , [bcte1].[PropertyName]
        , [bcte1].[CostCenterDesc]
        , [bcte1].[OutletName]
        , [bcte1].[AsOfDate]
        , 'MTD' AS [TimeSeries]
        , 'Budget' AS [Type]
        , 'Budget' AS [Scenario]
        , [bcte1].[FiscalYear]
        , [bcte1].[FiscalMonth]
        , [bcte1].[ReportLineId]
        , [bcte1].[ReportLineGroupId]
        , [bcte1].[ReportLineItem]
        , [bcte1].[LedgerAccountName]
        , [bcte1].[CategoryDesc]
        , [bcte1].[PeriodAmount]
      FROM [RCS_DW].[Asset_Review_Budget] AS [bcte1]
      UNION ALL
      SELECT
          [bcte].[PropertyId_AK]
        , [bcte].[PropertyName]
        , [bcte].[CostCenterDesc]
        , [bcte].[OutletName]
        , [ymd].[YearMonth] AS [AsOfDate]
        , 'YTD' AS [TimeSeries]
        , 'Budget' AS [Type]
        , 'Budget' AS [Scenario]
        , [bcte].[FiscalYear]
        , [bcte].[FiscalMonth]
        , [bcte].[ReportLineId]
        , [bcte].[ReportLineGroupId]
        , [bcte].[ReportLineItem]
        , [bcte].[LedgerAccountName]
        , [bcte].[CategoryDesc]
        , [bcte].[PeriodAmount]
      FROM [YearMonth_Dim] AS [ymd]
      INNER JOIN [RCS_DW].[Asset_Review_Budget] AS [bcte] ON [ymd].[Year] = [bcte].[FiscalYear] AND [ymd].[Month] >= [bcte].[FiscalMonth]
      UNION ALL
      SELECT
          [bcte].[PropertyId_AK]
        , [bcte].[PropertyName]
        , [bcte].[CostCenterDesc]
        , [bcte].[OutletName]
        , [ymd].[YearMonth] AS [AsOfDate]
        , 'BOY' AS [TimeSeries]
        , 'Budget' AS [Type]
        , 'Budget' AS [Scenario]
        , [bcte].[FiscalYear]
        , [bcte].[FiscalMonth]
        , [bcte].[ReportLineId]
        , [bcte].[ReportLineGroupId]
        , [bcte].[ReportLineItem]
        , [bcte].[LedgerAccountName]
        , [bcte].[CategoryDesc]
        , [bcte].[PeriodAmount]
      FROM [YearMonth_Dim] AS [ymd]
      INNER JOIN [RCS_DW].[Asset_Review_Budget] AS [bcte] ON [ymd].[Year] = [bcte].[FiscalYear] AND [ymd].[Month] < [bcte].[FiscalMonth]
      UNION ALL
      SELECT
          [bcte].[PropertyId_AK]
        , [bcte].[PropertyName]
        , [bcte].[CostCenterDesc]
        , [bcte].[OutletName]
        , [ymd].[YearMonth] AS [AsOfDate]
        , 'FY' AS [TimeSeries]
        , 'Budget' AS [Type]
        , 'Budget' AS [Scenario]
        , [bcte].[FiscalYear]
        , [bcte].[FiscalMonth]
        , [bcte].[ReportLineId]
        , [bcte].[ReportLineGroupId]
        , [bcte].[ReportLineItem]
        , [bcte].[LedgerAccountName]
        , [bcte].[CategoryDesc]
        , [bcte].[PeriodAmount]
      FROM [YearMonth_Dim] AS [ymd]
      INNER JOIN [RCS_DW].[Asset_Review_Budget] AS [bcte] ON [ymd].[Year] = [bcte].[FiscalYear]
      UNION ALL
      SELECT
          [bcte].[PropertyId_AK]
        , [bcte].[PropertyName]
        , [bcte].[CostCenterDesc]
        , [bcte].[OutletName]
        , [ymd].[YearMonth] AS [AsOfDate]
        , 'BOY' AS [TimeSeries]
        , 'Actual_Forecast' AS [Type]
        , [bcte].[Scenario_AK] AS [Scenario]
        , [bcte].[FiscalYear]
        , [bcte].[FiscalMonth]
        , [bcte].[ReportLineId]
        , [bcte].[ReportLineGroupId]
        , [bcte].[ReportLineItem]
        , [bcte].[LedgerAccountName]
        , [bcte].[CategoryDesc]
        , [bcte].[PeriodAmount]
      FROM [YearMonth_Dim] AS [ymd]
      INNER JOIN [RCS_DW].[Asset_Review_Blend] AS [bcte] ON [ymd].[Year] = [bcte].[FiscalYear]
                                                        AND [ymd].[Month] = [bcte].[Scenario_Rank]
                                                        AND [ymd].[Month] < [bcte].[FiscalMonth]

      UNION ALL
      SELECT
          [bcte].[PropertyId_AK]
        , [bcte].[PropertyName]
        , [bcte].[CostCenterDesc]
        , [bcte].[OutletName]
        , [ymd].[YearMonth] AS [AsOfDate]
        , 'FY' AS [TimeSeries]
        , 'Actual_Forecast' AS [Type]
        , [bcte].[Scenario_AK] AS [Scenario]
        , [bcte].[FiscalYear]
        , [bcte].[FiscalMonth]
        , [bcte].[ReportLineId]
        , [bcte].[ReportLineGroupId]
        , [bcte].[ReportLineItem]
        , [bcte].[LedgerAccountName]
        , [bcte].[CategoryDesc]
        , [bcte].[PeriodAmount]
      FROM [YearMonth_Dim] AS [ymd]
      INNER JOIN [RCS_DW].[Asset_Review_Blend] AS [bcte] ON [ymd].[Year] = [bcte].[FiscalYear]
                                                        AND [ymd].[Month] = [bcte].[Scenario_Rank]
                                                        AND [ymd].[Month] < [bcte].[FiscalMonth]

      -- start of the last year / two year ago 
      UNION ALL
      SELECT
          [acte].[PropertyId_AK]
        , [acte].[PropertyName]
        , [acte].[CostCenterDesc]
        , [acte].[OutletName]
        , [ymd].[YearMonth] AS [AsOfDate]
        , 'MTD' AS [TimeSeries]
        , 'LY' AS [Type]
        , 'Actual' AS [Scenario]
        , [acte].[FiscalYear]
        , [acte].[FiscalMonth]
        , [acte].[ReportLineId]
        , [acte].[ReportLineGroupId]
        , [acte].[ReportLineItem]
        , [acte].[LedgerAccountName]
        , [acte].[CategoryDesc]
        , [acte].[PeriodAmount]
      FROM [YearMonth_Dim] AS [ymd]
      INNER JOIN [RCS_DW].[Asset_Review_Actuals] AS [acte] ON [ymd].[Year] - 1 = [acte].[FiscalYear] -- last year's data
                                                          AND [ymd].[Month] = [acte].[FiscalMonth]
      UNION ALL
      SELECT
          [acte].[PropertyId_AK]
        , [acte].[PropertyName]
        , [acte].[CostCenterDesc]
        , [acte].[OutletName]
        , [ymd].[YearMonth] AS [AsOfDate]
        , CASE WHEN [ymd].[Month] >= [acte].[FiscalMonth] THEN 'YTD' ELSE 'BOY' END AS [TimeSeries]
        , 'LY' AS [Type]
        , 'Actual' AS [Scenario]
        , [acte].[FiscalYear]
        , [acte].[FiscalMonth]
        , [acte].[ReportLineId]
        , [acte].[ReportLineGroupId]
        , [acte].[ReportLineItem]
        , [acte].[LedgerAccountName]
        , [acte].[CategoryDesc]
        , [acte].[PeriodAmount]
      FROM [YearMonth_Dim] AS [ymd]
      INNER JOIN [RCS_DW].[Asset_Review_Actuals] AS [acte] ON [ymd].[Year] - 1 = [acte].[FiscalYear] -- last year's data
      UNION ALL
      SELECT
          [acte].[PropertyId_AK]
        , [acte].[PropertyName]
        , [acte].[CostCenterDesc]
        , [acte].[OutletName]
        , [ymd].[YearMonth] AS [AsOfDate]
        , 'FY' AS [TimeSeries]
        , 'LY' AS [Type]
        , 'Actual' AS [Scenario]
        , [acte].[FiscalYear]
        , [acte].[FiscalMonth]
        , [acte].[ReportLineId]
        , [acte].[ReportLineGroupId]
        , [acte].[ReportLineItem]
        , [acte].[LedgerAccountName]
        , [acte].[CategoryDesc]
        , [acte].[PeriodAmount]
      FROM [YearMonth_Dim] AS [ymd]
      INNER JOIN [RCS_DW].[Asset_Review_Actuals] AS [acte] ON [ymd].[Year] - 1 = [acte].[FiscalYear] -- last year's data
      UNION ALL
      SELECT
          [acte].[PropertyId_AK]
        , [acte].[PropertyName]
        , [acte].[CostCenterDesc]
        , [acte].[OutletName]
        , [ymd].[YearMonth] AS [AsOfDate]
        , 'MTD' AS [TimeSeries]
        , CAST([acte].[FiscalYear] AS VARCHAR(15)) AS [Type]
        , 'Actual' AS [Scenario]
        , [acte].[FiscalYear]
        , [acte].[FiscalMonth]
        , [acte].[ReportLineId]
        , [acte].[ReportLineGroupId]
        , [acte].[ReportLineItem]
        , [acte].[LedgerAccountName]
        , [acte].[CategoryDesc]
        , [acte].[PeriodAmount]
      FROM [YearMonth_Dim] AS [ymd]
      INNER JOIN [RCS_DW].[Asset_Review_Actuals] AS [acte] ON [ymd].[Year] - 2 = [acte].[FiscalYear] -- Two Years Ago data
                                                          AND [ymd].[Month] = [acte].[FiscalMonth]
      UNION ALL
      SELECT
          [acte].[PropertyId_AK]
        , [acte].[PropertyName]
        , [acte].[CostCenterDesc]
        , [acte].[OutletName]
        , [ymd].[YearMonth] AS [AsOfDate]
        , CASE WHEN [ymd].[Month] >= [acte].[FiscalMonth] THEN 'YTD' ELSE 'BOY' END AS [TimeSeries]
        , CAST([acte].[FiscalYear] AS VARCHAR(15)) AS [Type]
        , 'Actual' AS [Scenario]
        , [acte].[FiscalYear]
        , [acte].[FiscalMonth]
        , [acte].[ReportLineId]
        , [acte].[ReportLineGroupId]
        , [acte].[ReportLineItem]
        , [acte].[LedgerAccountName]
        , [acte].[CategoryDesc]
        , [acte].[PeriodAmount]
      FROM [YearMonth_Dim] AS [ymd]
      INNER JOIN [RCS_DW].[Asset_Review_Actuals] AS [acte] ON [ymd].[Year] - 2 = [acte].[FiscalYear] -- Two Years Ago data
      UNION ALL
      SELECT
          [acte].[PropertyId_AK]
        , [acte].[PropertyName]
        , [acte].[CostCenterDesc]
        , [acte].[OutletName]
        , [ymd].[YearMonth] AS [AsOfDate]
        , 'FY' AS [TimeSeries]
        , CAST([acte].[FiscalYear] AS VARCHAR(15)) AS [Type]
        , 'Actual' AS [Scenario]
        , [acte].[FiscalYear]
        , [acte].[FiscalMonth]
        , [acte].[ReportLineId]
        , [acte].[ReportLineGroupId]
        , [acte].[ReportLineItem]
        , [acte].[LedgerAccountName]
        , [acte].[CategoryDesc]
        , [acte].[PeriodAmount]
      FROM [YearMonth_Dim] AS [ymd]
      INNER JOIN [RCS_DW].[Asset_Review_Actuals] AS [acte] ON [ymd].[Year] - 2 = [acte].[FiscalYear] -- Two Years Ago data
) AS [x] ;
GO
