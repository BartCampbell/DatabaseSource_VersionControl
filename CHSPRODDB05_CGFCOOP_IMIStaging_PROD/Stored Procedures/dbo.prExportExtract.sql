SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



/*************************************************************************************
Procedure:	prExportExtract 
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

exec prExportExtract 
	@vcInputTab1 = 'FileExtr.DH18_HDX',
	@vcInputTab2 = NULL,
	@vcInputTab3 = NULL,
	@vcInputTab4 = NULL,
	@vcInputTab5 = NULL,

	@bOutputFileDelimted = 1,
	@vcFileDelimiter	= '|',

	@vcTargetPath 		= 'c:\ihds\',
	@vcTargetFileName 	= 'dh18_hdx.txt',
	@bTop10				= 0,
	@bDebug				= 1,
	@bExec				= 1,
	@bCreateOutFile		= 1

ToDo:		
*************************************************************************************/

CREATE PROC [dbo].[prExportExtract] 

@vcInputTab1 VARCHAR(100) ,
@vcInputTab2 VARCHAR(100) = NULL,
@vcInputTab3 VARCHAR(100)= NULL,
@vcInputTab4 VARCHAR(100)= NULL,
@vcInputTab5 VARCHAR(100)= NULL,

@bOutputFileDelimted BIT = 1 ,
@vcFileDelimiter VARCHAR(1) = '|',

@vcTargetPath VARCHAR(200)	,
@vcTargetFileName VARCHAR(200)	,
@bTop10 BIT = 0,
@bDebug BIT = 0,
@bExec BIT = 1,
@bCreateOutFile BIT = 1,
@vcIgnoreField VARCHAR(100) = NULL,
@bExportToExcel BIT = 0,
@vcOrderByField VARCHAR(1000)  = NULL

AS

/*------------------------------------------------------------------------
DECLARE @vcInputTab1 VARCHAR(200) = 'FileExtr.DH18_HDX'
DECLARE @vcInputTab2 VARCHAR(100) 
DECLARE @vcInputTab3 VARCHAR(100)
DECLARE @vcInputTab4 VARCHAR(100)
DECLARE @vcInputTab5 VARCHAR(100)

DECLARE @bOutputFileDelimted BIT = 0 -- Fixed, delimited
DECLARE @vcFileDelimiter VARCHAR(1) = '|'

DECLARE @vcTargetPath VARCHAR(200)		= 'c:\ihds\'
DECLARE @vcTargetFileName VARCHAR(200)	= 'dh18_hdx.txt'
DECLARE @bTop10 BIT = 1
DECLARE @bDebug BIT = 1
DECLARE @bExec BIT = 1
DECLARE @bCreateOutFile BIT = 1
DECLARE @vcIgnoreField VARCHAR(100) 


SELECT 	@vcInputTab1 = 'FileExtr.TreSolRx_Tab1',
	@vcInputTab2 = 'FileExtr.TreSolRx_Tab2',
	@vcInputTab3 = 'FileExtr.TreSolRx_Tab3',
	@vcInputTab4 = NULL,
	@vcInputTab5 = NULL,

	@bOutputFileDelimted = 1,
	@vcFileDelimiter	= '|',

	@vcTargetPath 		= 'c:\ihds\',
	@vcTargetFileName 	= 'TreSolRx_hdx.txt',
	@bTop10				= 0,
	@bDebug				= 1,
	@bExec				= 1,
	@bCreateOutFile		= 1,
	@vcIgnoreField		= 'RowID'
*/------------------------------------------------------------------------

DECLARE @vcCmd VARCHAR(MAX),
	@vcCmd2 VARCHAR(8000),
	@nvcCmd NVARCHAR(4000),
	@vcSrcName VARCHAR(200),
	@vcSrcTab VARCHAR(200),
	@vcSrcSchema VARCHAR(100),
	@vcDB VARCHAR(200),
	@i INT

SELECT @vcDB = MAX(TABLE_CATALOG) FROM INFORMATION_SCHEMA.tables

IF OBJECT_ID('tempdb..##ExtrOut') IS NOT NULL 
	DROP TABLE ##ExtrOut

CREATE TABLE ##ExtrOut
	(ExtrRowID INT IDENTITY(1,1),
	ExtrTxt VARCHAR(4000)
	)

