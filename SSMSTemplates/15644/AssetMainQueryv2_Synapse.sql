-- 15 mins
DROP TABLE RCS_DW.TEMP_ReportLineItems
CREATE TABLE RCS_DW.TEMP_ReportLineItems--vw_ReportLineItems
WITH (DISTRIBUTION=REPLICATE,HEAP )
AS
SELECT
    ReportLineGroupId
    ,CostCenter_SK
    ,ReportLineId
    ,rli.ReportLineItem
    ,LedgerAccountName
    ,CategoryDesc
FROM RCS_DW.V_REPORTLINECALCGROUPMAPPING rlcg
INNER JOIN RCS_DW.ReportLineItem rli ON rlcg.ReportLineItem = rli.ReportLineItem

-- 10 seconds 12M rows
DROP TABLE RCS_DW.TEMP_GLMonthlyBalanceActivity
CREATE TABLE RCS_DW.TEMP_GLMonthlyBalanceActivity--vw_ReportLineItems
WITH (DISTRIBUTION=HASH(ReportLineGroupId),HEAP )
AS
SELECT * FROM [RCS_DW].[v_GL_Monthly_Balance_Activity_Fact]

--
DROP TABLE RCS_DW.Asset_Review_Actuals
CREATE TABLE RCS_DW.Asset_Review_Actuals
WITH (DISTRIBUTION=ROUND_ROBIN,HEAP)
AS
SELECT
    pd.PropertyId_AK
    ,pd.PropertyName
    ,ccd.CostCenterDesc
    ,od.OutletName
    ,CASE
        WHEN LEN(mbaf.FiscalMonth) = 1 THEN CONCAT(mbaf.FiscalYear, '0', mbaf.FiscalMonth)
        ELSE CONCAT(mbaf.FiscalYear, mbaf.FiscalMonth)
      END AS AsOfDate
    ,mbaf.FiscalYear
    ,mbaf.FiscalMonth
    ,rlbgm.ReportLineId
    ,rlbgm.ReportLineGroupId
    ,rlbgm.ReportLineItem
    ,rlbgm.LedgerAccountName
    ,rlbgm.CategoryDesc
    ,SUM(PeriodAmount) AS PeriodAmount
FROM RCS_DW.TEMP_ReportLineItems rlbgm
	INNER JOIN RCS_DW.TEMP_GLMonthlyBalanceActivity mbaf    ON rlbgm.ReportLineGroupId = mbaf.ReportLineGroupId
	INNER JOIN RCS_DW.Currency_Dim curd ON mbaf.Currency_SK = curd.Currency_SK AND curd.Currency_AK = 'USD' AND IsCurrent=1
	INNER JOIN RCS_DW.V_BOOKHIERARCHY_DIM	bhd ON mbaf.BookCode_SK = bhd.BookCode_SK AND bhd.BookCodeParent = 'AM Reporting' -- only care about asset management reporting from a reporting perspective
	INNER JOIN RCS_DW.v_SCENARIO_DIM			sd1	ON mbaf.scenario_SK = sd1.scenario_SK    AND sd1.ScenarioDesc = 'Actuals'
	INNER JOIN RCS_DW.COMPANY_DIM			cd	ON mbaf.company_SK = cd.company_SK AND cd.IsCurrent=1
	INNER JOIN HOSPITALITY_DW.PROPERTY_DIM	pd  ON cd.PropertyId_AK = pd.PropertyId_AK    AND pd.IsCurrent = 1    AND pd.PropertyStatus = 'Active' -- only care about active properties
	INNER JOIN RCS_DW.COST_CENTER_DIM		ccd ON rlbgm.CostCenter_SK = ccd.CostCenter_SK AND ccd.IsCurrent=1
	LEFT JOIN RCS_DW.OUTLET_DIM				od  ON cd.company_sk = od.company_sk    AND ccd.costcenter_sk = od.costcenter_sk    AND od.IsCurrent = 1

GROUP BY
    pd.PropertyId_AK
    ,pd.PropertyName
    ,ccd.CostCenterDesc
    ,od.OutletName
    ,mbaf.FiscalYear
    ,mbaf.FiscalMonth
    ,rlbgm.ReportLineId
    ,rlbgm.ReportLineGroupId
    ,rlbgm.ReportLineItem
    ,rlbgm.LedgerAccountName
    ,rlbgm.CategoryDesc
    ,sd1.scenario_SK
