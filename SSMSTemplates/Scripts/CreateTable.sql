SELECT CONCAT('IF SCHEMA_ID(''', [name], ''') IS NULL EXEC(''CREATE SCHEMA ', [name], ''')
GO
')  AS [SQL]
FROM [sys].[schemas] ;
GO
SELECT
    [k].[FQN]
  , CONCAT(
        CAST(NULL AS VARCHAR(MAX)), 'CREATE TABLE ', [k].[FQN], '(
', STRING_AGG(
       CONCAT(
           CAST(CHAR(9) AS VARCHAR(MAX)), QUOTENAME([k].[ColumnName]), ' ', [k].[ColumnType], ' '
           , CASE WHEN [k].[is_nullable] = 1 THEN 'NULL' ELSE 'NOT NULL' END), ',
')WITHIN GROUP(ORDER BY [k].[column_id]), '
)
GO
') AS [SQL]
FROM( SELECT
          QUOTENAME([s].[name]) + '.' + QUOTENAME([t].[name]) AS [FQN]
        , [c].[name] AS [ColumnName]
        , CAST(CASE WHEN [y].[name] = 'timestamp' THEN 'rowversion'
                   WHEN [y].[name] IN ('char', 'varchar') THEN
                       CONCAT(
                           [y].[name], '(', CASE WHEN [c].[max_length] = -1 THEN 'MAX' ELSE CAST([c].[max_length] AS VARCHAR)END, ')'
                         , CASE WHEN [c].[collation_name] <> [d].[collation_name] THEN CONCAT(' COLLATE ', [c].[collation_name])ELSE '' END)
                   WHEN [y].[name] IN ('nchar', 'nvarchar') THEN
                       CONCAT(
                           [y].[name], '(', CASE WHEN [c].[max_length] = -1 THEN 'MAX' ELSE CAST([c].[max_length] / 2 AS VARCHAR)END, ')'
                         , CASE WHEN [c].[collation_name] <> [d].[collation_name] THEN CONCAT(' COLLATE ', [c].[collation_name])ELSE '' END)
                   WHEN [y].[name] IN ('binary', 'varbinary') THEN
                       CONCAT([y].[name], '(', CASE WHEN [c].[max_length] = -1 THEN 'MAX' ELSE CAST([c].[max_length] AS VARCHAR)END, ')')
                   WHEN [y].[name] IN ('bigint', 'int', 'smallint', 'tinyint') THEN [y].[name]
                   WHEN [y].[name] IN ('datetime2', 'time', 'datetimeoffset') THEN CONCAT([y].[name], '(', [c].[scale], ')')
                   WHEN [y].[name] IN ('numeric', 'decimal') THEN CONCAT([y].[name], '(', [c].[precision], ', ', [c].[scale], ')')
                   ELSE [y].[name]
               END AS VARCHAR(256)) AS [ColumnType]
        , [c].[column_id]
        , [c].[is_nullable]
      FROM [sys].[schemas] AS [s]
      INNER JOIN [sys].[tables] AS [t] ON [s].[schema_id] = [t].[schema_id]
      INNER JOIN [sys].[columns] AS [c] ON [c].[object_id] = [t].[object_id]
      INNER JOIN [sys].[types] AS [y] ON [y].[user_type_id] = [c].[user_type_id]
      INNER JOIN [sys].[databases] AS [d] ON [d].[name] = DB_NAME()) AS [k]
GROUP BY [k].[FQN] ;
GO
