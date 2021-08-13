CREATE VIEW [RCS_DW].[v_Cost_Center_Dim]
AS SELECT  
      [CostCenter_SK]
      ,[CostCenter_AK]
      ,[CostCenterDesc]
  FROM 
         [RCS_DW].[Cost_Center_Dim]
  WHERE isCurrent = 1;
GO

CREATE VIEW [RCS_DW].[v_Ledger_Account_Dim]
AS SELECT  
      [LedgerAccount_SK]
      ,[LedgerAccount_AK]
      ,[LedgerAccountID]
      ,[LedgerAccountName]
      ,[LedgerAccountSet]
  FROM 
         [RCS_DW].[Ledger_Account_Dim]
  WHERE isCurrent = 1;
GO
CREATE VIEW [RCS_DW].[v_ReportLineMapping] AS SELECT [CategoryType]
      ,[CostCenterType]
      ,[AccountType]
      ,[CostCenterDescType]
      ,[CategoryDescType]
      ,[CostCenterDescNotInType]
      ,[CategoryDescNotInType]
      ,[ReportLineId]
      ,[ReportLineItem]
      ,[ReportLineJSON]
      ,[ReportSection]
      ,[ReportSubSection]
      ,[IsExpandable]
      ,[Include]
      ,[IsCalc]
      ,[IsRevenue]
      ,[signFactor]
      ,[calcOperator]
      ,[IsFlowCalc]
      ,[constantFactor]
      ,[FormulaLineId]
      ,[CalcReportLineId1]
      ,[CalcReportLineId2]
      ,[CalcReportLineIdType1]
      ,[CalcReportLineIdType2]
      ,[PercentRevenueType]
      ,[PercentRevenueDenominator]
      ,[VarianceType]
      ,[PercentChangeType]
      ,[FormatString]
      ,[FormatStringPercentRevenue]
      ,[FormatStringVariance]
      ,[FormatStringPercentChange]
      ,[BackgroundColor]
      ,[FontColor]
      ,[sortOrder]
	  ,[IsReportItem]
	  ,[IncludeInReport]
  FROM [RCS_DW].[ReportLineMapping]
  WHERE [IsReportItem] = 1;
GO
CREATE VIEW [RCS_DW].[v_ReportLineGroupMapping]
AS SELECT DISTINCT
      fact.[CostCenter_SK], 
	  cc.[CostCenterDesc],
      fact.[LedgerAccount_SK], 
	  la.[LedgerAccountName],
	  fact.[Category_SK], 
	  cat.[CategoryDesc],
      [ReportLineGroupId]
  FROM [RCS_DW].[v_GL_Monthly_Balance_Activity_Fact] fact
  INNER JOIN 
[RCS_DW].[v_Cost_Center_Dim] cc
ON cc.CostCenter_SK = fact.CostCenter_SK 
INNER JOIN 
[RCS_DW].[v_Ledger_Account_Dim] la
ON la.[LedgerAccount_SK] = fact.[LedgerAccount_SK]
INNER JOIN 
[RCS_DW].[v_Category_Dim] cat
ON cat.[Category_SK] = fact.[Category_SK];
GO
