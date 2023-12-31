SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[uspAdmin_DetermineImportedTableCharacteristics] (@table varchar(510),@debug char(1)='N') AS

--DECLARE @debug		varchar(1)			SET @debug = 'Y' -- Set to Y to print statements
DECLARE @column		 varchar(255)
--DECLARE @columnid	 int
--DECLARE @compression varchar(5)
DECLARE @command1	 varchar(max)	SET @command1 = ''
DECLARE @command2	 varchar(max)	SET @command2 = ''
DECLARE @command3	 varchar(max)	SET @command3 = ''
DECLARE @command4	 varchar(max)	SET @command4 = ''
DECLARE @command5	 varchar(max)	SET @command5 = ''
DECLARE @command6	 varchar(max)	SET @command6 = ''
DECLARE @command7	 varchar(max)	SET @command7 = ''
DECLARE @command9	 varchar(max)	SET @command9 = ''
DECLARE @command11	 varchar(max)	SET @command11 = ''
DECLARE @command21	 varchar(max)	SET @command21 = ''
DECLARE @command31	 varchar(max)	SET @command31 = ''
DECLARE @command41	 varchar(max)	SET @command41 = ''
DECLARE @command51	 varchar(max)	SET @command51 = ''
DECLARE @command61	 varchar(max)	SET @command61 = ''
DECLARE @command71	 varchar(max)	SET @command71 = ''
DECLARE @command91	 varchar(max)	SET @command91 = ''

SET @command1 = 'SELECT 
 p.TableName
,x.ColumnName
,x.ColumnMeasure
,x.ColumnValue1
,ROUND(CAST(100.00 as float) * CAST(CASE 
									WHEN x.ColumnMeasure = ''Maximum length'' THEN NULL
									WHEN p.Records > 0 THEN CAST(x.ColumnValue1 as float) / CAST(p.Records as float) 
									ELSE 0.00 
									END as float),2) as PercentageOfRecords
,x.ColumnMin
,x.ColumnMax
FROM (-- p
SELECT '''+@table+''' as TableName,COUNT(*) as Records'

--- Declare column cusor
DECLARE cursor_column CURSOR FOR 
	select --TOP 3
	 sc.[name] 
	--,sc.column_id
	from sys.columns sc
	where object_name(object_id) = @table 
	ORDER BY sc.column_id

--- Open table cursor        
OPEN cursor_column 
        FETCH NEXT FROM cursor_column into @column--,@columnid
WHILE @@FETCH_STATUS = 0 
        BEGIN 

IF(@debug='Y')
BEGIN
PRINT @table + ' ' + @column 
END

SET @command2 = @command2 + '
,MAX(LEN([' + @column + '])) as [' + @column + '_MaxLEN]'
SET @command21 = @command21 + '
,(''' + @column + ''',''Maximum length'',ISNULL([' + @column + '_MaxLEN],0),CAST([' + @column + '_Min] as varchar(255)),CAST([' + @column + '_Max] as varchar(255)),2)'

SET @command3 = @command3 + '
,SUM(CASE WHEN ISNUMERIC([' + @column + ']/*+''e0''*/)=1 AND [' + @column + '] IS NOT NULL THEN 1 ELSE 0 END) as [' + @column + '_ISNUMERIC]'
SET @command31 = @command31 + '
,(''' + @column + ''',''Valid numbers'',[' + @column + '_ISNUMERIC],CAST([' + @column + '_Min] as varchar(255)),CAST([' + @column + '_Max] as varchar(255)),3)'

SET @command4 = @command4 + '
,SUM(CASE WHEN ISDATE([' + @column + '])=0 AND [' + @column + '] IS NOT NULL THEN 0 ELSE 1 END) as [' + @column + '_ISDATE]'
SET @command41 = @command41 + '
,(''' + @column + ''',''Valid dates'',[' + @column + '_ISDATE],CAST([' + @column + '_Min] as varchar(255)),CAST([' + @column + '_Max] as varchar(255)),4)'

SET @command5 = @command5 + '
,SUM(CASE WHEN LEN(ISNULL([' + @column + '],'''')) = 0 THEN 1 ELSE 0 END) as [' + @column + '_EMPTY]'
SET @command51 = @command51 + '
,(''' + @column + ''',''NULL fields'',[' + @column + '_EMPTY],CAST([' + @column + '_Min] as varchar(255)),CAST([' + @column + '_Max] as varchar(255)),5)'

--- NEED THESE (6&7) TO GO INTO A ColumnValue2 & 3 FIELD!

SET @command6 = @command6 + '
,MIN([' + @column + ']) as [' + @column + '_Min]'
SET @command61 = @command61 + '
,(''' + @column + ''',''Minimum value'',NULL,CAST([' + @column + '_Min] as varchar(255)),CAST([' + @column + '_Max] as varchar(255)),6)'

SET @command7 = @command7 + '
,MAX([' + @column + ']) as [' + @column + '_Max]'
SET @command71 = @command71 + '
,(''' + @column + ''',''Maximum value'',NULL,CAST([' + @column + '_Min] as varchar(255)),CAST([' + @column + '_Max] as varchar(255)),7)'

--- Loop table cursor
        FETCH NEXT FROM cursor_column INTO @column--,@columnid
END 
--- Close table cursor 
CLOSE cursor_column 
DEALLOCATE cursor_column 

SET @command9 = '
FROM [' + @table + ']
) as p'

SET @command11 = '
CROSS APPLY (VALUES(''' + @table + ''',''Record count'',p.[Records],NULL,NULL,1)'

SET @command91 = '
			) x (ColumnName,ColumnMeasure,ColumnValue1,ColumnMin,ColumnMax,ColumnPosition)
WHERE x.ColumnMeasure IS NOT NULL
ORDER BY x.ColumnName
,x.ColumnMeasure
'

IF(@debug='Y')
BEGIN
PRINT @command1
PRINT @command2
PRINT @command3
PRINT @command4
PRINT @command5
PRINT @command6
PRINT @command7
PRINT @command9
PRINT @command11
PRINT @command21
PRINT @command31
PRINT @command41
PRINT @command51
--PRINT @command61
--PRINT @command71
PRINT @command91
END

EXEC(@command1+@command2+@command3+@command4+@command5+@command6+@command7+@command9+@command11+@command21+@command31+@command41+@command51+@command91)
GO