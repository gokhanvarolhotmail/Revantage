USE [Revantage] ;
GO
DECLARE @SQL VARCHAR(MAX) ;

SELECT @SQL = [Util].[FS].[ReadAllTextFromFile]('c:\temp\ALL_DDL.txt') ;

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
CREATE UNIQUE CLUSTERED INDEX [name] ON [dbo].[tables]( [DatabaseName], [TableName] ) ;
GO
DROP TABLE IF EXISTS [dbo].[Columns] ;

SELECT *
INTO [dbo].[Columns]
FROM [#temp2] ;
GO
CREATE UNIQUE CLUSTERED INDEX [name] ON [dbo].[columns]( [DatabaseName], [TableName], [ColumnId] ) ;
GO
CREATE UNIQUE NONCLUSTERED INDEX [coln] ON [dbo].[columns]( [DatabaseName], [TableName], [ColumnName] ) ;
GO
