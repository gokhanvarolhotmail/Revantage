USE [Revantage] ;
GO
DECLARE @SQL VARCHAR(MAX) ;

SELECT @SQL = [Util].[FS].[ReadAllTextFromFile]('C:\Temp\ALL_DDL.txt') ;

SET @SQL = REPLACE(@SQL, CHAR(13) + CHAR(10), CHAR(10)) ;

DROP TABLE IF EXISTS [#temp] ;
DROP TABLE IF EXISTS [#temp2] ;

SELECT
    [FieldNum]
  , TRIM([Field]) AS [Field]
INTO [#temp]
FROM [Util].[dbo].ParseDelimited(@SQL, CHAR(10)) ;

SELECT
    CAST([tn].[C1] AS NVARCHAR(128)) AS [DatabaseName]
  , CAST([tn].[C2] AS NVARCHAR(128)) AS [TableName]
  , ROW_NUMBER() OVER ( PARTITION BY [tn].[C1], [tn].[C2] ORDER BY [t3].[FieldNum] ) AS [ColumnId]
  , CAST([cn].[C1] AS NVARCHAR(128)) AS [ColumnName]
  , CAST([cn].[C2] AS NVARCHAR(128)) AS [DataType]
INTO [#temp2]
FROM [#temp] AS [t]
CROSS APPLY( SELECT TOP( 1 )* FROM [#temp] AS [t2] WHERE [t2].[FieldNum] > [t].[FieldNum] AND RIGHT([t2].[Field], 1) = ')' ORDER BY [t2].[FieldNum] ASC ) AS [t2]
CROSS APPLY( SELECT * FROM [#temp] AS [t3] WHERE [t3].[FieldNum] > [t].[FieldNum] AND [t3].[FieldNum] <= [t2].[FieldNum] ) AS [t3]
CROSS APPLY [Util].[dbo].ParseDelimitedColumns32(REPLACE(REPLACE([t].[Field], 'CREATE TABLE `', ''), '` (', ''), '`.`') AS [tn]
CROSS APPLY [Util].[dbo].ParseDelimitedColumns32(SUBSTRING([t3].[Field], 2, LEN([t3].[Field]) - 2), '` ') AS [cn]
WHERE [t].[Field] LIKE 'CREATE TABLE %' ;
GO
DROP TABLE IF EXISTS [dbo].[Views] ;
GO
SELECT
    [k].[DatabaseName]
  , [k].[ViewName]
  , CONCAT(CAST(NULL AS NVARCHAR(MAX)), 'CREATE OR ALTER VIEW ', QUOTENAME([k].[DatabaseName]), '.', QUOTENAME([k].[ViewName]), '
', STRING_AGG([k].[Field], '
')WITHIN GROUP(ORDER BY [k].[FieldNum])) AS [Definition]
INTO [dbo].[Views]
FROM( SELECT
          CAST([tn].[C1] AS NVARCHAR(128)) AS [DatabaseName]
        , CAST([tn].[C2] AS NVARCHAR(128)) AS [ViewName]
        , [t5].[FieldNum]
        , [t5].[Field]
      FROM [#temp] AS [t]
      CROSS APPLY( SELECT TOP( 1 )* FROM [#temp] AS [t3] WHERE [t3].[FieldNum] > [t].[FieldNum] AND [t3].[Field] LIKE '--------------------------%' ORDER BY [t3].[FieldNum] ) AS [t3]
      CROSS APPLY( SELECT TOP( 1 )* FROM [#temp] AS [t4] WHERE [t4].[FieldNum] > [t].[FieldNum] AND [t4].[Field] LIKE 'AS %' ORDER BY [t4].[FieldNum] ) AS [t4]
      CROSS APPLY( SELECT * FROM [#temp] AS [t5] WHERE [t5].[FieldNum] >= [t4].[FieldNum] AND [t5].[FieldNum] < [t3].[FieldNum] ) AS [t5]
      CROSS APPLY [Util].[dbo].ParseDelimitedColumns32(REPLACE(REPLACE([t].[Field], 'CREATE VIEW `', ''), '` (', ''), '`.`') AS [tn]
      WHERE [t].[Field] LIKE 'CREATE VIEW %' ) AS [k]
GROUP BY [k].[DatabaseName]
       , [k].[ViewName] ;
GO
CREATE UNIQUE CLUSTERED INDEX [name] ON [dbo].[views]( [DatabaseName], [ViewName] ) ;
GO
ALTER TABLE [dbo].[Views]
ADD
    [FQN] AS QUOTENAME([DatabaseName]) + '.' + QUOTENAME([ViewName])
  , [SQL] AS [Definition] + '
GO
'
  , [ObjectId] AS OBJECT_ID(QUOTENAME([DatabaseName]) + '.' + QUOTENAME([ViewName])) ;
GO
DROP TABLE IF EXISTS [dbo].[Tables] ;
GO
SELECT
    [DatabaseName]
  , [TableName]
  , COUNT(1) AS [ColumnCount]
INTO [dbo].[Tables]
FROM [#temp2]
GROUP BY [DatabaseName]
       , [TableName] ;
GO
CREATE UNIQUE CLUSTERED INDEX [name] ON [dbo].[Tables]( [DatabaseName], [TableName] ) ;
GO
ALTER TABLE [dbo].[Tables] ADD [FQN] AS QUOTENAME([DatabaseName]) + '.' + QUOTENAME([TableName]), [ObjectId] AS
                                                                                                  OBJECT_ID(
                                                                                                  QUOTENAME([DatabaseName]) + '.' + QUOTENAME([TableName])) ;
GO
DROP TABLE IF EXISTS [dbo].[Columns] ;

SELECT *
INTO [dbo].[Columns]
FROM [#temp2] ;
GO
CREATE UNIQUE CLUSTERED INDEX [name] ON [dbo].[Columns]( [DatabaseName], [TableName], [ColumnId] ) ;
GO
CREATE UNIQUE NONCLUSTERED INDEX [coln] ON [dbo].[Columns]( [DatabaseName], [TableName], [ColumnName] ) ;
GO

ALTER TABLE [dbo].[Columns]
ADD
    [FQN] AS QUOTENAME([DatabaseName]) + '.' + QUOTENAME([TableName])
  , [SQLDataType] AS CASE WHEN [DataType] LIKE 'decimal%' THEN [DataType]
                         WHEN [DataType] IN ('INT', 'BIGINT', 'FLOAT', 'DATE') THEN [DataType]
                         WHEN [DataType] = 'binary' THEN 'VARBINARY(4000)'
                         WHEN [DataType] = 'STRING' THEN 'NVARCHAR(4000)'
                         WHEN [DataType] = 'DOUBLE' THEN 'REAL'
                         WHEN [DataType] = 'TIMESTAMP' THEN 'DATETIME2(7)'
                         WHEN [DataType] = 'BOOLEAN' THEN 'BIT'
                         WHEN [DataType] LIKE 'ARRAY%' THEN 'NVARCHAR(MAX)'
                     END ;
GO

SELECT DISTINCT
       CONCAT('IF SCHEMA_ID(''', [f].[DatabaseName], ''') IS NULL EXEC(''CREATE SCHEMA ', QUOTENAME([f].[DatabaseName]), ''')
GO
')  AS [SchemaSQL]
FROM( SELECT [DatabaseName] FROM [dbo].[Tables] UNION ALL SELECT [DATABASENAME] FROM [dbo].[views] ) AS [f] ;
GO
SELECT
    [FQN]
  , [DatabaseName]
  , [TableName]
  , CONCAT(CAST(NULL AS NVARCHAR(MAX)), 'DROP TABLE IF EXISTS ', [FQN], '
GO
CREATE TABLE ', [FQN], ' (
', STRING_AGG(CONCAT(CAST(NULL AS NVARCHAR(MAX)), CHAR(9), QUOTENAME([ColumnName]), ' ', [sqldatatype]), ',
')WITHIN GROUP(ORDER BY [ColumnId]), '
)
GO
') AS [SQL]
FROM [dbo].[Columns]
GROUP BY [FQN]
       , [DatabaseName]
       , [TableName]
ORDER BY 1 ;
GO
SELECT *
FROM [dbo].[views] ;
GO
SELECT *
FROM [dbo].[Tables] ;
GO