;


-----------------------------

--CREATE OR REPLACE TABLE "BRE_SANDBOX"."BRE"."Asset_Review_Budget"
--COMMENT = 'Asset Review Budget'
CREATE TABLE RCS_DW.Asset_Review_Budget
WITH (DISTRIBUTION=ROUND_ROBIN,HEAP)
AS
SELECT
    pd.PropertyId_AK
    ,pd.PropertyName
    ,ccd.CostCenterDesc
    ,od.OutletName
    ,CASE
        WHEN LEN(mbaf.FiscalMonth) = 1 THEN CONCAT(mbaf.FiscalYear, '0', mbaf.FiscalMonth)
        ELSE CONCAT(mbaf.FiscalYear, mbaf.FiscalMonth)
      END AS AsOfDate
    ,mbaf.FiscalYear
    ,mbaf.FiscalMonth
    ,rlbgm.ReportLineId
    ,rlbgm.ReportLineGroupId
    ,rlbgm.ReportLineItem
    ,rlbgm.LedgerAccountName
    ,rlbgm.CategoryDesc
    ,SUM(PeriodAmount) AS PeriodAmount
FROM  RCS_DW.TEMP_ReportLineItems rlbgm
	INNER JOIN RCS_DW.TEMP_GLMonthlyBalanceActivity mbaf    ON rlbgm.ReportLineGroupId = mbaf.ReportLineGroupId
	INNER JOIN RCS_DW.Currency_Dim curd ON mbaf.Currency_SK = curd.Currency_SK AND curd.Currency_AK = 'USD' AND curd.IsCurrent=1
	INNER JOIN RCS_DW.V_BOOKHIERARCHY_DIM bhd    ON mbaf.BookCode_SK = bhd.BookCode_SK  AND bhd.BookCodeParent = 'AM Reporting' -- only care about asset management reporting from a reporting perspective
	INNER JOIN RCS_DW.v_Scenario_Dim sd1     ON mbaf.scenario_SK = sd1.scenario_SK    AND sd1.ScenarioDesc = 'Budget'    AND sd1.Scenario_AK = 'Approved'
	INNER JOIN RCS_DW.COMPANY_DIM cd    ON mbaf.company_SK = cd.company_SK AND cd.IsCurrent=1
	INNER JOIN HOSPITALITY_DW.PROPERTY_DIM pd    ON cd.PropertyId_AK = pd.PropertyId_AK    AND pd.IsCurrent = 1    AND pd.PropertyStatus = 'Active' -- only care about active properties
	INNER JOIN RCS_DW.COST_CENTER_DIM ccd    ON rlbgm.CostCenter_SK = ccd.CostCenter_SK AND ccd.IsCurrent=1
	LEFT OUTER JOIN RCS_DW.OUTLET_DIM od    ON cd.company_sk = od.company_sk    AND ccd.costcenter_sk = od.costcenter_sk    AND od.IsCurrent = 1
GROUP BY
    pd.PropertyId_AK
    ,pd.PropertyName
    ,ccd.CostCenterDesc
    ,od.OutletName
    ,mbaf.FiscalYear
    ,mbaf.FiscalMonth
    ,rlbgm.ReportLineId
    ,rlbgm.ReportLineGroupId
    ,rlbgm.ReportLineItem
    ,rlbgm.LedgerAccountName
    ,rlbgm.CategoryDesc
    ,sd1.scenario_SK
;

-----------------------------

--CREATE OR REPLACE TABLE "BRE_SANDBOX"."BRE"."Asset_Review_Blend"
--COPY GRANTS
--COMMENT = 'Asset Review Blend'

