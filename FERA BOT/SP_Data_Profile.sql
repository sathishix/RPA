-- =======================================================
-- Create Stored Procedure Template for Azure SQL Database
-- =======================================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      <Author, , Name>
-- Create Date: <Create Date, , >
-- Description: <Description, , >
-- =============================================
alter PROCEDURE Data_Profile
    -- Add the parameters for the stored procedure here
   @IntableName NVARCHAR(255) --,@FirstResult NVARCHAR(MAX) OUT

AS
DECLARE @DatabaseName NVARCHAR(255) = 'Sample_ADV_WRK'
DECLARE @SchemaName NVARCHAR(255) = 'dbo'
DECLARE @TableName NVARCHAR(255) = @IntableName

BEGIN

SET NOCOUNT ON

-- Declare the parameters internal to query
DECLARE @SQLString NVARCHAR(MAX) = ''
DECLARE @ParamDefinition NVARCHAR(MAX) = ''

DECLARE @ColumnList TABLE (
ColumnId INT IDENTITY(1,1)
, ColumnName NVARCHAR(255)
, ColumnNullCount INT
, ColumnNullPercentage NUMERIC(10,4)
, ColumnUniqueCount INT
, ColumnMaxValue NVarchar(255)
, ColumnMinValue NVarchar(255)
)

DECLARE @TableRecordCount INT
DECLARE @ColumnNullCount INT
DECLARE @ColumnCount INT = 0

DECLARE @ColumnUniqueCount INT=0
DECLARE @ColumnMaxValue NVarchar(255)
DECLARE @ColumnMinValue NVarchar(255)

DECLARE @LoopCounter INT = 1
DECLARE @ColumnName NVARCHAR(255)

SET @SQLString = 
'SELECT @TableRecordCount = COUNT(*) FROM '
+ @DatabaseName + '.' + @SchemaName + '.' + @TableName
SET @ParamDefinition = '@TableRecordCount INT OUTPUT'
EXECUTE sp_executesql @SQLString, @ParamDefinition
, @TableRecordCount OUTPUT


SET @SQLString = 
'SELECT COLUMN_NAME FROM '
+ @DatabaseName + '.' + 'INFORMATION_SCHEMA.COLUMNS
WHERE 
TABLE_SCHEMA = @SchemaName
AND TABLE_NAME = @TableName'

SET @ParamDefinition = '@SchemaName NVARCHAR(255), @TableName NVARCHAR(255)'

INSERT INTO @ColumnList (ColumnName)
EXECUTE sp_executesql @SQLString, @ParamDefinition
, @SchemaName, @TableName

SELECT @ColumnCount = COUNT(*) FROM @ColumnList

WHILE (@LoopCounter <= @ColumnCount)
BEGIN

SELECT @ColumnName = ColumnName 
FROM @ColumnList 
WHERE ColumnId = @LoopCounter

SET @SQLString = 
'SELECT @ColumnNullCount = COUNT(*) FROM '
+ @DatabaseName + '.' + @SchemaName + '.' + @TableName 
+ ' WHERE ' + @ColumnName + ' IS NULL'

SET @ParamDefinition = '@ColumnNullCount INT OUTPUT'

EXECUTE sp_executesql @SQLString, @ParamDefinition
, @ColumnNullCount OUTPUT

SET @SQLString = 
'SELECT @ColumnUniqueCount = COUNT(Distinct '+@ColumnName +') FROM '
+ @DatabaseName + '.' + @SchemaName + '.' + @TableName 

SET @ParamDefinition = '@ColumnUniqueCount INT OUTPUT'

EXECUTE sp_executesql @SQLString, @ParamDefinition
, @ColumnNullCount OUTPUT


SET @SQLString = 
'SELECT @ColumnMaxValue = MAX('+@ColumnName +') FROM '
+ @DatabaseName + '.' + @SchemaName + '.' + @TableName 

SET @ParamDefinition = '@ColumnMaxValue NVARCHAR(255) OUTPUT'

EXECUTE sp_executesql @SQLString, @ParamDefinition
, @ColumnMaxValue OUTPUT

SET @SQLString = 
'SELECT @ColumnMinValue = Min('+@ColumnName +') FROM '
+ @DatabaseName + '.' + @SchemaName + '.' + @TableName 

SET @ParamDefinition = '@ColumnMinValue NVARCHAR(255) OUTPUT'

EXECUTE sp_executesql @SQLString, @ParamDefinition
, @ColumnMinValue OUTPUT




UPDATE @ColumnList
SET 
ColumnNullCount = @ColumnNullCount
, ColumnNullPercentage = @ColumnNullCount * 100.0/@TableRecordCount
,ColumnUniqueCount=@ColumnUniqueCount
,ColumnMinValue=@ColumnMinValue
,ColumnMaxValue=@ColumnMaxValue
WHERE ColumnId = @LoopCounter

SET @LoopCounter += 1

END

SELECT 'Column Name','Record Count','Null Count','Null Percentage','Unique Count','Min Value','Max Value' union all  SELECT 
ColumnName AS [Column Name]
,Cast( @TableRecordCount as NVARCHAR(255)) AS [Table Record Count]
,Cast( ColumnNullCount as NVARCHAR(255))  AS [Column Null Count]
, CAST(ColumnNullPercentage AS NVARCHAR(20)) + ' %' AS [Column Null Percentage]
, Cast( ColumnUniqueCount as NVARCHAR(255)) as [Unique Count]
, ColumnMinValue as [Min Value]
, ColumnMaxValue as [Max Value]
FROM @ColumnList
 

END
GO
