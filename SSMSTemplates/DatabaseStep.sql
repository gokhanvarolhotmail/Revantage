PRINT('Executing R21.11.00\07_uspPersistFinancialMappings.sql');

UPDATE [d]
SET [d].[ItemNameToExecute] = [d].[ItemNameToExecute] + ', 50~[RCS_DW].[uspPersistFinancialMappings]'
FROM [state_config].[DatabaseToStepCommand] AS [d]
WHERE [d].[DatabaseId] = 2
AND [d].[StepId] = 10
AND CHARINDEX(', 50~[RCS_DW].[uspPersistFinancialMappings]', [d].[ItemNameToExecute]) = 0 ;