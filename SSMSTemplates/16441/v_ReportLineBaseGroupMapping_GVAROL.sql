USE [RCS_SqlDw] ;
GO
CREATE OR ALTER VIEW [RCS_DW].[v_ReportLineBaseGroupMapping_GVAROL]
AS
SELECT
    [map].[ReportLineId]
  , [map].[ReportLineItem]
  , [map].[CostCenterDesc]
  , [map].[CostCenter_SK]
  , [map].[LedgerAccountName]
  , [map].[LedgerAccount_SK]
  , [groupmap].[CategoryDesc]
  , [groupmap].[Category_SK]
  , CONCAT([map].[CostCenter_SK], '_', [map].[LedgerAccount_SK], '_', [groupmap].[Category_SK]) AS [ReportLineGroupId]
  , CAST(1 AS INT) AS [signFactor]
FROM( SELECT
          [rbm].[ReportLineId]
        , [rbm].[ReportLineItem]
        , [rb].[LedgerAccount_SK]
        , [la].[LedgerAccountName]
        , [cc].[CostCenter_SK]
        , [cc].[CostCenterDesc]
        , [rbm].[CategoryDescType]
        , [rbm].[CategoryDescNotInType]
      FROM [RCS_DW].[Report_Business_Mapping_Flattened_Rpt] AS [rb]
      INNER JOIN [RCS_DW].[v_Cost_Center_Dim] AS [cc] ON [rb].[CostCenter_SK] = [cc].[CostCenter_SK] OR [rb].[CostCenter_SK] = -9999
      INNER JOIN [RCS_DW].[v_Ledger_Account_Dim] AS [la] ON [la].[LedgerAccount_SK] = [rb].[LedgerAccount_SK]
      INNER JOIN [RCS_DW].[v_ReportLineMapping] AS [rbm] ON [rbm].[CategoryType] = [rb].[Category]
                                                        AND ( [rbm].[CostCenterType] IS NULL OR [rbm].[CostCenterType] = [rb].[CostCenterName] )
                                                        AND ( [rbm].[AccountType] IS NULL OR [rbm].[AccountType] = [la].[LedgerAccountName] )
                                                        AND ( [rbm].[CostCenterDescType] IS NULL OR [rbm].[CostCenterDescType] = [cc].[CostCenterDesc] )
                                                        AND ( [rbm].[CostCenterDescNotInType] IS NULL
                                                            OR [rbm].[CostCenterDescNotInType] != [cc].[CostCenterDesc] )
      WHERE [Meta__IsCurrent] = 1 ) AS [map]
INNER JOIN [RCS_DW].[v_ReportLineGroupMapping] AS [groupmap] ON [map].[LedgerAccount_SK] = [groupmap].[LedgerAccount_SK]
                                                            AND [map].[CostCenter_SK] = [groupmap].[CostCenter_SK]
                                                            AND ( [map].[CategoryDescType] IS NULL OR [map].[CategoryDescType] = [groupmap].[CategoryDesc] )
                                                            AND ( [map].[CategoryDescNotInType] IS NULL
                                                                OR [map].[CategoryDescNotInType] != [groupmap].[CategoryDesc] ) ;
GO

sp_text'[RCS_DW].[v_ReportLineGroupMapping]'