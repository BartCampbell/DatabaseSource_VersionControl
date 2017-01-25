SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/*************************************************************************************
Procedure:	spExportDataToXLS
Author:		Leon Dowling
Copyright:	© 2013
Date:		2013.01.01
Purpose:	
Parameters:	
Depends On:	
Calls:		
Called By:	
Returns:	
Notes:		
Process:	
Test Script:	
ToDo:		
*************************************************************************************/


--/*
CREATE PROC [dbo].[spExportDataToXLS]
    (@dbName VARCHAR(100) = 'master',
     @sql VARCHAR(5000) = '',
     @fullFileName VARCHAR(1000) = '',
	 @bExec BIT = 1,
	 @bDebug BIT = 0
    )
AS
--*/ 
/*
DECLARE @dbName VARCHAR(100) = 'DHMP_Sandbox'
DECLARE @sql VARCHAR(5000) = 'SELECT * FROM FileExtr.REP001_SubscriberList'
DECLARE @fullFileName VARCHAR(1000) = '\\IMIFS02\IMI.FTP.Storage\IMI.External.Clients\DHMP.Filestore.FTP\Reports\REP001_SubscriberList\\REP001_SubLIst.xls'

DECLARE @bExec BIT = 1
DECLARE @bDebug BIT = 1
*/


IF @sql = ''
    OR @fullFileName = '' 
    BEGIN
        SELECT 0 AS ReturnValue -- failure
        RETURN
    END 
-- if DB isn't passed in set it to master
SELECT @dbName = 'use ' + @dbName + ';'
IF OBJECT_ID('tempdb..##TempExportData') IS NOT NULL 
    DROP TABLE ##TempExportData
IF OBJECT_ID('tempdb..##TempExportData2') IS NOT NULL 
    DROP TABLE ##TempExportData2
-- insert data into a global temp table
DECLARE @columnNames VARCHAR(8000),
    @columnConvert VARCHAR(8000),
    @tempSQL VARCHAR(8000),
    @ColInit VARCHAR(8000)
SELECT @tempSQL = LEFT(@sql,CHARINDEX('from',@sql) - 1)
        + ' into ##TempExportData ' + SUBSTRING(@sql,
                                                CHARINDEX('from',@sql) - 1,
                                                LEN(@sql))
EXEC(@dbName + @tempSQL)
IF @@error > 0 
    BEGIN
        SELECT 0 AS ReturnValue -- failure
        RETURN
    END 
-- build 2 lists
-- 1. column names
-- 2. columns converted to nvarchar
SELECT @columnNames = COALESCE(@columnNames + ',','') + column_name,
        @columnConvert = COALESCE(@columnConvert + ',','')
        + 'convert(nvarchar(4000),' + column_name
        + CASE WHEN data_type IN ('datetime','smalldatetime') THEN ',121'
               WHEN data_type IN ('numeric','decimal') THEN ',128'
               WHEN data_type IN ('float','real','money','smallmoney')
               THEN ',2'
               WHEN data_type IN ('datetime','smalldatetime') THEN ',120'
               ELSE ''
          END + ') as ' + column_name,
        @ColInit = COALESCE(@ColInit + ',' + CHAR(13),'')
        + 'convert(nvarchar(4000),NULL'
        + CASE WHEN data_type IN ('datetime','smalldatetime') THEN ',121'
               WHEN data_type IN ('numeric','decimal') THEN ',128'
               WHEN data_type IN ('float','real','money','smallmoney')
               THEN ',2'
               WHEN data_type IN ('datetime','smalldatetime') THEN ',120'
               ELSE ''
          END + ') as ' + column_name
    FROM tempdb.INFORMATION_SCHEMA.Columns
    WHERE table_name = '##TempExportData'
-- Create Table

SELECT @SQL = 'select top 0 ' + @colINit + ', '
        + ' [temp##RowID] = Identity(int,1,1) ' + CHAR(13)
        + ' into ##TempExportData2 ' + CHAR(13)
--		+ ' from (select '''+REPLACE(@columnNames, ',', ''', ''') +''') t '

IF @bDebug = 1 
    PRINT @sql
IF @bExec = 1 
    EXEC (@sql)

SELECT @sql = 'select ''' + REPLACE(@columnNames,',',''',''') + ''''

IF @bDebug = 1 
    PRINT @sql
IF @bExec = 1 
    INSERT INTO ##TempExportData2
            EXEC (@sql
                )

SELECT @sql = 'select  ' + @columnConvert + ' from ##TempExportData '
IF @bDebug = 1 
    PRINT @sql
IF @bExec = 1 
    INSERT INTO ##TempExportData2
            EXEC (@sql
                )

-- build full BCP query
SELECT @sql = 'bcp "' + @dbName + ' select ' + @columnNames
        + ' from ##TempExportData2 ORDER BY [temp##RowID]" queryout "'
        + @fullFileName + '" -c -CRAW -T'
-- execute BCP
IF @bDebug = 1 
    PRINT @sql
IF @bExec = 1 
    EXEC master..xp_cmdshell @sql

IF @@error > 0 
    BEGIN 
        SELECT 0 AS ReturnValue -- failure
        RETURN
    END

IF @bDebug = 0 
    BEGIN 
        DROP TABLE ##TempExportData
        DROP TABLE ##TempExportData2
    END
SELECT 1 AS ReturnValue -- success
/*
go
declare @sql varchar(6800),    @dbName varchar(100), @fullFileName varchar(100)
select    @dbName = 'northwind', @sql = 'select * from orders order by orderdate', @fullFileName = 'e:\test.xls'
exec    master..spExportData @dbName, @sql, @fullFileName 
*/

/*
SELECT @sql='select '+@columnNames+', ' 
		+ ' from (select '+@columnConvert+', ''2'' as [temp##SortID] from ##TempExportData '
		+ ' union all select '''+REPLACE(@columnNames, ',', ''', ''') +''', ''1'') t '
		+ ' order by [temp##SortID]'

*/
GO
GRANT VIEW DEFINITION ON  [dbo].[spExportDataToXLS] TO [db_ViewProcedures]
GO