DECLARE @tInputTab TABLE (TabName VARCHAR(200), RowID INT IDENTITY(1,1))


INSERT INTO @tInputTab SELECT @vcInputTab1 

IF @vcInputTab2 IS NOT NULL 
	INSERT INTO @tInputTab SELECT @vcInputTab2 

IF @vcInputTab3 IS NOT NULL 
	INSERT INTO @tInputTab SELECT @vcInputTab3 

IF @vcInputTab4 IS NOT NULL 
	INSERT INTO @tInputTab SELECT @vcInputTab4 

IF @vcInputTab5 IS NOT NULL 
	INSERT INTO @tInputTab SELECT @vcInputTab5 


-- Excel Outpu
IF @bExportToExcel = 1
BEGIN
	
	SET @vcCmd = 'SELECT * FROM '+ @vcInputTab1 
				+ CASE WHEN @vcOrderByField IS NOT NULL THEN ' ORDER BY ' + @vcOrderByField  ELSE '' END
	SET @vcCmd2 = @vcTargetPath + ISNULL(@vcTargetFileName,REPLACE(@vcInputTab1,'FileExtr.','')+'.xls')

	EXEC [spExportDataToXLS]
		@dbName			= 'DHMP_Sandbox',
		@sql			= @vcCmd,
		@fullFileName	= @vcCmd2

	IF @vcInputTab2 IS NOT NULL 
	BEGIN

		SET @vcCmd = 'SELECT * FROM '+ @vcInputTab2
		SET @vcCmd2 = @vcTargetPath + REPLACE(@vcInputTab2,'FileExtr.','')+'.xls'

		EXEC [spExportDataToXLS]
			@dbName			= 'DHMP_Sandbox',
			@sql			= @vcCmd,
			@fullFileName	= @vcCmd2
	END

	IF @vcInputTab3 IS NOT NULL 
	BEGIN

		SET @vcCmd = 'SELECT * FROM '+ @vcInputTab3
		SET @vcCmd2 = @vcTargetPath + REPLACE(@vcInputTab3,'FileExtr.','')+'.xls'

		EXEC [spExportDataToXLS]
			@dbName			= 'DHMP_Sandbox',
			@sql			= @vcCmd,
			@fullFileName	= @vcCmd2
	END

	IF @vcInputTab4 IS NOT NULL 
	BEGIN

		SET @vcCmd = 'SELECT * FROM '+ @vcInputTab4
		SET @vcCmd2 = @vcTargetPath + REPLACE(@vcInputTab4,'FileExtr.','')+'.xls'

		EXEC [spExportDataToXLS]
			@dbName			= 'DHMP_Sandbox',
			@sql			= @vcCmd,
			@fullFileName	= @vcCmd2
	END

	IF @vcInputTab5 IS NOT NULL 
	BEGIN

		SET @vcCmd = 'SELECT * FROM '+ @vcInputTab5
		SET @vcCmd2 = @vcTargetPath + REPLACE(@vcInputTab5,'FileExtr.','')+'.xls'

		EXEC [spExportDataToXLS]
			@dbName			= 'DHMP_Sandbox',
			@sql			= @vcCmd,
			@fullFileName	= @vcCmd2
	END