CREATE TABLE RCS_DW.Asset_Review_Blend
WITH (DISTRIBUTION=ROUND_ROBIN,HEAP)
AS
SELECT
    pd.PropertyId_AK
    ,pd.PropertyName
    ,ccd.CostCenterDesc
    ,od.OutletName
    ,CASE
        WHEN LEN(mbaf.FiscalMonth) = 1 THEN CONCAT(mbaf.FiscalYear, '0', mbaf.FiscalMonth)
        ELSE CONCAT(mbaf.FiscalYear, mbaf.FiscalMonth)
      END AS AsOfDate
    ,mbaf.FiscalYear
    ,mbaf.FiscalMonth
    ,rlbgm.ReportLineId
    ,rlbgm.ReportLineGroupId
    ,rlbgm.ReportLineItem
    ,rlbgm.LedgerAccountName
    ,rlbgm.CategoryDesc
    ,sd1.Scenario_AK
    ,CASE
        WHEN sd1.Scenario_AK = 'January_Scenario' THEN 1
        WHEN sd1.Scenario_AK = 'February_Scenario' THEN 2
        WHEN sd1.Scenario_AK = 'March_Scenario' THEN 3
        WHEN sd1.Scenario_AK = 'April_Scenario' THEN 4
        WHEN sd1.Scenario_AK = 'May_Scenario' THEN 5
        WHEN sd1.Scenario_AK = 'June_Scenario' THEN 6
        WHEN sd1.Scenario_AK = 'July_Scenario' THEN 7
        WHEN sd1.Scenario_AK = 'August_Scenario' THEN 8
        WHEN sd1.Scenario_AK = 'September_Scenario' THEN 9
        WHEN sd1.Scenario_AK = 'October_Scenario' THEN 10
        WHEN sd1.Scenario_AK = 'November_Scenario' THEN 11
        WHEN sd1.Scenario_AK = 'December_Scenario' THEN 12
    END AS Scenario_Rank
    ,SUM(PeriodAmount) AS PeriodAmount
FROM RCS_DW.TEMP_ReportLineItems rlbgm
	INNER JOIN RCS_DW.TEMP_GLMonthlyBalanceActivity mbaf ON rlbgm.ReportLineGroupId = mbaf.ReportLineGroupId
	INNER JOIN RCS_DW.Currency_Dim curd ON mbaf.Currency_SK = curd.Currency_SK AND curd.Currency_AK = 'USD' AND curd.IsCurrent=1
	INNER JOIN RCS_DW.V_BOOKHIERARCHY_DIM bhd    ON mbaf.BookCode_SK = bhd.BookCode_SK    AND bhd.BookCodeParent = 'AM Reporting' -- only care about asset management reporting from a reporting perspective
	INNER JOIN RCS_DW.SCENARIO_DIM sd1 ON mbaf.scenario_SK = sd1.scenario_SK AND sd1.IsCurrent=1
		AND sd1.Scenario_AK IN(
                        'January_Scenario'
                        ,'February_Scenario'
                        ,'March_Scenario'
                        ,'April_Scenario'
                        ,'May_Scenario'
                        ,'June_Scenario'
                        ,'July_Scenario'
                        ,'August_Scenario'
                        ,'September_Scenario'
                        ,'October_Scenario'
                        ,'November_Scenario'
                        ,'December_Scenario'
                        )
	INNER JOIN RCS_DW.COMPANY_DIM cd    ON mbaf.company_SK = cd.company_SK AND cd.isCurrent = 1 AND cd.CompanyStatus = 'Active'
	INNER JOIN HOSPITALITY_DW.PROPERTY_DIM pd    ON cd.PropertyId_AK = pd.PropertyId_AK    AND pd.IsCurrent = 1    AND pd.PropertyStatus = 'Active' -- only care about active properties
	INNER JOIN RCS_DW.COST_CENTER_DIM ccd    ON rlbgm.CostCenter_SK = ccd.CostCenter_SK AND ccd.IsCurrent=1
	LEFT OUTER JOIN RCS_DW.OUTLET_DIM od    ON cd.company_sk = od.company_sk    AND ccd.costcenter_sk = od.costcenter_sk    AND od.IsCurrent = 1
GROUP BY
    pd.PropertyId_AK
    ,pd.PropertyName
    ,ccd.CostCenterDesc
    ,od.OutletName
    ,mbaf.FiscalYear
    ,mbaf.FiscalMonth
    ,rlbgm.ReportLineId
    ,rlbgm.ReportLineGroupId
    ,rlbgm.ReportLineItem
    ,rlbgm.LedgerAccountName
    ,rlbgm.CategoryDesc
    ,sd1.Scenario_AK
;

-------------------------------------

--CREATE OR REPLACE TABLE "BRE_SANDBOX"."BRE"."Asset_Review_Test"
CREATE TABLE RCS_DW.Asset_Review_Test
WITH (DISTRIBUTION=ROUND_ROBIN,HEAP)
AS

