-- SELECT REPLACE(NEWID(),'-','')

DECLARE
    @Getdate DATETIME2(7)
  , @Debug   BIT = 1 ;

IF OBJECT_ID('[RCS_DW].[Asset_Review_RPT_New]') IS NOT NULL
    DROP TABLE [RCS_DW].[Asset_Review_RPT_New] ;

IF OBJECT_ID('[RCS_DW].[Asset_Review_RPT_Old]') IS NOT NULL
    DROP TABLE [RCS_DW].[Asset_Review_RPT_Old] ;

IF OBJECT_ID('[RCS_DW].[Asset_Review_RPT_Old]') IS NOT NULL
    DROP TABLE [RCS_DW].[Asset_Review_RPT_Old] ;

IF OBJECT_ID('[tempdb]..[#BookHierarchy_Dim]') IS NOT NULL
    DROP TABLE [#BookHierarchy_Dim] ;

IF OBJECT_ID('[tempdb]..[#v_Scenario_Dim]') IS NOT NULL
    DROP TABLE [#v_Scenario_Dim] ;

IF OBJECT_ID('[tempdb]..[#GL_Monthly_Balance_Activity_Fact]') IS NOT NULL
    DROP TABLE [#GL_Monthly_Balance_Activity_Fact] ;

IF OBJECT_ID('[tempdb]..[#ReportLineItems]') IS NOT NULL
    DROP TABLE [#ReportLineItems] ;

IF OBJECT_ID('[tempdb]..[#Asset_Review_Actuals]') IS NOT NULL
    DROP TABLE [#Asset_Review_Actuals] ;

IF OBJECT_ID('[tempdb]..[#Asset_Review_Budget]') IS NOT NULL
    DROP TABLE [#Asset_Review_Budget] ;

IF OBJECT_ID('[tempdb]..[#Asset_Review_Blend]') IS NOT NULL
    DROP TABLE [#Asset_Review_Blend] ;

IF OBJECT_ID('[tempdb]..[#YearMonth_Dim]') IS NOT NULL
    DROP TABLE [#YearMonth_Dim] ;

IF OBJECT_ID('[tempdb]..[#Currency_Dim]') IS NOT NULL
    DROP TABLE [#Currency_Dim] ;

IF OBJECT_ID('[tempdb]..[#Cost_Center_Dim]') IS NOT NULL
    DROP TABLE [#Cost_Center_Dim] ;

IF OBJECT_ID('[tempdb]..[#Company_Dim]') IS NOT NULL
    DROP TABLE [#Company_Dim] ;

IF OBJECT_ID('[tempdb]..[#Outlet_Dim]') IS NOT NULL
    DROP TABLE [#Outlet_Dim] ;

IF OBJECT_ID('[tempdb]..[#PROPERTY_DIM]') IS NOT NULL
    DROP TABLE [#PROPERTY_DIM] ;

IF OBJECT_ID('[tempdb]..[#t_Scenario_Dim]') IS NOT NULL
    DROP TABLE [#t_Scenario_Dim] ;

SET @Getdate = GETDATE() ;

SELECT
    [IsCurrent]
  , [Scenario_AK]
  , [Scenario_SK]
  , [ScenarioDesc]
INTO [#t_Scenario_Dim]
FROM [RCS_DW].[Scenario_Dim]
WHERE [IsCurrent] = 1
  AND [Scenario_AK] IN ('January_Scenario', 'February_Scenario', 'March_Scenario', 'April_Scenario', 'May_Scenario', 'June_Scenario', 'July_Scenario'
                      , 'August_Scenario', 'September_Scenario', 'October_Scenario', 'November_Scenario', 'December_Scenario')
  AND /*DEBUG*/ 1 = 1
OPTION( LABEL='Stored_Proc_Name BUILD [#t_Scenario_Dim] 665A288540BB4EF494A191E11D242034' ) ;

IF @Debug = 1
    BEGIN
        PRINT CONCAT('Build [#t_Scenario_Dim], DurationSec: ', CAST(DATEDIFF(MILLISECOND, @Getdate, GETDATE()) / 1000.0 AS NUMERIC(20, 3))) ;

        SET @Getdate = GETDATE() ;
    END ;

SELECT
    [IsCurrent]
  , [PropertyID_AK]
  , [PropertyName]
  , [PropertyStatus]
INTO [#PROPERTY_DIM]
FROM [hospitality_DW].[PROPERTY_DIM]
WHERE [IsCurrent] = 1 AND [PropertyStatus] = 'Active' AND /*DEBUG*/ 1 = 1
OPTION( LABEL='Stored_Proc_Name BUILD [#PROPERTY_DIM] 665A288540BB4EF494A191E11D242034' ) ;

IF @Debug = 1
    BEGIN
        PRINT CONCAT('Build [#PROPERTY_DIM], DurationSec: ', CAST(DATEDIFF(MILLISECOND, @Getdate, GETDATE()) / 1000.0 AS NUMERIC(20, 3))) ;

        SET @Getdate = GETDATE() ;
    END ;

SELECT
    [Company_SK]
  , [CostCenter_SK]
  , [IsCurrent]
  , [OutletName]
INTO [#Outlet_Dim]
FROM [RCS_DW].[Outlet_Dim]
WHERE [IsCurrent] = 1 AND /*DEBUG*/ 1 = 1
OPTION( LABEL='Stored_Proc_Name BUILD [#Outlet_Dim] 665A288540BB4EF494A191E11D242034' ) ;

IF @Debug = 1
    BEGIN
        PRINT CONCAT('Build [#Outlet_Dim], DurationSec: ', CAST(DATEDIFF(MILLISECOND, @Getdate, GETDATE()) / 1000.0 AS NUMERIC(20, 3))) ;

        SET @Getdate = GETDATE() ;
    END ;

SELECT
    [Company_SK]
  , [CompanyStatus]
  , [IsCurrent]
  , [PropertyID_AK]
INTO [#Company_Dim]
FROM [RCS_DW].[Company_Dim]
WHERE [IsCurrent] = 1 AND /*DEBUG*/ 1 = 1
OPTION( LABEL='Stored_Proc_Name BUILD [#Company_Dim] 665A288540BB4EF494A191E11D242034' ) ;

IF @Debug = 1
    BEGIN
        PRINT CONCAT('Build [#Company_Dim], DurationSec: ', CAST(DATEDIFF(MILLISECOND, @Getdate, GETDATE()) / 1000.0 AS NUMERIC(20, 3))) ;

        SET @Getdate = GETDATE() ;
    END ;

SELECT
    [CostCenter_SK]
  , [CostCenterDesc]
  , [IsCurrent]
INTO [#Cost_Center_Dim]
FROM [RCS_DW].[Cost_Center_Dim]
WHERE [IsCurrent] = 1 AND /*DEBUG*/ 1 = 1
OPTION( LABEL='Stored_Proc_Name BUILD [#Cost_Center_Dim] 665A288540BB4EF494A191E11D242034' ) ;

IF @Debug = 1
    BEGIN
        PRINT CONCAT('Build [#Cost_Center_Dim], DurationSec: ', CAST(DATEDIFF(MILLISECOND, @Getdate, GETDATE()) / 1000.0 AS NUMERIC(20, 3))) ;

        SET @Getdate = GETDATE() ;
    END ;

SELECT
    [Currency_AK]
  , [Currency_SK]
  , [IsCurrent]
INTO [#Currency_Dim]
FROM [RCS_DW].[Currency_Dim]( NOLOCK )
WHERE [IsCurrent] = 1 AND [Currency_AK] = 'USD' AND /*DEBUG*/ 1 = 1
OPTION( LABEL='Stored_Proc_Name BUILD [#Currency_Dim] 665A288540BB4EF494A191E11D242034' ) ;

IF @Debug = 1
    BEGIN
        PRINT CONCAT('Build [#Currency_Dim], DurationSec: ', CAST(DATEDIFF(MILLISECOND, @Getdate, GETDATE()) / 1000.0 AS NUMERIC(20, 3))) ;

        SET @Getdate = GETDATE() ;
    END ;

SELECT
    [bookCode_SK]
  , [BookCodeParent]
INTO [#BookHierarchy_Dim]
FROM [RCS_DW].[v_BookHierarchy_Dim]
WHERE [BookCodeParent] = 'AM Reporting' AND /*DEBUG*/ 1 = 1
OPTION( LABEL='Stored_Proc_Name BUILD [#BookHierarchy_Dim] 665A288540BB4EF494A191E11D242034' ) ;

IF @Debug = 1
    BEGIN
        PRINT CONCAT('Build [#BookHierarchy_Dim], DurationSec: ', CAST(DATEDIFF(MILLISECOND, @Getdate, GETDATE()) / 1000.0 AS NUMERIC(20, 3))) ;

        SET @Getdate = GETDATE() ;
    END ;

SELECT
    [Scenario_AK]
  , [Scenario_SK]
  , [ScenarioDesc]
INTO [#v_Scenario_Dim]
FROM [RCS_DW].[v_Scenario_Dim]
WHERE( [ScenarioDesc] = 'Actuals' OR [ScenarioDesc] = 'Budget' AND [Scenario_AK] = 'Approved' ) AND /*DEBUG*/ 1 = 1
OPTION( LABEL='Stored_Proc_Name BUILD [#v_Scenario_Dim] 665A288540BB4EF494A191E11D242034' ) ;

IF @Debug = 1
    BEGIN
        PRINT CONCAT('Build [#v_Scenario_Dim], DurationSec: ', CAST(DATEDIFF(MILLISECOND, @Getdate, GETDATE()) / 1000.0 AS NUMERIC(20, 3))) ;

        SET @Getdate = GETDATE() ;
    END ;

SELECT
    [BankAccount_SK]
  , [BookCode_SK]
  , [Category_SK]
  , [Company_SK]
  , [CostCenter_SK]
  , [Currency_SK]
  , [DateKey]
  , [FiscalMonth]
  , [FiscalYear]
  , [FixedAssetCategory_SK]
  , [Glinfo_SK]
  , [IntercompanyAffiliate_SK]
  , [LedgerAccount_SK]
  , [LedgerType_SK]
  , [PeriodAmount]
  , [PortfolioCompany_SK]
  , [Scenario_SK]
  , [ReportLineGroupId]
INTO [#GL_Monthly_Balance_Activity_Fact]
FROM [RCS_DW].[v_GL_Monthly_Balance_Activity_Fact]
WHERE /*DEBUG*/ 1 = 1
OPTION( LABEL='Stored_Proc_Name BUILD [#GL_Monthly_Balance_Activity_Fact] 665A288540BB4EF494A191E11D242034' ) ;

IF @Debug = 1
    BEGIN
        PRINT CONCAT('Build [#GL_Monthly_Balance_Activity_Fact], DurationSec: ', CAST(DATEDIFF(MILLISECOND, @Getdate, GETDATE()) / 1000.0 AS NUMERIC(20, 3))) ;

        SET @Getdate = GETDATE() ;
    END ;

SELECT
    [rlcg].[ReportLineGroupId]
  , [rlcg].[CostCenter_SK]
  , [rlcg].[ReportLineId]
  , [rli].[ReportLineItem]
  , [rlcg].[LedgerAccountName]
  , [rlcg].[CategoryDesc]
INTO [#ReportLineItems]
FROM [RCS_DW].[ReportLineCalcGroupMapping] AS [rlcg]
INNER JOIN [RCS_DW].[ReportLineItem] AS [rli] ON [rlcg].[ReportLineItem] = [rli].[ReportLineItem]
WHERE /*DEBUG*/ 1 = 1
OPTION( LABEL='Stored_Proc_Name BUILD [#ReportLineItems] 665A288540BB4EF494A191E11D242034' ) ;

IF @Debug = 1
    BEGIN
        PRINT CONCAT('Build [#ReportLineItems], DurationSec: ', CAST(DATEDIFF(MILLISECOND, @Getdate, GETDATE()) / 1000.0 AS NUMERIC(20, 3))) ;

        SET @Getdate = GETDATE() ;
    END ;

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
INTO [#Asset_Review_Actuals]
FROM [#ReportLineItems] AS [rlbgm]
INNER JOIN [#GL_Monthly_Balance_Activity_Fact] AS [mbaf] ON [rlbgm].[ReportLineGroupId] = [mbaf].[ReportLineGroupId]
INNER JOIN [#Currency_Dim] AS [curd] ON [mbaf].[Currency_SK] = [curd].[Currency_SK] AND [curd].[Currency_AK] = 'USD' AND [curd].[IsCurrent] = 1
INNER JOIN [#BookHierarchy_Dim] AS [bhd] ON [mbaf].[BookCode_SK] = [bhd].[bookCode_SK] AND [bhd].[BookCodeParent] = 'AM Reporting' -- only care about asset management reporting from a reporting perspective
INNER JOIN [#v_Scenario_Dim] AS [sd1] ON [mbaf].[Scenario_SK] = [sd1].[Scenario_SK] AND [sd1].[ScenarioDesc] = 'Actuals'
INNER JOIN [#Company_Dim] AS [cd] ON [mbaf].[Company_SK] = [cd].[Company_SK] AND [cd].[IsCurrent] = 1
INNER JOIN [#PROPERTY_DIM] AS [pd] ON [cd].[PropertyID_AK] = [pd].[PropertyID_AK] AND [pd].[IsCurrent] = 1 AND [pd].[PropertyStatus] = 'Active' -- only care about active properties
INNER JOIN [#Cost_Center_Dim] AS [ccd] ON [rlbgm].[CostCenter_SK] = [ccd].[CostCenter_SK] AND [ccd].[IsCurrent] = 1
LEFT JOIN [#Outlet_Dim] AS [od] ON [cd].[Company_SK] = [od].[Company_SK] AND [ccd].[CostCenter_SK] = [od].[CostCenter_SK] AND [od].[IsCurrent] = 1
WHERE /*DEBUG*/ 1 = 1
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
       , [sd1].[Scenario_SK]
OPTION( LABEL='Stored_Proc_Name BUILD [#Asset_Review_Actuals] 665A288540BB4EF494A191E11D242034' ) ;

IF @Debug = 1
    BEGIN
        PRINT CONCAT('Build [#Asset_Review_Actuals], DurationSec: ', CAST(DATEDIFF(MILLISECOND, @Getdate, GETDATE()) / 1000.0 AS NUMERIC(20, 3))) ;

        SET @Getdate = GETDATE() ;
    END ;

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
INTO [#Asset_Review_Budget]
FROM [#ReportLineItems] AS [rlbgm]
INNER JOIN [#GL_Monthly_Balance_Activity_Fact] AS [mbaf] ON [rlbgm].[ReportLineGroupId] = [mbaf].[ReportLineGroupId]
INNER JOIN [#Currency_Dim] AS [curd] ON [mbaf].[Currency_SK] = [curd].[Currency_SK] AND [curd].[Currency_AK] = 'USD' AND [curd].[IsCurrent] = 1
INNER JOIN [#BookHierarchy_Dim] AS [bhd] ON [mbaf].[BookCode_SK] = [bhd].[bookCode_SK] AND [bhd].[BookCodeParent] = 'AM Reporting' -- only care about asset management reporting from a reporting perspective
INNER JOIN [#v_Scenario_Dim] AS [sd1] ON [mbaf].[Scenario_SK] = [sd1].[Scenario_SK] AND [sd1].[ScenarioDesc] = 'Budget' AND [sd1].[Scenario_AK] = 'Approved'
INNER JOIN [#Company_Dim] AS [cd] ON [mbaf].[Company_SK] = [cd].[Company_SK] AND [cd].[IsCurrent] = 1
INNER JOIN [#PROPERTY_DIM] AS [pd] ON [cd].[PropertyID_AK] = [pd].[PropertyID_AK] AND [pd].[IsCurrent] = 1 AND [pd].[PropertyStatus] = 'Active' -- only care about active properties
INNER JOIN [#Cost_Center_Dim] AS [ccd] ON [rlbgm].[CostCenter_SK] = [ccd].[CostCenter_SK] AND [ccd].[IsCurrent] = 1
LEFT OUTER JOIN [#Outlet_Dim] AS [od] ON [cd].[Company_SK] = [od].[Company_SK] AND [ccd].[CostCenter_SK] = [od].[CostCenter_SK] AND [od].[IsCurrent] = 1
WHERE /*DEBUG*/ 1 = 1
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
       , [sd1].[Scenario_SK]
OPTION( LABEL='Stored_Proc_Name BUILD [#Asset_Review_Budget] 665A288540BB4EF494A191E11D242034' ) ;

IF @Debug = 1
    BEGIN
        PRINT CONCAT('Build [#Asset_Review_Budget], DurationSec: ', CAST(DATEDIFF(MILLISECOND, @Getdate, GETDATE()) / 1000.0 AS NUMERIC(20, 3))) ;

        SET @Getdate = GETDATE() ;
    END ;

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
INTO [#Asset_Review_Blend]
FROM [#ReportLineItems] AS [rlbgm]
INNER JOIN [#GL_Monthly_Balance_Activity_Fact] AS [mbaf] ON [rlbgm].[ReportLineGroupId] = [mbaf].[ReportLineGroupId]
INNER JOIN [#Currency_Dim] AS [curd] ON [mbaf].[Currency_SK] = [curd].[Currency_SK] AND [curd].[Currency_AK] = 'USD' AND [curd].[IsCurrent] = 1
INNER JOIN [#BookHierarchy_Dim] AS [bhd] ON [mbaf].[BookCode_SK] = [bhd].[bookCode_SK] AND [bhd].[BookCodeParent] = 'AM Reporting' -- only care about asset management reporting from a reporting perspective
INNER JOIN [#t_Scenario_Dim] AS [sd1] ON [mbaf].[Scenario_SK] = [sd1].[Scenario_SK]
                                     AND [sd1].[IsCurrent] = 1
                                     AND [sd1].[Scenario_AK] IN ('January_Scenario', 'February_Scenario', 'March_Scenario', 'April_Scenario', 'May_Scenario'
                                                               , 'June_Scenario', 'July_Scenario', 'August_Scenario', 'September_Scenario', 'October_Scenario'
                                                               , 'November_Scenario', 'December_Scenario')
INNER JOIN [#Company_Dim] AS [cd] ON [mbaf].[Company_SK] = [cd].[Company_SK] AND [cd].[IsCurrent] = 1 AND [cd].[CompanyStatus] = 'Active'
INNER JOIN [#PROPERTY_DIM] AS [pd] ON [cd].[PropertyID_AK] = [pd].[PropertyID_AK] AND [pd].[IsCurrent] = 1 AND [pd].[PropertyStatus] = 'Active' -- only care about active properties
INNER JOIN [#Cost_Center_Dim] AS [ccd] ON [rlbgm].[CostCenter_SK] = [ccd].[CostCenter_SK] AND [ccd].[IsCurrent] = 1
LEFT OUTER JOIN [#Outlet_Dim] AS [od] ON [cd].[Company_SK] = [od].[Company_SK] AND [ccd].[CostCenter_SK] = [od].[CostCenter_SK] AND [od].[IsCurrent] = 1
WHERE /*DEBUG*/ 1 = 1
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
       , [sd1].[Scenario_AK]
OPTION( LABEL='Stored_Proc_Name BUILD [#Asset_Review_Blend] 665A288540BB4EF494A191E11D242034' ) ;

IF @Debug = 1
    BEGIN
        PRINT CONCAT('Build [#Asset_Review_Blend], DurationSec: ', CAST(DATEDIFF(MILLISECOND, @Getdate, GETDATE()) / 1000.0 AS NUMERIC(20, 3))) ;

        SET @Getdate = GETDATE() ;
    END ;

SELECT DISTINCT
       [Year]
     , [YearMonth]
     , [Month]
INTO [#YearMonth_Dim]
FROM [hospitality_DW].[DATE_DIM]
WHERE [Year] BETWEEN YEAR(GETDATE()) - 4 AND YEAR(GETDATE()) AND /*DEBUG*/ 1 = 1
OPTION( LABEL='Stored_Proc_Name BUILD [#YearMonth_Dim] 665A288540BB4EF494A191E11D242034' ) ;

IF @Debug = 1
    BEGIN
        PRINT CONCAT('Build [#YearMonth_Dim], DurationSec: ', CAST(DATEDIFF(MILLISECOND, @Getdate, GETDATE()) / 1000.0 AS NUMERIC(20, 3))) ;

        SET @Getdate = GETDATE() ;
    END ;

CREATE TABLE [RCS_DW].[Asset_Review_RPT_New]
WITH (DISTRIBUTION = ROUND_ROBIN, HEAP)
AS
SELECT
    CAST([acte1].[PropertyID_AK] AS VARCHAR(100)) AS [PropertyID_AK]
  , CAST([acte1].[PropertyName] AS VARCHAR(100)) AS [PropertyName]
  , CAST([acte1].[CostCenterDesc] AS NVARCHAR(4000)) AS [CostCenterDesc]
  , CAST([acte1].[OutletName] AS NVARCHAR(4000)) AS [OutletName]
  , CAST([acte1].[AsOfDate] AS INT) AS [AsOfDate]
  , CAST('MTD' AS VARCHAR(3)) AS [TimeSeries]
  , CAST('Actual_Forecast' AS VARCHAR(30)) AS [Type]
  , CAST('Actual' AS NVARCHAR(4000)) AS [Scenario]
  , CAST([acte1].[FiscalYear] AS INT) AS [FiscalYear]
  , CAST([acte1].[FiscalMonth] AS SMALLINT) AS [FiscalMonth]
  , CAST([acte1].[ReportLineId] AS VARCHAR(25)) AS [ReportLineId]
  , CAST([acte1].[ReportLineGroupId] AS VARCHAR(50)) AS [ReportLineGroupId]
  , CAST([acte1].[ReportLineItem] AS VARCHAR(100)) AS [ReportLineItem]
  , CAST([acte1].[LedgerAccountName] AS NVARCHAR(4000)) AS [LedgerAccountName]
  , CAST([acte1].[CategoryDesc] AS NVARCHAR(4000)) AS [CategoryDesc]
  , CAST([acte1].[PeriodAmount] AS DECIMAL(38, 2)) AS [PeriodAmount]
FROM [#Asset_Review_Actuals] AS [acte1]
WHERE /*DEBUG*/ 1 = 1
OPTION( LABEL='Stored_Proc_Name Build [RCS_DW].[Asset_Review_RPT_New] Step 1 665A288540BB4EF494A191E11D242034' ) ;

IF @Debug = 1
    BEGIN
        PRINT CONCAT('Build [RCS_DW].[Asset_Review_RPT_New] Step 1, DurationSec: ', CAST(DATEDIFF(MILLISECOND, @Getdate, GETDATE()) / 1000.0 AS NUMERIC(20, 3))) ;

        SET @Getdate = GETDATE() ;
    END ;

INSERT [RCS_DW].[Asset_Review_RPT_New]
SELECT
    [acte].[PropertyID_AK]
  , [acte].[PropertyName]
  , [acte].[CostCenterDesc]
  , [acte].[OutletName]
  , [ymd].[YearMonth] AS [AsOfDate]
  , [ua].[TimeSeries]
  , [ua].[Type]
  , [ua].[Scenario]
  , [acte].[FiscalYear]
  , [acte].[FiscalMonth]
  , [acte].[ReportLineId]
  , [acte].[ReportLineGroupId]
  , [acte].[ReportLineItem]
  , [acte].[LedgerAccountName]
  , [acte].[CategoryDesc]
  , [acte].[PeriodAmount]
FROM [#YearMonth_Dim] AS [ymd]
INNER JOIN [#Asset_Review_Actuals] AS [acte] ON [ymd].[Year] = [acte].[FiscalYear] AND [ymd].[Month] >= [acte].[FiscalMonth]
CROSS JOIN( SELECT
                'YTD' AS [TimeSeries]
              , 'Actual_Forecast' AS [Type]
              , 'Actual' AS [Scenario]
            UNION ALL
            SELECT
                'FY' AS [TimeSeries]
              , 'Actual_Forecast' AS [Type]
              , 'Actual' AS [Scenario] ) AS [ua]
WHERE /*DEBUG*/ 1 = 1
OPTION( LABEL='Stored_Proc_Name Build [RCS_DW].[Asset_Review_RPT_New] Step 2 665A288540BB4EF494A191E11D242034' ) ;

IF @Debug = 1
    BEGIN
        PRINT CONCAT(
                  'Insert [RCS_DW].[Asset_Review_RPT_New] Step 2, DurationSec: ' , CAST(DATEDIFF(MILLISECOND, @Getdate, GETDATE()) / 1000.0 AS NUMERIC(20, 3))) ;

        SET @Getdate = GETDATE() ;
    END ;

INSERT [RCS_DW].[Asset_Review_RPT_New]
SELECT
    [bcte1].[PropertyID_AK]
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
FROM [#Asset_Review_Budget] AS [bcte1]
WHERE /*DEBUG*/ 1 = 1
OPTION( LABEL='Stored_Proc_Name Build [RCS_DW].[Asset_Review_RPT_New] Step 3 665A288540BB4EF494A191E11D242034' ) ;

IF @Debug = 1
    BEGIN
        PRINT CONCAT(
                  'Insert [RCS_DW].[Asset_Review_RPT_New] Step 3, DurationSec: ' , CAST(DATEDIFF(MILLISECOND, @Getdate, GETDATE()) / 1000.0 AS NUMERIC(20, 3))) ;

        SET @Getdate = GETDATE() ;
    END ;

INSERT [RCS_DW].[Asset_Review_RPT_New]
SELECT
    [bcte].[PropertyID_AK]
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
FROM [#YearMonth_Dim] AS [ymd]
INNER JOIN [#Asset_Review_Budget] AS [bcte] ON [ymd].[Year] = [bcte].[FiscalYear] AND [ymd].[Month] >= [bcte].[FiscalMonth]
WHERE /*DEBUG*/ 1 = 1
OPTION( LABEL='Stored_Proc_Name Build [RCS_DW].[Asset_Review_RPT_New] Step 4 665A288540BB4EF494A191E11D242034' ) ;

IF @Debug = 1
    BEGIN
        PRINT CONCAT(
                  'Insert [RCS_DW].[Asset_Review_RPT_New] Step 4, DurationSec: ' , CAST(DATEDIFF(MILLISECOND, @Getdate, GETDATE()) / 1000.0 AS NUMERIC(20, 3))) ;

        SET @Getdate = GETDATE() ;
    END ;

INSERT [RCS_DW].[Asset_Review_RPT_New]
SELECT
    [bcte].[PropertyID_AK]
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
FROM [#YearMonth_Dim] AS [ymd]
INNER JOIN [#Asset_Review_Budget] AS [bcte] ON [ymd].[Year] = [bcte].[FiscalYear] AND [ymd].[Month] < [bcte].[FiscalMonth]
WHERE /*DEBUG*/ 1 = 1
OPTION( LABEL='Stored_Proc_Name Build [RCS_DW].[Asset_Review_RPT_New] Step 5 665A288540BB4EF494A191E11D242034' ) ;

IF @Debug = 1
    BEGIN
        PRINT CONCAT(
                  'Insert [RCS_DW].[Asset_Review_RPT_New] Step 5, DurationSec: ' , CAST(DATEDIFF(MILLISECOND, @Getdate, GETDATE()) / 1000.0 AS NUMERIC(20, 3))) ;

        SET @Getdate = GETDATE() ;
    END ;

INSERT [RCS_DW].[Asset_Review_RPT_New]
SELECT
    [bcte].[PropertyID_AK]
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
FROM [#YearMonth_Dim] AS [ymd]
INNER JOIN [#Asset_Review_Budget] AS [bcte] ON [ymd].[Year] = [bcte].[FiscalYear]
WHERE /*DEBUG*/ 1 = 1
OPTION( LABEL='Stored_Proc_Name Build [RCS_DW].[Asset_Review_RPT_New] Step 6 665A288540BB4EF494A191E11D242034' ) ;

IF @Debug = 1
    BEGIN
        PRINT CONCAT(
                  'Insert [RCS_DW].[Asset_Review_RPT_New] Step 6, DurationSec: ' , CAST(DATEDIFF(MILLISECOND, @Getdate, GETDATE()) / 1000.0 AS NUMERIC(20, 3))) ;

        SET @Getdate = GETDATE() ;
    END ;

INSERT [RCS_DW].[Asset_Review_RPT_New]
SELECT
    [bcte].[PropertyID_AK]
  , [bcte].[PropertyName]
  , [bcte].[CostCenterDesc]
  , [bcte].[OutletName]
  , [ymd].[YearMonth] AS [AsOfDate]
  , [ua].[TimeSeries]
  , [ua].[Type]
  , [bcte].[Scenario_AK] AS [Scenario]
  , [bcte].[FiscalYear]
  , [bcte].[FiscalMonth]
  , [bcte].[ReportLineId]
  , [bcte].[ReportLineGroupId]
  , [bcte].[ReportLineItem]
  , [bcte].[LedgerAccountName]
  , [bcte].[CategoryDesc]
  , [bcte].[PeriodAmount]
FROM [#YearMonth_Dim] AS [ymd]
INNER JOIN [#Asset_Review_Blend] AS [bcte] ON [ymd].[Year] = [bcte].[FiscalYear]
                                          AND [ymd].[Month] = [bcte].[Scenario_Rank]
                                          AND [ymd].[Month] < [bcte].[FiscalMonth]
CROSS JOIN( SELECT 'BOY' AS [TimeSeries], 'Actual_Forecast' AS [Type] UNION ALL SELECT 'FY' AS [TimeSeries], 'Actual_Forecast' AS [Type] ) AS [ua]
WHERE /*DEBUG*/ 1 = 1
OPTION( LABEL='Stored_Proc_Name Build [RCS_DW].[Asset_Review_RPT_New] Step 7 665A288540BB4EF494A191E11D242034' ) ;

IF @Debug = 1
    BEGIN
        PRINT CONCAT(
                  'Insert [RCS_DW].[Asset_Review_RPT_New] Step 7, DurationSec: ' , CAST(DATEDIFF(MILLISECOND, @Getdate, GETDATE()) / 1000.0 AS NUMERIC(20, 3))) ;

        SET @Getdate = GETDATE() ;
    END ;

INSERT [RCS_DW].[Asset_Review_RPT_New]
SELECT
    [acte].[PropertyID_AK]
  , [acte].[PropertyName]
  , [acte].[CostCenterDesc]
  , [acte].[OutletName]
  , [ymd].[YearMonth] AS [AsOfDate]
  , CASE WHEN [ua].[TS] = 'CALC' THEN CASE WHEN [ymd].[Month] >= [acte].[FiscalMonth] THEN 'YTD' ELSE 'BOY' END WHEN [ua].[TS] = 'FY' THEN 'FY' END AS [TimeSeries]
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
FROM [#YearMonth_Dim] AS [ymd]
INNER JOIN [#Asset_Review_Actuals] AS [acte] ON [ymd].[Year] - 1 = [acte].[FiscalYear] -- last year's data
CROSS JOIN( SELECT 'FY' AS [TS] UNION ALL SELECT 'CALC' AS [TS] ) AS [ua]
WHERE /*DEBUG*/ 1 = 1
OPTION( LABEL='Stored_Proc_Name Build [RCS_DW].[Asset_Review_RPT_New] Step 8 665A288540BB4EF494A191E11D242034' ) ;

IF @Debug = 1
    BEGIN
        PRINT CONCAT(
                  'Insert [RCS_DW].[Asset_Review_RPT_New] Step 8, DurationSec: ' , CAST(DATEDIFF(MILLISECOND, @Getdate, GETDATE()) / 1000.0 AS NUMERIC(20, 3))) ;

        SET @Getdate = GETDATE() ;
    END ;

INSERT [RCS_DW].[Asset_Review_RPT_New]
SELECT
    [acte].[PropertyID_AK]
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
FROM [#YearMonth_Dim] AS [ymd]
INNER JOIN [#Asset_Review_Actuals] AS [acte] ON [ymd].[Year] - 1 = [acte].[FiscalYear] -- last year's data
                                            AND [ymd].[Month] = [acte].[FiscalMonth]
WHERE /*DEBUG*/ 1 = 1
OPTION( LABEL='Stored_Proc_Name Build [RCS_DW].[Asset_Review_RPT_New] Step 9 665A288540BB4EF494A191E11D242034' ) ;

IF @Debug = 1
    BEGIN
        PRINT CONCAT(
                  'Insert [RCS_DW].[Asset_Review_RPT_New] Step 9, DurationSec: ' , CAST(DATEDIFF(MILLISECOND, @Getdate, GETDATE()) / 1000.0 AS NUMERIC(20, 3))) ;

        SET @Getdate = GETDATE() ;
    END ;

INSERT [RCS_DW].[Asset_Review_RPT_New]
SELECT
    [acte].[PropertyID_AK]
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
FROM [#YearMonth_Dim] AS [ymd]
INNER JOIN [#Asset_Review_Actuals] AS [acte] ON [ymd].[Year] - 2 = [acte].[FiscalYear] -- Two Years Ago data
                                            AND [ymd].[Month] = [acte].[FiscalMonth]
WHERE /*DEBUG*/ 1 = 1
OPTION( LABEL='Stored_Proc_Name Build [RCS_DW].[Asset_Review_RPT_New] Step 10 665A288540BB4EF494A191E11D242034' ) ;

IF @Debug = 1
    BEGIN
        PRINT CONCAT(
                  'Insert [RCS_DW].[Asset_Review_RPT_New] Step 10, DurationSec: ' , CAST(DATEDIFF(MILLISECOND, @Getdate, GETDATE()) / 1000.0 AS NUMERIC(20, 3))) ;

        SET @Getdate = GETDATE() ;
    END ;

INSERT [RCS_DW].[Asset_Review_RPT_New]
SELECT
    [acte].[PropertyID_AK]
  , [acte].[PropertyName]
  , [acte].[CostCenterDesc]
  , [acte].[OutletName]
  , [ymd].[YearMonth] AS [AsOfDate]
  , CASE WHEN [ua].[TS] = 'CALC' THEN CASE WHEN [ymd].[Month] >= [acte].[FiscalMonth] THEN 'YTD' ELSE 'BOY' END WHEN [ua].[TS] = 'FY' THEN 'FY' END AS [TimeSeries]
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
FROM [#YearMonth_Dim] AS [ymd]
INNER JOIN [#Asset_Review_Actuals] AS [acte] ON [ymd].[Year] - 2 = [acte].[FiscalYear] -- Two Years Ago data
CROSS JOIN( SELECT 'CALC' AS [TS] UNION ALL SELECT 'FY' AS [TS] ) AS [ua]
WHERE /*DEBUG*/ 1 = 1
OPTION( LABEL='Stored_Proc_Name Build [RCS_DW].[Asset_Review_RPT_New] Step 11 665A288540BB4EF494A191E11D242034' ) ;

IF @Debug = 1
    BEGIN
        PRINT CONCAT(
                  'Insert [RCS_DW].[Asset_Review_RPT_New] Step 11, DurationSec: ' , CAST(DATEDIFF(MILLISECOND, @Getdate, GETDATE()) / 1000.0 AS NUMERIC(20, 3))) ;

        SET @Getdate = GETDATE() ;
    END ;
IF OBJECT_ID('[RCS_DW].[Asset_Review_RPT]') IS NOT NULL
	RENAME OBJECT [RCS_DW].[Asset_Review_RPT] TO [Asset_Review_RPT_Old];

RENAME OBJECT [RCS_DW].[Asset_Review_RPT_New] TO [Asset_Review_RPT];

IF OBJECT_ID('[RCS_DW].[Asset_Review_RPT_Old]') IS NOT NULL
	DROP TABLE [RCS_DW].[Asset_Review_RPT_Old]


SELECT '[#t_Scenario_Dim]' as [TableName], Count(1) as [Rows]
FROM [#t_Scenario_Dim]
UNION ALL
SELECT '[#PROPERTY_DIM]' as [TableName], Count(1) as [Rows]
FROM [#PROPERTY_DIM]
UNION ALL
SELECT '[#Outlet_Dim]' as [TableName], Count(1) as [Rows]
FROM [#Outlet_Dim]
UNION ALL
SELECT '[#Company_Dim]' as [TableName], Count(1) as [Rows]
FROM [#Company_Dim]
UNION ALL
SELECT '[#Cost_Center_Dim]' as [TableName], Count(1) as [Rows]
FROM [#Cost_Center_Dim]
UNION ALL
SELECT '[#Currency_Dim]' as [TableName], Count(1) as [Rows]
FROM [#Currency_Dim]
UNION ALL
SELECT '[RCS_DW].[ReportLineCalcGroupMapping]' as [TableName], Count(1) as [Rows]
FROM [RCS_DW].[ReportLineCalcGroupMapping]
UNION ALL
SELECT '[#BookHierarchy_Dim]' as [TableName], Count(1) as [Rows]
FROM [#BookHierarchy_Dim]
UNION ALL
SELECT '[#v_Scenario_Dim]' as [TableName], Count(1) as [Rows]
FROM [#v_Scenario_Dim]
UNION ALL
SELECT '[#GL_Monthly_Balance_Activity_Fact]' as [TableName], Count(1) as [Rows]
FROM [#GL_Monthly_Balance_Activity_Fact]
UNION ALL
SELECT '[#ReportLineItems]' as [TableName], Count(1) as [Rows]
FROM [#ReportLineItems]
UNION ALL
SELECT '[#Asset_Review_Actuals]' as [TableName], Count(1) as [Rows]
FROM [#Asset_Review_Actuals]
UNION ALL
SELECT '[#Asset_Review_Budget]' as [TableName], Count(1) as [Rows]
FROM [#Asset_Review_Budget]
UNION ALL
SELECT '[#Asset_Review_Blend]' as [TableName], Count(1) as [Rows]
FROM [#Asset_Review_Blend]
UNION ALL
SELECT '[#YearMonth_Dim]' as [TableName], Count(1) as [Rows]
FROM [#YearMonth_Dim]
UNION ALL
SELECT '[RCS_DW].[Asset_Review_RPT]' as [TableName], Count(1) as [Rows]
FROM [RCS_DW].[Asset_Review_RPT]

/*
SELECT
	[TableName], [Rows]
FROM (VALUES
('[#t_Scenario_Dim]', 12),
('[#PROPERTY_DIM]', 131),
('[#Outlet_Dim]', 16583),
('[#Company_Dim]', 9344),
('[#Cost_Center_Dim]', 403),
('[#Currency_Dim]', 1),
('[RCS_DW].[ReportLineCalcGroupMapping]', 84654),
('[#BookHierarchy_Dim]', 5),
('[#v_Scenario_Dim]', 2),
('[#GL_Monthly_Balance_Activity_Fact]', 12180036),
('[#ReportLineItems]', 63569),
('[#Asset_Review_Actuals]', 17426268),
('[#Asset_Review_Budget]', 7145688),
('[#Asset_Review_Blend]', 62358504),
('[#YearMonth_Dim]', 60),
('[RCS_DW].[Asset_Review_RPT]', 1075406776))
vdata ([TableName], [Rows])
*/