END
ELSE 
BEGIN
	-- Create output table
	BEGIN

		SET @i = 1
	

		WHILE EXISTS (SELECT 1 FROM @tInputTab WHERE RowID = @i)
		BEGIN

			SELECT @vcSrcName = TabName
				FROM @tInputTab
				WHERE RowID = @i

	
			IF CHARINDEX('.',@vcSrcName) > 0
				SELECT @vcSrcTab = SUBSTRING(@vcSrcName,CHARINDEX('.',@vcSrcName)+1,200),
					@vcSrcSchema = SUBSTRING(@vcSrcName,1,CHARINDEX('.',@vcSrcName)-1)
	
			ELSE	
				SELECT @vcSrcTab = @vcSrcName,
					@vcSrcSchema = 'dbo'

			IF OBJECT_ID('tempdb..#col') IS NOT NULL 
				drop TABLE #col

			SELECT RowOrder = IDENTITY(INT,1,1),
					*,
					colLen = CASE WHEN DATA_TYPE iN ('VARCHAR','CHAR') THEN CHARACTER_MAXIMUM_LENGTH
									ELSE 50
									END
				INTO #col
				FROM INFORMATION_SCHEMA.COLUMNS 
				WHERE TABLE_SCHEMA = @vcSrcSchema
					AND TABLE_NAME = @vcSrcTab
					AND COLUMN_NAME <> ISNULL(@vcIgnoreField,'')
				ORDER BY ORDINAL_POSITION

			IF @bOutputFileDelimted = 1
			BEGIN
		
				SELECT @vcCmd = 'SELECT ' 
								+ CASE WHEN @bTop10 = 1 THEN ' TOP 10 ' + CHAR(13) ELSE '' END
								+ ' REPLACE(RTRIM(ISNULL(CONVERT(VARCHAR(' + CONVERT(VARCHAR(10),ColLen) +'),' + COLUMN_NAME + '),'''')),''' + @vcFileDelimiter + ''',''_'')'
					FROM #col
					WHERE RowOrder = 1

				SELECT @vcCmd = @vcCmd + '+'''+ @vcFileDelimiter + '''' + CHAR(13) 
						+ ' + REPLACE(RTRIM(ISNULL(CONVERT(VARCHAR(' + CONVERT(VARCHAR(10),ColLen) +'),' + COLUMN_NAME + '),'''')),''' + @vcFileDelimiter + ''',''_'')'
					FROM #col
					WHERE RowOrder > 1
					ORDER BY RowOrder

				SELECT @vcCmd = @vcCmd + ' FROM ' + @vcSrcSchema + '.' + @vcSrcTab
								+ CASE WHEN @vcOrderByField IS NOT NULL THEN ' ORDER BY ' + @vcOrderByField  ELSE '' END

				IF @bDebug = 1
					PRINT @vcCmd
				IF @bExec = 1
					INSERT INTO ##ExtrOut
					EXEC (@vcCmd)

			END
			ELSE
			BEGIN

				-- Alter length of extract field
				SELECT @i = SUM(ColLen)
					FROM #col

				SET @vcCmd = 'alter TABLE ##ExtrOut ALTER COLUMN ExtrTxt CHAR(' + CONVERT(VARCHAR(10),@i) + ')'
				IF @bDebug = 1	
					PRINT @vcCmd
				IF @bExec = 1
					EXEC (@vcCmd)

				SELECT @vcCmd = 'SELECT ' 
								+ CASE WHEN @bTop10 = 1 THEN ' TOP 10 ' + CHAR(13) ELSE '' END
								+ ' CONVERT(CHAR(' + CONVERT(VARCHAR(10),ColLen) +'),' + COLUMN_NAME + ')'
					FROM #col
					WHERE RowOrder = 1

				SELECT @vcCmd = @vcCmd + CHAR(13) 
						+ ' + CONVERT(CHAR(' + CONVERT(VARCHAR(10),ColLen) +'),' + COLUMN_NAME + ')'
					FROM #col
					WHERE RowOrder > 1
					ORDER BY RowOrder

				SELECT @vcCmd = @vcCmd + ' FROM ' + @vcSrcSchema + '.' + @vcSrcTab
									+ CASE WHEN @vcOrderByField IS NOT NULL THEN ' ORDER BY ' + @vcOrderByField  ELSE '' END

				IF @bDebug = 1
					PRINT @vcCmd
				IF @bExec = 1
					INSERT INTO ##ExtrOut
					EXEC (@vcCmd)
			END

			SET @i = @i + 1

		END


	END

	IF @bCreateOutFile = 1
	BEGIN
	
		EXEC [usp_export_table] 
			@vcDB = @vcDb, 
			@vcTab = '', 
			@vcType = 'E', 
			@vcPath = @vcTargetPath, 
			@vcFileName = @vcTargetFileName, 
			@vcDelim  = null, 
			@vcAddParam = NULL,
			@vcExportQuery = '"select ExtrTxt from ##ExtrOut order by ExtrRowid"',
			@bDebug = @bDebug

	END


	IF @bDebug = 1
		SELECT * FROM ##ExtrOut
			ORDER BY ExtrRowID
END
----------------------------------------------------------------------------------------------
GO
GRANT VIEW DEFINITION ON  [dbo].[prExportExtract] TO [db_ViewProcedures]
GO