WITH YearMonth_Dim

AS

(
    SELECT DISTINCT
        Year
        ,YearMonth
        ,Month
    FROM HOSPITALITY_DW.DATE_DIM
    WHERE Year BETWEEN YEAR(CURRENT_DATE) - 4 AND YEAR(CURRENT_DATE)
)

SELECT * FROM (

  SELECT
      PropertyId_AK
      ,PropertyName
      ,acte1.CostCenterDesc
      ,OutletName
      ,AsOfDate
      ,'MTD' AS TimeSeries
      ,'Actual_Forecast' AS Type
      ,'Actual' AS Scenario
      ,FiscalYear
      ,FiscalMonth
      ,ReportLineId
      ,ReportLineGroupId
      ,ReportLineItem
      ,LedgerAccountName
      ,CategoryDesc
      ,PeriodAmount
  FROM RCS_DW.Asset_Review_Actuals acte1

  UNION ALL

  SELECT
      acte.PropertyId_AK
      ,acte.PropertyName
      ,acte.CostCenterDesc
      ,acte.OutletName
      ,ymd.YearMonth AS AsOfDate
      ,'YTD' AS TimeSeries
      ,'Actual_Forecast' AS Type
      ,'Actual' AS Scenario
      ,acte.FiscalYear
      ,acte.FiscalMonth
      ,acte.ReportLineId
      ,acte.ReportLineGroupId
      ,acte.ReportLineItem
      ,acte.LedgerAccountName
      ,acte.CategoryDesc
      ,acte.PeriodAmount
  FROM YearMonth_Dim ymd
  JOIN RCS_DW.Asset_Review_Actuals acte
      ON ymd.Year = acte.Fiscalyear
      AND ymd.Month >= acte.FiscalMonth

  UNION ALL

  SELECT
      PropertyId_AK
      ,PropertyName
      ,bcte1.CostCenterDesc
      ,bcte1.OutletName
      ,bcte1.AsOfDate
      ,'MTD' AS TimeSeries
      ,'Budget' AS Type
      ,'Budget' AS Scenario
      ,FiscalYear
      ,FiscalMonth
      ,ReportLineId
      ,ReportLineGroupId
      ,ReportLineItem
      ,LedgerAccountName
      ,CategoryDesc
      ,PeriodAmount
  FROM RCS_DW.Asset_Review_Budget bcte1

  UNION ALL

  SELECT
      bcte.PropertyId_AK
      ,bcte.PropertyName
      ,bcte.CostCenterDesc
      ,bcte.OutletName
      ,ymd.YearMonth AS AsOfDate
      ,'YTD' AS TimeSeries
      ,'Budget' AS Type
      ,'Budget' AS Scenario
      ,bcte.FiscalYear
      ,bcte.FiscalMonth
      ,bcte.ReportLineId
      ,bcte.ReportLineGroupId
      ,bcte.ReportLineItem
      ,bcte.LedgerAccountName
      ,bcte.CategoryDesc
      ,bcte.PeriodAmount
  FROM YearMonth_Dim ymd
  JOIN RCS_DW.Asset_Review_Budget bcte
      ON ymd.Year = bcte.Fiscalyear
      AND ymd.Month >= bcte.FiscalMonth

  UNION ALL

  SELECT
      bcte.PropertyId_AK
      ,bcte.PropertyName
      ,bcte.CostCenterDesc
      ,bcte.OutletName
      ,ymd.YearMonth AS AsOfDate
      ,'BOY' AS TimeSeries
      ,'Budget' AS Type
      ,'Budget' AS Scenario
      ,bcte.FiscalYear
      ,bcte.FiscalMonth
      ,bcte.ReportLineId
      ,bcte.ReportLineGroupId
      ,bcte.ReportLineItem
      ,bcte.LedgerAccountName
      ,bcte.CategoryDesc
      ,bcte.PeriodAmount
  FROM YearMonth_Dim ymd
  JOIN RCS_DW.Asset_Review_Budget bcte
      ON ymd.Year = bcte.Fiscalyear
      AND ymd.Month < bcte.FiscalMonth

  UNION ALL

  SELECT
      bcte.PropertyId_AK
      ,bcte.PropertyName
      ,bcte.CostCenterDesc
      ,bcte.OutletName
      ,ymd.YearMonth AS AsOfDate
      ,'FY' AS TimeSeries
      ,'Budget' AS Type
      ,'Budget' AS Scenario
      ,bcte.FiscalYear
      ,bcte.FiscalMonth
      ,bcte.ReportLineId
      ,bcte.ReportLineGroupId
      ,bcte.ReportLineItem
      ,bcte.LedgerAccountName
      ,bcte.CategoryDesc
      ,bcte.PeriodAmount
  FROM YearMonth_Dim ymd
  JOIN RCS_DW.Asset_Review_Budget bcte      ON ymd.Year = bcte.Fiscalyear

  UNION ALL

  SELECT
      bcte.PropertyId_AK
      ,bcte.PropertyName
      ,bcte.CostCenterDesc
      ,bcte.OutletName
      ,ymd.YearMonth AS AsOfDate
      ,'BOY' AS TimeSeries
      ,'Actual_Forecast' AS Type
      ,bcte.Scenario_AK AS Scenario
      ,bcte.FiscalYear
      ,bcte.FiscalMonth
      ,bcte.ReportLineId
      ,bcte.ReportLineGroupId
      ,bcte.ReportLineItem
      ,bcte.LedgerAccountName
      ,bcte.CategoryDesc
      ,bcte.PeriodAmount
  FROM YearMonth_Dim ymd
  JOIN RCS_DW.Asset_Review_Blend bcte
      ON ymd.Year = bcte.Fiscalyear
      AND ymd.Month = bcte.Scenario_Rank
      AND ymd.Month < bcte.FiscalMonth

  UNION ALL

  SELECT
      acte.PropertyId_AK
      ,acte.PropertyName
      ,acte.CostCenterDesc
      ,acte.OutletName
      ,ymd.YearMonth AS AsOfDate
      ,'FY' AS TimeSeries
      ,'Actual_Forecast' AS Type
      ,'Actual' AS Scenario
      ,acte.FiscalYear
      ,acte.FiscalMonth
      ,acte.ReportLineId
      ,acte.ReportLineGroupId
      ,acte.ReportLineItem
      ,acte.LedgerAccountName
      ,acte.CategoryDesc
      ,acte.PeriodAmount
  FROM YearMonth_Dim ymd
  JOIN RCS_DW.Asset_Review_Actuals acte
      ON ymd.Year = acte.Fiscalyear
      AND ymd.Month >= acte.FiscalMonth

  UNION ALL

  SELECT
      bcte.PropertyId_AK
      ,bcte.PropertyName
      ,bcte.CostCenterDesc
      ,bcte.OutletName
      ,ymd.YearMonth AS AsOfDate
      ,'FY' AS TimeSeries
      ,'Actual_Forecast' AS Type
      ,bcte.Scenario_AK AS Scenario
      ,bcte.FiscalYear
      ,bcte.FiscalMonth
      ,bcte.ReportLineId
      ,bcte.ReportLineGroupId
      ,bcte.ReportLineItem
      ,bcte.LedgerAccountName
      ,bcte.CategoryDesc
      ,bcte.PeriodAmount
  FROM YearMonth_Dim ymd
  JOIN RCS_DW.Asset_Review_Blend bcte
      ON ymd.Year = bcte.Fiscalyear
      AND ymd.Month = bcte.Scenario_Rank
      AND ymd.Month < bcte.FiscalMonth

-------------------
  -- start of the last year / two year ago

  UNION ALL

  SELECT
      acte.PropertyId_AK
      ,acte.PropertyName
      ,acte.CostCenterDesc
      ,acte.OutletName
      ,ymd.YearMonth AS AsOfDate
      ,'MTD' AS TimeSeries
      ,'LY' AS Type
      ,'Actual' AS Scenario
      ,acte.FiscalYear
      ,acte.FiscalMonth
      ,acte.ReportLineId
      ,acte.ReportLineGroupId
      ,acte.ReportLineItem
      ,acte.LedgerAccountName
      ,acte.CategoryDesc
      ,acte.PeriodAmount
  FROM YearMonth_Dim ymd
  JOIN RCS_DW.Asset_Review_Actuals acte
      ON ymd.Year - 1 = acte.Fiscalyear -- last year's data
      AND ymd.Month = acte.FiscalMonth

  UNION ALL

  SELECT
      acte.PropertyId_AK
      ,acte.PropertyName
      ,acte.CostCenterDesc
      ,acte.OutletName
      ,ymd.YearMonth AS AsOfDate
      ,CASE
        WHEN ymd.Month >= acte.FiscalMonth THEN 'YTD'
        ELSE 'BOY'
       END AS TimeSeries
      ,'LY' AS Type
      ,'Actual' AS Scenario
      ,acte.FiscalYear
      ,acte.FiscalMonth
      ,acte.ReportLineId
      ,acte.ReportLineGroupId
      ,acte.ReportLineItem
      ,acte.LedgerAccountName
      ,acte.CategoryDesc
      ,acte.PeriodAmount
  FROM YearMonth_Dim ymd
  JOIN RCS_DW.Asset_Review_Actuals acte
      ON ymd.Year - 1 = acte.Fiscalyear -- last year's data

  UNION ALL

  SELECT
      acte.PropertyId_AK
      ,acte.PropertyName
      ,acte.CostCenterDesc
      ,acte.OutletName
      ,ymd.YearMonth AS AsOfDate
      ,'FY' AS TimeSeries
      ,'LY' AS Type
      ,'Actual' AS Scenario
      ,acte.FiscalYear
      ,acte.FiscalMonth
      ,acte.ReportLineId
      ,acte.ReportLineGroupId
      ,acte.ReportLineItem
      ,acte.LedgerAccountName
      ,acte.CategoryDesc
      ,acte.PeriodAmount
  FROM YearMonth_Dim ymd
  JOIN RCS_DW.Asset_Review_Actuals acte      ON ymd.Year - 1 = acte.Fiscalyear -- last year's data

  UNION ALL

  SELECT
      acte.PropertyId_AK
      ,acte.PropertyName
      ,acte.CostCenterDesc
      ,acte.OutletName
      ,ymd.YearMonth AS AsOfDate
      ,'MTD' AS TimeSeries
      ,CAST(acte.FiscalYear AS VARCHAR(15)) AS Type
      ,'Actual' AS Scenario
      ,acte.FiscalYear
      ,acte.FiscalMonth
      ,acte.ReportLineId
      ,acte.ReportLineGroupId
      ,acte.ReportLineItem
      ,acte.LedgerAccountName
      ,acte.CategoryDesc
      ,acte.PeriodAmount
  FROM YearMonth_Dim ymd
  JOIN RCS_DW.Asset_Review_Actuals acte
      ON ymd.Year - 2 = acte.Fiscalyear -- Two Years Ago data
      AND ymd.Month = acte.FiscalMonth

  UNION ALL

  SELECT
      acte.PropertyId_AK
      ,acte.PropertyName
      ,acte.CostCenterDesc
      ,acte.OutletName
      ,ymd.YearMonth AS AsOfDate
      ,CASE
        WHEN ymd.Month >= acte.FiscalMonth THEN 'YTD'
        ELSE 'BOY'
       END AS TimeSeries
      ,CAST(acte.FiscalYear AS VARCHAR(15)) AS Type
      ,'Actual' AS Scenario
      ,acte.FiscalYear
      ,acte.FiscalMonth
      ,acte.ReportLineId
      ,acte.ReportLineGroupId
      ,acte.ReportLineItem
      ,acte.LedgerAccountName
      ,acte.CategoryDesc
      ,acte.PeriodAmount
  FROM YearMonth_Dim ymd
  JOIN RCS_DW.Asset_Review_Actuals acte ON ymd.Year - 2 = acte.Fiscalyear -- Two Years Ago data

  UNION ALL

  SELECT
      acte.PropertyId_AK
      ,acte.PropertyName
      ,acte.CostCenterDesc
      ,acte.OutletName
      ,ymd.YearMonth AS AsOfDate
      ,'FY' AS TimeSeries
      ,CAST(acte.FiscalYear AS VARCHAR(15)) AS Type
      ,'Actual' AS Scenario
      ,acte.FiscalYear
      ,acte.FiscalMonth
      ,acte.ReportLineId
      ,acte.ReportLineGroupId
      ,acte.ReportLineItem
      ,acte.LedgerAccountName
      ,acte.CategoryDesc
      ,acte.PeriodAmount
  FROM YearMonth_Dim ymd
  JOIN RCS_DW.Asset_Review_Actuals acte      ON ymd.Year - 2 = acte.Fiscalyear -- Two Years Ago data
) x
;
