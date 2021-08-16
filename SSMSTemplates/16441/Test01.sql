IF OBJECT_ID('tempdb..[#ReportLineBaseGroupMapping]') IS not NULL
DROP TABLE [#ReportLineBaseGroupMapping] ;


IF OBJECT_ID('tempdb..[#ReportLineBaseGroupMapping]') IS NULL
    SELECT
        [Category_SK]
      , [CategoryDesc]
      , [CostCenter_SK]
      , [CostCenterDesc]
      , [LedgerAccount_SK]
      , [LedgerAccountName]
      , [ReportLineGroupId]
      , [ReportLineId]
      , [ReportLineItem]
      , [signFactor]
    INTO [#ReportLineBaseGroupMapping]
    FROM [RCS_DW].[v_ReportLineBaseGroupMapping]
	OPTION(LABEL = 'Build [#ReportLineBaseGroupMapping]')
-- 2:08
-- 2:03
--(24537 rows affected)

IF OBJECT_ID('tempdb..[#ReportLineMapping]') IS not NULL
DROP TABLE [#ReportLineMapping] ;


IF OBJECT_ID('tempdb..[#ReportLineMapping]') IS NULL
    SELECT
        *
    INTO [#ReportLineMapping]
    FROM [RCS_DW].[v_ReportLineMapping]
	OPTION(LABEL = 'Build [#ReportLineMapping]')
-- 00:02
--(384 rows affected)

IF OBJECT_ID('[RCS_DW].[v_ReportLineCalcGroupMapping_GVAROL]') IS not NULL
DROP TABLE [RCS_DW].[v_ReportLineCalcGroupMapping_GVAROL] ;

CREATE TABLE [RCS_DW].[v_ReportLineCalcGroupMapping_GVAROL]
WITH
(
 DISTRIBUTION = REPLICATE
)
AS
SELECT
    [ReportLineId]
  , [ReportLineItem]
  , [CostCenterDesc]
  , [CostCenter_SK]
  , [LedgerAccountName]
  , [LedgerAccount_SK]
  , [CategoryDesc]
  , [Category_SK]
  , [ReportLineGroupId]
  , [signFactor]
  , CAST(1 AS DECIMAL(10, 5)) AS [constFactor]
FROM [#ReportLineBaseGroupMapping]
UNION ALL
SELECT
    [calcmap].[CalcReportLineId] AS [ReportLineId]
  , [map].[ReportLineItem]
  , [base].[CostCenterDesc]
  , [base].[CostCenter_SK]
  , [base].[LedgerAccountName]
  , [base].[LedgerAccount_SK]
  , [base].[CategoryDesc]
  , [base].[Category_SK]
  , [base].[ReportLineGroupId]
  , [calcmap].[signFactor]
  , [calcmap].[constFactor]
FROM [#ReportLineBaseGroupMapping] AS [base]
INNER JOIN [RCS_DW].[ReportLineCalcBusinessMapping] AS [calcmap]
INNER JOIN [RCS_DW].[ReportLineMapping] AS [map] ON [map].[ReportLineId] = [calcmap].[CalcReportLineId] ON [base].[ReportLineId] = [calcmap].[ReportLineId]
UNION ALL
SELECT
    'L204' AS [ReportLineId]
  , [ReportLineItem]
  , [CostCenterDesc]
  , [CostCenter_SK]
  , [LedgerAccountName]
  , [LedgerAccount_SK]
  , [CategoryDesc]
  , [Category_SK]
  , [ReportLineGroupId]
  , [signFactor]
  , CAST(1 AS DECIMAL(10, 5)) AS [constFactor]
FROM [#ReportLineBaseGroupMapping]
WHERE [ReportLineId] = 'L206' AND [CostCenterDesc] NOT IN ('Catering (Local/Social related)', 'Banquets (Group Rooms Related)')
UNION ALL
SELECT
    'L205' AS [ReportLineId]
  , [ReportLineItem]
  , [CostCenterDesc]
  , [CostCenter_SK]
  , [LedgerAccountName]
  , [LedgerAccount_SK]
  , [CategoryDesc]
  , [Category_SK]
  , [ReportLineGroupId]
  , [signFactor]
  , CAST(1 AS DECIMAL(10, 5)) AS [constFactor]
FROM [#ReportLineBaseGroupMapping]
WHERE [ReportLineId] = 'L206' AND [CostCenterDesc] IN ('Catering (Local/Social related)', 'Banquets (Group Rooms Related)')
UNION ALL
SELECT
    'L2033' AS [ReportLineId]
  , [ReportLineItem]
  , [CostCenterDesc]
  , [CostCenter_SK]
  , [LedgerAccountName]
  , [LedgerAccount_SK]
  , [CategoryDesc]
  , [Category_SK]
  , [ReportLineGroupId]
  , [signFactor]
  , CAST(1 AS DECIMAL(10, 5)) AS [constFactor]
FROM [#ReportLineBaseGroupMapping]
WHERE [ReportLineId] = 'L206' AND [LedgerAccountName] NOT IN ('BRH | 400050 | Food Revenue', 'BRH | 400060 | Beverage Revenue')
UNION ALL
SELECT
    'L310' AS [ReportLineId]
  , [ReportLineItem]
  , [CostCenterDesc]
  , [CostCenter_SK]
  , [LedgerAccountName]
  , [LedgerAccount_SK]
  , [CategoryDesc]
  , [Category_SK]
  , [ReportLineGroupId]
  , [signFactor]
  , CAST(1 AS DECIMAL(10, 5)) AS [constFactor]
FROM [#ReportLineBaseGroupMapping]
WHERE [ReportLineId] = 'L3090' AND [CostCenterDesc] NOT IN ('Catering (Local/Social related)', 'Banquets (Group Rooms Related)')
UNION ALL
SELECT
    'L311' AS [ReportLineId]
  , [ReportLineItem]
  , [CostCenterDesc]
  , [CostCenter_SK]
  , [LedgerAccountName]
  , [LedgerAccount_SK]
  , [CategoryDesc]
  , [Category_SK]
  , [ReportLineGroupId]
  , [signFactor]
  , CAST(1 AS DECIMAL(10, 5)) AS [constFactor]
FROM [#ReportLineBaseGroupMapping]
WHERE [ReportLineId] = 'L3090' AND [CostCenterDesc] IN ('Catering (Local/Social related)', 'Banquets (Group Rooms Related)')
UNION ALL
SELECT
    'L312' AS [ReportLineId]
  , [ReportLineItem]
  , [CostCenterDesc]
  , [CostCenter_SK]
  , [LedgerAccountName]
  , [LedgerAccount_SK]
  , [CategoryDesc]
  , [Category_SK]
  , [ReportLineGroupId]
  , [signFactor]
  , CAST(1 AS DECIMAL(10, 5)) AS [constFactor]
FROM [#ReportLineBaseGroupMapping]
WHERE [ReportLineId] = 'L3110' AND [CostCenterDesc] NOT IN ('Catering (Local/Social related)', 'Banquets (Group Rooms Related)')
UNION ALL
SELECT
    'L313' AS [ReportLineId]
  , [ReportLineItem]
  , [CostCenterDesc]
  , [CostCenter_SK]
  , [LedgerAccountName]
  , [LedgerAccount_SK]
  , [CategoryDesc]
  , [Category_SK]
  , [ReportLineGroupId]
  , [signFactor]
  , CAST(1 AS DECIMAL(10, 5)) AS [constFactor]
FROM [#ReportLineBaseGroupMapping]
WHERE [ReportLineId] = 'L3110' AND [CostCenterDesc] IN ('Catering (Local/Social related)', 'Banquets (Group Rooms Related)')
UNION ALL
SELECT
    'L401' AS [ReportLineId]
  , [ReportLineItem]
  , [CostCenterDesc]
  , [CostCenter_SK]
  , [LedgerAccountName]
  , [LedgerAccount_SK]
  , [CategoryDesc]
  , [Category_SK]
  , [ReportLineGroupId]
  , [signFactor]
  , CAST(1 AS DECIMAL(10, 5)) AS [constFactor]
FROM [#ReportLineBaseGroupMapping]
WHERE [ReportLineId] = 'L402'
  AND [LedgerAccountName] NOT IN ('BRH | 214010 | Accrued Payroll', 'BRH | 500250 | Property Payroll Taxes and related expenses'
                                , 'BRH | 500220 | Property Payroll - Overtime Pay (by Skill set)', 'BRH | 500240 | Property Payroll - Benefits'
                                , 'BRH | 500230 | Property Payroll - Other Pay', 'BRH | 211050 | Unclaimed Wages Payroll'
                                , 'BRH | 214020 | Accrued Payroll Taxes', 'BRH | 500210 | Property Payroll - Regular Pay (by Skill set)')
UNION ALL
SELECT
    'L407' AS [ReportLineId]
  , [ReportLineItem]
  , [CostCenterDesc]
  , [CostCenter_SK]
  , [LedgerAccountName]
  , [LedgerAccount_SK]
  , [CategoryDesc]
  , [Category_SK]
  , [ReportLineGroupId]
  , [signFactor]
  , CAST(1 AS DECIMAL(10, 5)) AS [constFactor]
FROM [#ReportLineBaseGroupMapping]
WHERE [ReportLineId] = 'L408'
  AND [LedgerAccountName] NOT IN ('BRH | 214010 | Accrued Payroll', 'BRH | 500250 | Property Payroll Taxes and related expenses'
                                , 'BRH | 500220 | Property Payroll - Overtime Pay (by Skill set)', 'BRH | 500240 | Property Payroll - Benefits'
                                , 'BRH | 500230 | Property Payroll - Other Pay', 'BRH | 211050 | Unclaimed Wages Payroll'
                                , 'BRH | 214020 | Accrued Payroll Taxes', 'BRH | 500210 | Property Payroll - Regular Pay (by Skill set)')
UNION ALL
SELECT
    'L420' AS [ReportLineId]
  , [ReportLineItem]
  , [CostCenterDesc]
  , [CostCenter_SK]
  , [LedgerAccountName]
  , [LedgerAccount_SK]
  , [CategoryDesc]
  , [Category_SK]
  , [ReportLineGroupId]
  , [signFactor]
  , CAST(1 AS DECIMAL(10, 5)) AS [constFactor]
FROM [#ReportLineBaseGroupMapping]
WHERE [ReportLineId] = 'L421'
  AND [LedgerAccountName] NOT IN ('BRH | 214010 | Accrued Payroll', 'BRH | 500250 | Property Payroll Taxes and related expenses'
                                , 'BRH | 500220 | Property Payroll - Overtime Pay (by Skill set)', 'BRH | 500240 | Property Payroll - Benefits'
                                , 'BRH | 500230 | Property Payroll - Other Pay', 'BRH | 211050 | Unclaimed Wages Payroll'
                                , 'BRH | 214020 | Accrued Payroll Taxes', 'BRH | 500210 | Property Payroll - Regular Pay (by Skill set)')
UNION ALL
SELECT
    'L412' AS [ReportLineId]
  , 'S&M (less Marketing Fees/Frequent Guest Program/Web Site)' AS [ReportLineItem]
  , [datL412].[CostCenterDesc]
  , [datL412].[CostCenter_SK]
  , [datL412].[LedgerAccountName]
  , [datL412].[LedgerAccount_SK]
  , [datL412].[CategoryDesc]
  , [datL412].[Category_SK]
  , [datL412].[ReportLineGroupId]
  , [datL412].[signFactor]
  , CAST(1 AS DECIMAL(10, 5)) AS [constFactor]
FROM( SELECT
          [CostCenterDesc]
        , [CostCenter_SK]
        , [LedgerAccountName]
        , [LedgerAccount_SK]
        , [CategoryDesc]
        , [Category_SK]
        , [ReportLineGroupId]
        , [signFactor]
      FROM [#ReportLineBaseGroupMapping]
      WHERE [ReportLineId] = 'L418'
      EXCEPT
      SELECT
          [CostCenterDesc]
        , [CostCenter_SK]
        , [LedgerAccountName]
        , [LedgerAccount_SK]
        , [CategoryDesc]
        , [Category_SK]
        , [ReportLineGroupId]
        , [signFactor]
      FROM [#ReportLineBaseGroupMapping]
      WHERE [ReportLineId] IN ('L414', 'L415', 'L416')) AS [datL412]
UNION ALL
SELECT
    'L411' AS [ReportLineId]
  , 'S&M Other Expense' AS [ReportLineItem]
  , [datL411].[CostCenterDesc]
  , [datL411].[CostCenter_SK]
  , [datL411].[LedgerAccountName]
  , [datL411].[LedgerAccount_SK]
  , [datL411].[CategoryDesc]
  , [datL411].[Category_SK]
  , [datL411].[ReportLineGroupId]
  , [datL411].[signFactor]
  , CAST(1 AS DECIMAL(10, 5)) AS [constFactor]
FROM( SELECT
          [CostCenterDesc]
        , [CostCenter_SK]
        , [LedgerAccountName]
        , [LedgerAccount_SK]
        , [CategoryDesc]
        , [Category_SK]
        , [ReportLineGroupId]
        , [signFactor]
      FROM [#ReportLineBaseGroupMapping]
      WHERE [ReportLineId] = 'L418'
      EXCEPT
      SELECT
          [CostCenterDesc]
        , [CostCenter_SK]
        , [LedgerAccountName]
        , [LedgerAccount_SK]
        , [CategoryDesc]
        , [Category_SK]
        , [ReportLineGroupId]
        , [signFactor]
      FROM [#ReportLineBaseGroupMapping]
      WHERE [ReportLineId] IN ('L414', 'L415', 'L416')) AS [datL411]
WHERE [datL411].[LedgerAccountName] NOT IN ('BRH | 214010 | Accrued Payroll', 'BRH | 500250 | Property Payroll Taxes and related expenses'
                                          , 'BRH | 500220 | Property Payroll - Overtime Pay (by Skill set)', 'BRH | 500240 | Property Payroll - Benefits'
                                          , 'BRH | 500230 | Property Payroll - Other Pay', 'BRH | 211050 | Unclaimed Wages Payroll'
                                          , 'BRH | 214020 | Accrued Payroll Taxes', 'BRH | 500210 | Property Payroll - Regular Pay (by Skill set)')
UNION ALL
SELECT
    'L304' AS [ReportLineId]
  , 'Rooms Other Exp (excl. TA)' AS [ReportLineItem]
  , [datL304].[CostCenterDesc]
  , [datL304].[CostCenter_SK]
  , [datL304].[LedgerAccountName]
  , [datL304].[LedgerAccount_SK]
  , [datL304].[CategoryDesc]
  , [datL304].[Category_SK]
  , [datL304].[ReportLineGroupId]
  , [datL304].[signFactor]
  , CAST(1 AS DECIMAL(10, 5)) AS [constFactor]
FROM( SELECT
          [CostCenterDesc]
        , [CostCenter_SK]
        , [LedgerAccountName]
        , [LedgerAccount_SK]
        , [CategoryDesc]
        , [Category_SK]
        , [ReportLineGroupId]
        , [signFactor]
        , CAST(1 AS DECIMAL(10, 5)) AS [constFactor]
      FROM [#ReportLineBaseGroupMapping]
      WHERE [ReportLineId] = 'L305' AND [CategoryDesc] NOT LIKE 'RC%'
      EXCEPT
      SELECT
          [CostCenterDesc]
        , [CostCenter_SK]
        , [LedgerAccountName]
        , [LedgerAccount_SK]
        , [CategoryDesc]
        , [Category_SK]
        , [ReportLineGroupId]
        , [signFactor]
        , CAST(1 AS DECIMAL(10, 5)) AS [constFactor]
      FROM [#ReportLineBaseGroupMapping]
      WHERE [ReportLineId] IN ('L300', 'L301')) AS [datL304]
UNION ALL
SELECT
    'L314' AS [ReportLineId]
  , [ReportLineItem]
  , [CostCenterDesc]
  , [CostCenter_SK]
  , [LedgerAccountName]
  , [LedgerAccount_SK]
  , [CategoryDesc]
  , [Category_SK]
  , [ReportLineGroupId]
  , [signFactor]
  , CAST(1 AS DECIMAL(10, 5)) AS [constFactor]
FROM [#ReportLineBaseGroupMapping]
WHERE [ReportLineId] = 'L315'
  AND [LedgerAccountName] IN ('BRH | 500260 | Other Expense', 'BRH | 500270 | Contract Expense', 'BRH | 500280 | Complimentary Expense'
                              , 'BRH | 500290 | Commissions Expense')
UNION ALL
SELECT
    'L611' AS [ReportLineId]
  , 'Undistributed (less CC/Marketing Fees/Frequent Guest Program/Web Site)' AS [ReportLineItem]
  , [CostCenterDesc]
  , [CostCenter_SK]
  , [LedgerAccountName]
  , [LedgerAccount_SK]
  , [CategoryDesc]
  , [Category_SK]
  , [ReportLineGroupId]
  , [signFactor]
  , CAST(1 AS DECIMAL(10, 5)) AS [constFactor]
FROM [#ReportLineBaseGroupMapping]
WHERE [ReportLineId] IN ('L423', 'L421', 'L408', 'L402', 'L4180')
UNION ALL
SELECT
    'L611' AS [ReportLineId]
  , 'Undistributed (less CC/Marketing Fees/Frequent Guest Program/Web Site)' AS [ReportLineItem]
  , [dataL412].[CostCenterDesc]
  , [dataL412].[CostCenter_SK]
  , [dataL412].[LedgerAccountName]
  , [dataL412].[LedgerAccount_SK]
  , [dataL412].[CategoryDesc]
  , [dataL412].[Category_SK]
  , [dataL412].[ReportLineGroupId]
  , [dataL412].[signFactor]
  , CAST(1 AS DECIMAL(10, 5)) AS [constFactor]
FROM( SELECT
          [CostCenterDesc]
        , [CostCenter_SK]
        , [LedgerAccountName]
        , [LedgerAccount_SK]
        , [CategoryDesc]
        , [Category_SK]
        , [ReportLineGroupId]
        , [signFactor]
      FROM [#ReportLineBaseGroupMapping]
      WHERE [ReportLineId] = 'L418'
      EXCEPT
      SELECT
          [CostCenterDesc]
        , [CostCenter_SK]
        , [LedgerAccountName]
        , [LedgerAccount_SK]
        , [CategoryDesc]
        , [Category_SK]
        , [ReportLineGroupId]
        , [signFactor]
      FROM [#ReportLineBaseGroupMapping]
      WHERE [ReportLineId] IN ('L414', 'L415', 'L416')) AS [dataL412]
UNION ALL
SELECT
    'L1001' AS [ReportLineId]
  , 'Other Occupied Rooms' AS [ReportLineItem]
  , [datL1001].[CostCenterDesc]
  , [datL1001].[CostCenter_SK]
  , [datL1001].[LedgerAccountName]
  , [datL1001].[LedgerAccount_SK]
  , [datL1001].[CategoryDesc]
  , [datL1001].[Category_SK]
  , [datL1001].[ReportLineGroupId]
  , [datL1001].[signFactor]
  , CAST(1 AS DECIMAL(10, 5)) AS [constFactor]
FROM( SELECT
          [CostCenterDesc]
        , [CostCenter_SK]
        , [LedgerAccountName]
        , [LedgerAccount_SK]
        , [CategoryDesc]
        , [Category_SK]
        , [ReportLineGroupId]
        , [signFactor]
      FROM [#ReportLineBaseGroupMapping]
      WHERE [ReportLineId] = 'L1002'
      EXCEPT
      SELECT
          [CostCenterDesc]
        , [CostCenter_SK]
        , [LedgerAccountName]
        , [LedgerAccount_SK]
        , [CategoryDesc]
        , [Category_SK]
        , [ReportLineGroupId]
        , [signFactor]
      FROM [#ReportLineBaseGroupMapping]
      WHERE [ReportLineId] = 'L100' ) AS [datL1001]
UNION ALL
SELECT
    'L2030' AS [ReportLineId]
  , 'Non Group Room Revenue' AS [ReportLineItem]
  , [datL2030].[CostCenterDesc]
  , [datL2030].[CostCenter_SK]
  , [datL2030].[LedgerAccountName]
  , [datL2030].[LedgerAccount_SK]
  , [datL2030].[CategoryDesc]
  , [datL2030].[Category_SK]
  , [datL2030].[ReportLineGroupId]
  , [datL2030].[signFactor]
  , CAST(1 AS DECIMAL(10, 5)) AS [constFactor]
FROM( SELECT
          [CostCenterDesc]
        , [CostCenter_SK]
        , [LedgerAccountName]
        , [LedgerAccount_SK]
        , [CategoryDesc]
        , [Category_SK]
        , [ReportLineGroupId]
        , [signFactor]
      FROM [#ReportLineBaseGroupMapping]
      WHERE [ReportLineId] = 'L203'
      EXCEPT
      SELECT
          [CostCenterDesc]
        , [CostCenter_SK]
        , [LedgerAccountName]
        , [LedgerAccount_SK]
        , [CategoryDesc]
        , [Category_SK]
        , [ReportLineGroupId]
        , [signFactor]
      FROM [#ReportLineBaseGroupMapping]
      WHERE [ReportLineId] = 'L201' ) AS [datL2030]
UNION ALL
SELECT
    'L3081' AS [ReportLineId]
  , 'Total Payroll - F&B Dept (Excl Service Chrgs)' AS [ReportLineItem]
  , [CostCenterDesc]
  , [CostCenter_SK]
  , [LedgerAccountName]
  , [LedgerAccount_SK]
  , [CategoryDesc]
  , [Category_SK]
  , [ReportLineGroupId]
  , [signFactor]
  , CAST(1 AS DECIMAL(10, 5)) AS [constFactor]
FROM [#ReportLineBaseGroupMapping]
WHERE [ReportLineId] = 'L308'
  AND [LedgerAccountName] IN ('BRH | 500210 | Property Payroll - Regular Pay (by Skill set)', 'BRH | 500220 | Property Payroll - Overtime Pay (by Skill set)')
  AND [CategoryDesc] NOT IN ('SC1690 | Service Charge Payroll')
UNION ALL
SELECT
    'L625' AS [ReportLineId]
  , 'F&B Other Operating Expenses' AS [ReportLineItem]
  , [CostCenterDesc]
  , [CostCenter_SK]
  , [LedgerAccountName]
  , [LedgerAccount_SK]
  , [CategoryDesc]
  , [Category_SK]
  , [ReportLineGroupId]
  , [signFactor]
  , CAST(1 AS DECIMAL(10, 5)) AS [constFactor]
FROM [#ReportLineBaseGroupMapping]
WHERE [ReportLineId] = 'L624'
  AND [LedgerAccountName] IN ('BRH | 500260 | Other Expense', 'BRH | 500270 | Contract Expense', 'BRH | 500280 | Complimentary Expense')
UNION ALL
SELECT
    'L309' AS [ReportLineId]
  , 'Cost of Sales' AS [ReportLineItem]
  , [datL309].[CostCenterDesc]
  , [datL309].[CostCenter_SK]
  , [datL309].[LedgerAccountName]
  , [datL309].[LedgerAccount_SK]
  , [datL309].[CategoryDesc]
  , [datL309].[Category_SK]
  , [datL309].[ReportLineGroupId]
  , [datL309].[signFactor]
  , CAST(1 AS DECIMAL(10, 5)) AS [constFactor]
FROM( SELECT
          [CostCenterDesc]
        , [CostCenter_SK]
        , [LedgerAccountName]
        , [LedgerAccount_SK]
        , [CategoryDesc]
        , [Category_SK]
        , [ReportLineGroupId]
        , [signFactor]
      FROM [#ReportLineBaseGroupMapping]
      WHERE [ReportLineId] = 'L626'
      EXCEPT
      SELECT
          [datL308plusL625].[CostCenterDesc]
        , [datL308plusL625].[CostCenter_SK]
        , [datL308plusL625].[LedgerAccountName]
        , [datL308plusL625].[LedgerAccount_SK]
        , [datL308plusL625].[CategoryDesc]
        , [datL308plusL625].[Category_SK]
        , [datL308plusL625].[ReportLineGroupId]
        , [datL308plusL625].[signFactor]
      FROM( SELECT
                [CostCenterDesc]
              , [CostCenter_SK]
              , [LedgerAccountName]
              , [LedgerAccount_SK]
              , [CategoryDesc]
              , [Category_SK]
              , [ReportLineGroupId]
              , [signFactor]
            FROM [#ReportLineBaseGroupMapping]
            WHERE [ReportLineId] = 'L308'
            UNION ALL
            SELECT
                [CostCenterDesc]
              , [CostCenter_SK]
              , [LedgerAccountName]
              , [LedgerAccount_SK]
              , [CategoryDesc]
              , [Category_SK]
              , [ReportLineGroupId]
              , [signFactor]
            FROM [#ReportLineBaseGroupMapping]
            WHERE [ReportLineId] = 'L624'
              AND [LedgerAccountName] IN ('BRH | 500260 | Other Expense', 'BRH | 500270 | Contract Expense', 'BRH | 500280 | Complimentary Expense'
                                          , 'BRH | 500290 | Commissions Expense')) AS [datL308plusL625] ) AS [datL309]
UNION ALL
SELECT
    'L3410' AS [ReportLineId]
  , 'Casino Profit' AS [ReportLineItem]
  , [datL3410].[CostCenterDesc]
  , [datL3410].[CostCenter_SK]
  , [datL3410].[LedgerAccountName]
  , [datL3410].[LedgerAccount_SK]
  , [datL3410].[CategoryDesc]
  , [datL3410].[Category_SK]
  , [datL3410].[ReportLineGroupId]
  , [datL3410].[signFactor]
  , CAST(1 AS DECIMAL(10, 5)) AS [constFactor]
FROM( SELECT
          [CostCenterDesc]
        , [CostCenter_SK]
        , [LedgerAccountName]
        , [LedgerAccount_SK]
        , [CategoryDesc]
        , [Category_SK]
        , [ReportLineGroupId]
        , [signFactor]
      FROM [#ReportLineBaseGroupMapping]
      WHERE [ReportLineId] = 'L2120'
      UNION ALL
      SELECT
          [CostCenterDesc]
        , [CostCenter_SK]
        , [LedgerAccountName]
        , [LedgerAccount_SK]
        , [CategoryDesc]
        , [Category_SK]
        , [ReportLineGroupId]
        , [signFactor]
      FROM [#ReportLineBaseGroupMapping]
      WHERE [ReportLineId] = 'L627' ) AS [datL3410]
UNION ALL
SELECT
    [LineItem].[ReportLineId]
  , [LineItem].[ReportLineItem]
  , [datL3410].[CostCenterDesc]
  , [datL3410].[CostCenter_SK]
  , [datL3410].[LedgerAccountName]
  , [datL3410].[LedgerAccount_SK]
  , [datL3410].[CategoryDesc]
  , [datL3410].[Category_SK]
  , [datL3410].[ReportLineGroupId]
  , [datL3410].[signFactor]
  , CAST(1 AS DECIMAL(10, 5)) AS [constFactor]
FROM( SELECT
          [CostCenterDesc]
        , [CostCenter_SK]
        , [LedgerAccountName]
        , [LedgerAccount_SK]
        , [CategoryDesc]
        , [Category_SK]
        , [ReportLineGroupId]
        , [signFactor]
      FROM [#ReportLineBaseGroupMapping]
      WHERE [ReportLineId] = 'L2120'
      UNION ALL
      SELECT
          [CostCenterDesc]
        , [CostCenter_SK]
        , [LedgerAccountName]
        , [LedgerAccount_SK]
        , [CategoryDesc]
        , [Category_SK]
        , [ReportLineGroupId]
        , [signFactor]
      FROM [#ReportLineBaseGroupMapping]
      WHERE [ReportLineId] = 'L627' ) AS [datL3410]
CROSS JOIN( SELECT [ReportLineId], [ReportLineItem] FROM [#ReportLineMapping] WHERE [ReportLineId] IN ('L529', 'L351', 'L500', 'L508', 'L517', 'L520'
                                                                                                                 , 'L617')) AS [LineItem]
UNION ALL
SELECT
    'L202' AS [ReportLineId]
  , 'Other Room Revenue' AS [ReportLineItem]
  , [L202].[CostCenterDesc]
  , [L202].[CostCenter_SK]
  , [L202].[LedgerAccountName]
  , [L202].[LedgerAccount_SK]
  , [L202].[CategoryDesc]
  , [L202].[Category_SK]
  , [L202].[ReportLineGroupId]
  , [L202].[signFactor]
  , CAST(1 AS DECIMAL(10, 5)) AS [constFactor]
FROM( SELECT
          [CostCenterDesc]
        , [CostCenter_SK]
        , [LedgerAccountName]
        , [LedgerAccount_SK]
        , [CategoryDesc]
        , [Category_SK]
        , [ReportLineGroupId]
        , [signFactor]
        , CAST(1 AS DECIMAL(10, 5)) AS [constFactor]
      FROM [#ReportLineBaseGroupMapping]
      WHERE [ReportLineId] = 'L203'
      EXCEPT
      SELECT
          [CostCenterDesc]
        , [CostCenter_SK]
        , [LedgerAccountName]
        , [LedgerAccount_SK]
        , [CategoryDesc]
        , [Category_SK]
        , [ReportLineGroupId]
        , [signFactor]
        , CAST(1 AS DECIMAL(10, 5)) AS [constFactor]
      FROM [#ReportLineBaseGroupMapping]
      WHERE [ReportLineId] IN ('L121', 'L122', 'L201', 'L2010')) AS [L202]
UNION ALL
SELECT
    'L320' AS [ReportLineId]
  , 'Telecommunications Other Expenses' AS [ReportLineItem]
  , [datL320].[CostCenterDesc]
  , [datL320].[CostCenter_SK]
  , [datL320].[LedgerAccountName]
  , [datL320].[LedgerAccount_SK]
  , [datL320].[CategoryDesc]
  , [datL320].[Category_SK]
  , [datL320].[ReportLineGroupId]
  , [datL320].[signFactor]
  , CAST(1 AS DECIMAL(10, 5)) AS [constFactor]
FROM( SELECT
          [CostCenterDesc]
        , [CostCenter_SK]
        , [LedgerAccountName]
        , [LedgerAccount_SK]
        , [CategoryDesc]
        , [Category_SK]
        , [ReportLineGroupId]
        , [signFactor]
        , CAST(1 AS DECIMAL(10, 5)) AS [constFactor]
      FROM [#ReportLineBaseGroupMapping]
      WHERE [ReportLineId] = 'L318'
      EXCEPT
      SELECT
          [CostCenterDesc]
        , [CostCenter_SK]
        , [LedgerAccountName]
        , [LedgerAccount_SK]
        , [CategoryDesc]
        , [Category_SK]
        , [ReportLineGroupId]
        , [signFactor]
        , CAST(1 AS DECIMAL(10, 5)) AS [constFactor]
      FROM [#ReportLineBaseGroupMapping]
      WHERE [ReportLineId] = 'L6291' ) AS [datL320]
UNION ALL
SELECT
    'L324' AS [ReportLineId]
  , 'Retail Other Expenses' AS [ReportLineItem]
  , [datL324].[CostCenterDesc]
  , [datL324].[CostCenter_SK]
  , [datL324].[LedgerAccountName]
  , [datL324].[LedgerAccount_SK]
  , [datL324].[CategoryDesc]
  , [datL324].[Category_SK]
  , [datL324].[ReportLineGroupId]
  , [datL324].[signFactor]
  , CAST(1 AS DECIMAL(10, 5)) AS [constFactor]
FROM( SELECT
          [CostCenterDesc]
        , [CostCenter_SK]
        , [LedgerAccountName]
        , [LedgerAccount_SK]
        , [CategoryDesc]
        , [Category_SK]
        , [ReportLineGroupId]
        , [signFactor]
        , CAST(1 AS DECIMAL(10, 5)) AS [constFactor]
      FROM [#ReportLineBaseGroupMapping]
      WHERE [ReportLineId] = 'L322'
      EXCEPT
      SELECT
          [CostCenterDesc]
        , [CostCenter_SK]
        , [LedgerAccountName]
        , [LedgerAccount_SK]
        , [CategoryDesc]
        , [Category_SK]
        , [ReportLineGroupId]
        , [signFactor]
        , CAST(1 AS DECIMAL(10, 5)) AS [constFactor]
      FROM [#ReportLineBaseGroupMapping]
      WHERE [ReportLineId] = 'L6281' ) AS [datL324]
UNION ALL
SELECT
    'L328' AS [ReportLineId]
  , 'Spa Other Expenses' AS [ReportLineItem]
  , [datL328].[CostCenterDesc]
  , [datL328].[CostCenter_SK]
  , [datL328].[LedgerAccountName]
  , [datL328].[LedgerAccount_SK]
  , [datL328].[CategoryDesc]
  , [datL328].[Category_SK]
  , [datL328].[ReportLineGroupId]
  , [datL328].[signFactor]
  , CAST(1 AS DECIMAL(10, 5)) AS [constFactor]
FROM( SELECT
          [CostCenterDesc]
        , [CostCenter_SK]
        , [LedgerAccountName]
        , [LedgerAccount_SK]
        , [CategoryDesc]
        , [Category_SK]
        , [ReportLineGroupId]
        , [signFactor]
        , CAST(1 AS DECIMAL(10, 5)) AS [constFactor]
      FROM [#ReportLineBaseGroupMapping]
      WHERE [ReportLineId] = 'L326'
      EXCEPT
      SELECT
          [CostCenterDesc]
        , [CostCenter_SK]
        , [LedgerAccountName]
        , [LedgerAccount_SK]
        , [CategoryDesc]
        , [Category_SK]
        , [ReportLineGroupId]
        , [signFactor]
        , CAST(1 AS DECIMAL(10, 5)) AS [constFactor]
      FROM [#ReportLineBaseGroupMapping]
      WHERE [ReportLineId] = 'L6311' ) AS [datL328]
UNION ALL
SELECT
    'L332' AS [ReportLineId]
  , 'Membership Other Expenses' AS [ReportLineItem]
  , [datL332].[CostCenterDesc]
  , [datL332].[CostCenter_SK]
  , [datL332].[LedgerAccountName]
  , [datL332].[LedgerAccount_SK]
  , [datL332].[CategoryDesc]
  , [datL332].[Category_SK]
  , [datL332].[ReportLineGroupId]
  , [datL332].[signFactor]
  , CAST(1 AS DECIMAL(10, 5)) AS [constFactor]
FROM( SELECT
          [CostCenterDesc]
        , [CostCenter_SK]
        , [LedgerAccountName]
        , [LedgerAccount_SK]
        , [CategoryDesc]
        , [Category_SK]
        , [ReportLineGroupId]
        , [signFactor]
        , CAST(1 AS DECIMAL(10, 5)) AS [constFactor]
      FROM [#ReportLineBaseGroupMapping]
      WHERE [ReportLineId] = 'L330'
      EXCEPT
      SELECT
          [CostCenterDesc]
        , [CostCenter_SK]
        , [LedgerAccountName]
        , [LedgerAccount_SK]
        , [CategoryDesc]
        , [Category_SK]
        , [ReportLineGroupId]
        , [signFactor]
        , CAST(1 AS DECIMAL(10, 5)) AS [constFactor]
      FROM [#ReportLineBaseGroupMapping]
      WHERE [ReportLineId] = 'L6331' ) AS [datL332]
UNION ALL
SELECT
    'L336' AS [ReportLineId]
  , 'Recreation Other Expenses' AS [ReportLineItem]
  , [datL336].[CostCenterDesc]
  , [datL336].[CostCenter_SK]
  , [datL336].[LedgerAccountName]
  , [datL336].[LedgerAccount_SK]
  , [datL336].[CategoryDesc]
  , [datL336].[Category_SK]
  , [datL336].[ReportLineGroupId]
  , [datL336].[signFactor]
  , CAST(1 AS DECIMAL(10, 5)) AS [constFactor]
FROM( SELECT
          [CostCenterDesc]
        , [CostCenter_SK]
        , [LedgerAccountName]
        , [LedgerAccount_SK]
        , [CategoryDesc]
        , [Category_SK]
        , [ReportLineGroupId]
        , [signFactor]
        , CAST(1 AS DECIMAL(10, 5)) AS [constFactor]
      FROM [#ReportLineBaseGroupMapping]
      WHERE [ReportLineId] = 'L334'
      EXCEPT
      SELECT
          [CostCenterDesc]
        , [CostCenter_SK]
        , [LedgerAccountName]
        , [LedgerAccount_SK]
        , [CategoryDesc]
        , [Category_SK]
        , [ReportLineGroupId]
        , [signFactor]
        , CAST(1 AS DECIMAL(10, 5)) AS [constFactor]
      FROM [#ReportLineBaseGroupMapping]
      WHERE [ReportLineId] = 'L6321' ) AS [datL336]
UNION ALL
SELECT
    'L3410001' AS [ReportLineId]
  , 'Casino Other Expenses' AS [ReportLineItem]
  , [datL3410001].[CostCenterDesc]
  , [datL3410001].[CostCenter_SK]
  , [datL3410001].[LedgerAccountName]
  , [datL3410001].[LedgerAccount_SK]
  , [datL3410001].[CategoryDesc]
  , [datL3410001].[Category_SK]
  , [datL3410001].[ReportLineGroupId]
  , [datL3410001].[signFactor]
  , CAST(1 AS DECIMAL(10, 5)) AS [constFactor]
FROM( SELECT
          [CostCenterDesc]
        , [CostCenter_SK]
        , [LedgerAccountName]
        , [LedgerAccount_SK]
        , [CategoryDesc]
        , [Category_SK]
        , [ReportLineGroupId]
        , [signFactor]
        , CAST(1 AS DECIMAL(10, 5)) AS [constFactor]
      FROM [#ReportLineBaseGroupMapping]
      WHERE [ReportLineId] = 'L34100'
      EXCEPT
      SELECT
          [CostCenterDesc]
        , [CostCenter_SK]
        , [LedgerAccountName]
        , [LedgerAccount_SK]
        , [CategoryDesc]
        , [Category_SK]
        , [ReportLineGroupId]
        , [signFactor]
        , CAST(1 AS DECIMAL(10, 5)) AS [constFactor]
      FROM [#ReportLineBaseGroupMapping]
      WHERE [ReportLineId] = 'L6371' ) AS [datL3410001]
UNION ALL
SELECT
    'L34102' AS [ReportLineId]
  , 'Golf Other Expenses' AS [ReportLineItem]
  , [datL34102].[CostCenterDesc]
  , [datL34102].[CostCenter_SK]
  , [datL34102].[LedgerAccountName]
  , [datL34102].[LedgerAccount_SK]
  , [datL34102].[CategoryDesc]
  , [datL34102].[Category_SK]
  , [datL34102].[ReportLineGroupId]
  , [datL34102].[signFactor]
  , CAST(1 AS DECIMAL(10, 5)) AS [constFactor]
FROM( SELECT
          [CostCenterDesc]
        , [CostCenter_SK]
        , [LedgerAccountName]
        , [LedgerAccount_SK]
        , [CategoryDesc]
        , [Category_SK]
        , [ReportLineGroupId]
        , [signFactor]
        , CAST(1 AS DECIMAL(10, 5)) AS [constFactor]
      FROM [#ReportLineBaseGroupMapping]
      WHERE [ReportLineId] = 'L34101'
      EXCEPT
      SELECT
          [CostCenterDesc]
        , [CostCenter_SK]
        , [LedgerAccountName]
        , [LedgerAccount_SK]
        , [CategoryDesc]
        , [Category_SK]
        , [ReportLineGroupId]
        , [signFactor]
        , CAST(1 AS DECIMAL(10, 5)) AS [constFactor]
      FROM [#ReportLineBaseGroupMapping]
      WHERE [ReportLineId] = 'L6341' ) AS [datL34102]
UNION ALL
SELECT
    'L34112' AS [ReportLineId]
  , 'Tennis Other Expenses' AS [ReportLineItem]
  , [datL34112].[CostCenterDesc]
  , [datL34112].[CostCenter_SK]
  , [datL34112].[LedgerAccountName]
  , [datL34112].[LedgerAccount_SK]
  , [datL34112].[CategoryDesc]
  , [datL34112].[Category_SK]
  , [datL34112].[ReportLineGroupId]
  , [datL34112].[signFactor]
  , CAST(1 AS DECIMAL(10, 5)) AS [constFactor]
FROM( SELECT
          [CostCenterDesc]
        , [CostCenter_SK]
        , [LedgerAccountName]
        , [LedgerAccount_SK]
        , [CategoryDesc]
        , [Category_SK]
        , [ReportLineGroupId]
        , [signFactor]
        , CAST(1 AS DECIMAL(10, 5)) AS [constFactor]
      FROM [#ReportLineBaseGroupMapping]
      WHERE [ReportLineId] = 'L34111'
      EXCEPT
      SELECT
          [CostCenterDesc]
        , [CostCenter_SK]
        , [LedgerAccountName]
        , [LedgerAccount_SK]
        , [CategoryDesc]
        , [Category_SK]
        , [ReportLineGroupId]
        , [signFactor]
        , CAST(1 AS DECIMAL(10, 5)) AS [constFactor]
      FROM [#ReportLineBaseGroupMapping]
      WHERE [ReportLineId] = 'L63472' ) AS [datL34112]
UNION ALL
SELECT
    'L341202' AS [ReportLineId]
  , 'Marina Other Expenses' AS [ReportLineItem]
  , [datL341202].[CostCenterDesc]
  , [datL341202].[CostCenter_SK]
  , [datL341202].[LedgerAccountName]
  , [datL341202].[LedgerAccount_SK]
  , [datL341202].[CategoryDesc]
  , [datL341202].[Category_SK]
  , [datL341202].[ReportLineGroupId]
  , [datL341202].[signFactor]
  , CAST(1 AS DECIMAL(10, 5)) AS [constFactor]
FROM( SELECT
          [CostCenterDesc]
        , [CostCenter_SK]
        , [LedgerAccountName]
        , [LedgerAccount_SK]
        , [CategoryDesc]
        , [Category_SK]
        , [ReportLineGroupId]
        , [signFactor]
        , CAST(1 AS DECIMAL(10, 5)) AS [constFactor]
      FROM [#ReportLineBaseGroupMapping]
      WHERE [ReportLineId] = 'L341201'
      EXCEPT
      SELECT
          [CostCenterDesc]
        , [CostCenter_SK]
        , [LedgerAccountName]
        , [LedgerAccount_SK]
        , [CategoryDesc]
        , [Category_SK]
        , [ReportLineGroupId]
        , [signFactor]
        , CAST(1 AS DECIMAL(10, 5)) AS [constFactor]
      FROM [#ReportLineBaseGroupMapping]
      WHERE [ReportLineId] = 'L6351' ) AS [datL341202]
UNION ALL
SELECT
    'L34142' AS [ReportLineId]
  , 'Business Center Other Expenses' AS [ReportLineItem]
  , [datL34142].[CostCenterDesc]
  , [datL34142].[CostCenter_SK]
  , [datL34142].[LedgerAccountName]
  , [datL34142].[LedgerAccount_SK]
  , [datL34142].[CategoryDesc]
  , [datL34142].[Category_SK]
  , [datL34142].[ReportLineGroupId]
  , [datL34142].[signFactor]
  , CAST(1 AS DECIMAL(10, 5)) AS [constFactor]
FROM( SELECT
          [CostCenterDesc]
        , [CostCenter_SK]
        , [LedgerAccountName]
        , [LedgerAccount_SK]
        , [CategoryDesc]
        , [Category_SK]
        , [ReportLineGroupId]
        , [signFactor]
        , CAST(1 AS DECIMAL(10, 5)) AS [constFactor]
      FROM [#ReportLineBaseGroupMapping]
      WHERE [ReportLineId] = 'L34141'
      EXCEPT
      SELECT
          [CostCenterDesc]
        , [CostCenter_SK]
        , [LedgerAccountName]
        , [LedgerAccount_SK]
        , [CategoryDesc]
        , [Category_SK]
        , [ReportLineGroupId]
        , [signFactor]
        , CAST(1 AS DECIMAL(10, 5)) AS [constFactor]
      FROM [#ReportLineBaseGroupMapping]
      WHERE [ReportLineId] = 'L63482' ) AS [datL34142]
UNION ALL
SELECT
    'L341502' AS [ReportLineId]
  , 'Condo Rental Management Other Expenses' AS [ReportLineItem]
  , [datL341502].[CostCenterDesc]
  , [datL341502].[CostCenter_SK]
  , [datL341502].[LedgerAccountName]
  , [datL341502].[LedgerAccount_SK]
  , [datL341502].[CategoryDesc]
  , [datL341502].[Category_SK]
  , [datL341502].[ReportLineGroupId]
  , [datL341502].[signFactor]
  , CAST(1 AS DECIMAL(10, 5)) AS [constFactor]
FROM( SELECT
          [CostCenterDesc]
        , [CostCenter_SK]
        , [LedgerAccountName]
        , [LedgerAccount_SK]
        , [CategoryDesc]
        , [Category_SK]
        , [ReportLineGroupId]
        , [signFactor]
        , CAST(1 AS DECIMAL(10, 5)) AS [constFactor]
      FROM [#ReportLineBaseGroupMapping]
      WHERE [ReportLineId] = 'L341501'
      EXCEPT
      SELECT
          [CostCenterDesc]
        , [CostCenter_SK]
        , [LedgerAccountName]
        , [LedgerAccount_SK]
        , [CategoryDesc]
        , [Category_SK]
        , [ReportLineGroupId]
        , [signFactor]
        , CAST(1 AS DECIMAL(10, 5)) AS [constFactor]
      FROM [#ReportLineBaseGroupMapping]
      WHERE [ReportLineId] = 'L6361' ) AS [datL341502]
UNION ALL
SELECT
    'L354' AS [ReportLineId]
  , 'Administrative & General Other Expenses' AS [ReportLineItem]
  , [datL354].[CostCenterDesc]
  , [datL354].[CostCenter_SK]
  , [datL354].[LedgerAccountName]
  , [datL354].[LedgerAccount_SK]
  , [datL354].[CategoryDesc]
  , [datL354].[Category_SK]
  , [datL354].[ReportLineGroupId]
  , [datL354].[signFactor]
  , CAST(1 AS DECIMAL(10, 5)) AS [constFactor]
FROM( SELECT
          [CostCenterDesc]
        , [CostCenter_SK]
        , [LedgerAccountName]
        , [LedgerAccount_SK]
        , [CategoryDesc]
        , [Category_SK]
        , [ReportLineGroupId]
        , [signFactor]
        , CAST(1 AS DECIMAL(10, 5)) AS [constFactor]
      FROM [#ReportLineBaseGroupMapping]
      WHERE [ReportLineId] = 'L353'
      EXCEPT
      SELECT
          [CostCenterDesc]
        , [CostCenter_SK]
        , [LedgerAccountName]
        , [LedgerAccount_SK]
        , [CategoryDesc]
        , [Category_SK]
        , [ReportLineGroupId]
        , [signFactor]
        , CAST(1 AS DECIMAL(10, 5)) AS [constFactor]
      FROM [#ReportLineBaseGroupMapping]
      WHERE [ReportLineId] = 'L6381' ) AS [datL354]
UNION ALL
SELECT
    'L4092' AS [ReportLineId]
  , 'Sales & Marketing Other Expenses' AS [ReportLineItem]
  , [datL4092].[CostCenterDesc]
  , [datL4092].[CostCenter_SK]
  , [datL4092].[LedgerAccountName]
  , [datL4092].[LedgerAccount_SK]
  , [datL4092].[CategoryDesc]
  , [datL4092].[Category_SK]
  , [datL4092].[ReportLineGroupId]
  , [datL4092].[signFactor]
  , CAST(1 AS DECIMAL(10, 5)) AS [constFactor]
FROM( SELECT
          [CostCenterDesc]
        , [CostCenter_SK]
        , [LedgerAccountName]
        , [LedgerAccount_SK]
        , [CategoryDesc]
        , [Category_SK]
        , [ReportLineGroupId]
        , [signFactor]
        , CAST(1 AS DECIMAL(10, 5)) AS [constFactor]
      FROM [#ReportLineBaseGroupMapping]
      WHERE [ReportLineId] = 'L4091'
      EXCEPT
      SELECT
          [CostCenterDesc]
        , [CostCenter_SK]
        , [LedgerAccountName]
        , [LedgerAccount_SK]
        , [CategoryDesc]
        , [Category_SK]
        , [ReportLineGroupId]
        , [signFactor]
        , CAST(1 AS DECIMAL(10, 5)) AS [constFactor]
      FROM [#ReportLineBaseGroupMapping]
      WHERE [ReportLineId] = 'L6401' ) AS [datL4092]
UNION ALL
SELECT
    'L4183' AS [ReportLineId]
  , 'Repairs & Maintenance Other Expenses' AS [ReportLineItem]
  , [datL4183].[CostCenterDesc]
  , [datL4183].[CostCenter_SK]
  , [datL4183].[LedgerAccountName]
  , [datL4183].[LedgerAccount_SK]
  , [datL4183].[CategoryDesc]
  , [datL4183].[Category_SK]
  , [datL4183].[ReportLineGroupId]
  , [datL4183].[signFactor]
  , CAST(1 AS DECIMAL(10, 5)) AS [constFactor]
FROM( SELECT
          [CostCenterDesc]
        , [CostCenter_SK]
        , [LedgerAccountName]
        , [LedgerAccount_SK]
        , [CategoryDesc]
        , [Category_SK]
        , [ReportLineGroupId]
        , [signFactor]
        , CAST(1 AS DECIMAL(10, 5)) AS [constFactor]
      FROM [#ReportLineBaseGroupMapping]
      WHERE [ReportLineId] = 'L4182'
      EXCEPT
      SELECT
          [CostCenterDesc]
        , [CostCenter_SK]
        , [LedgerAccountName]
        , [LedgerAccount_SK]
        , [CategoryDesc]
        , [Category_SK]
        , [ReportLineGroupId]
        , [signFactor]
        , CAST(1 AS DECIMAL(10, 5)) AS [constFactor]
      FROM [#ReportLineBaseGroupMapping]
      WHERE [ReportLineId] = 'L6411' ) AS [datL4183]
	  OPTION(LABEL = '[RCS_DW].[v_ReportLineCalcGroupMapping_GVAROL]')
--1:05
--00:48
--(84654 rows affected)

GO
/*
select count_BIG(*) as cnt from [RCS_DW].[v_ReportLineCalcGroupMapping]

-- 84654
-- 14:52

CREATE TABLE [#ReportLineCalcGroupMapping_GVAROL]
WITH
(
 DISTRIBUTION = ROUND_ROBIN
)
as
select * From [RCS_DW].[v_ReportLineCalcGroupMapping]

-- 14:03
*/
