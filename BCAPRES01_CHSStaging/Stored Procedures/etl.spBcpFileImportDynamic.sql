SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


/****************************************************************************************************************************************************
Description:			Import a file using BCP to CHSStaging.etl.BCPFileStage. For file automation, this proc will not be called directly. Instead,
						spBcpFileImportByFileConfigID will be used to lookup the config params and call this.
Depenedents:			etl.spBcpFile

Usage:
EXEC CHSStaging.etl.spBcpFileImportDynamic
	@FileLogID = 1000850
	,@FileProcessID = 1001
	,@vcPath = '\\CHS-FS01\DataIntake\112562\HEDIS'
	,@vcTxtFile = 'BCBSAZ_LabResults_20170112.txt'
	,@iColCnt = 34
	,@vcFieldTerminator = '|'
	,@vcRowTerminator = '\n'
	,@bTabDelimited = 0
	,@bBcpParmIsFixedWidth = 0
	,@bRemoveTextQuotes = 1
	,@iMinRow = NULL	
	,@iMaxRow = NULL
	,@Debug = 1

SELECT * FROM etl.BCPFileFormat_1001
SELECT * FROM etl.BCPFileStage_1001

spBcpFile: Import:bcp CHSStaging.etl.BCPFileStage_1001 IN "\\CHS-FS01\DataIntake\112562\HEDIS\BCBSAZ_LabResults_20170112.txt" -S CHSDEVDB01 -T -c -o \\CHS-FS01\DataIntake\112562\HEDIS\BCBSAZ_LabResults_20170112.txt.out -e \\CHS-FS01\DataIntake\112562\HEDIS\BCBSAZ_LabResults_20170112.txt.err /f \\CHS-FS01\DataIntake\112562\HEDISBCPFileFormat_1001.txt


Parameters:	
	@FileLogID
	@FileProcessID
	@vcPath				: The path of the text file. Must be from the perspective of the SQL Server
	@vcTxtFile			: The name of the text file.  Include the file extension
	@iColCnt      : Enter the desired column count.  if not entered and @vcTargTab exists, will use column count without ('RowID','RowFileID','JobRunTaskFileID','LoadInstanceID','LoadInstanceFileID')
	@vcFieldTerminator  : '|'
	@vcRowTerminator	: '\n'
	@bTabDelimited		: If set to 1, Change @vcFieldTerminator = NULL
	@bRemoveTextQuotes
	@iMinRow			: 1st row to import data
	@iMaxRow			: max row to import data.  
	@Debug

Change Log:
-----------------------------------------------------------------------------------------------------------------------------------------------------
2010-02-05	Leon Dowling		- Create
5/16		Leon Dowling		- Add @bTabDelimited 
2016-11-15	Michael Vlk			- Update for new CHS ETL process use
								- Split into spBcpFileImport / spBcpFileStageToRDSM
								- Rename: utb_ihds_import_dtl to BCPFileStage; utb_ihds_import_format to BCPFileFormat; utb_ihds_import_fmt_tabinfo to BCPFileTabInfo
								- BCPFileStage no longer recreated each run. Truncate only.
2016-12-24	Michael Vlk			- Enable Max/Min row ability. Primary use to get 1st row for pre-validation
2017-01-03	Michael Vlk			- Add functionality: Remove \n \r from last col
2017-01-17	Michael Vlk			- Fix Remove \n \r from last col, had static Col223 in replacement string
2017-02-02	Michael Vlk			- Allow stage table to be dynamic based on ProcessID
2017-03-14	Michael Vlk			- Add spBCPFileStageTableCreate_Flat to setup stage table for ProcessID
****************************************************************************************************************************************************/
CREATE PROC [etl].[spBcpFileImportDynamic]
	@FileLogID INT
	,@FileProcessID INT
	,@vcPath VARCHAR(1000)
	,@vcTxtFile VARCHAR(1000)
	,@iColCnt INT
	,@vcFieldTerminator VARCHAR(10)
	,@vcRowTerminator VARCHAR(10)
	,@bTabDelimited BIT = 0	
	,@bBcpParmIsFixedWidth INT = 0
	,@bRemoveTextQuotes BIT = 0
	,@iMinRow INT = NULL	
	,@iMaxRow INT = NULL
	,@Debug INT = 0
AS

-- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

	SET NOCOUNT ON 

	DECLARE 
		@vcCmd NVARCHAR(MAX)
		,@iCnt INT
		,@lcExportQuery VARCHAR(2000)
		,@lcAddParam VARCHAR(2000)
		,@BCPFileStageRowCnt INT
		,@DebugMsgVar VARCHAR(100)
		,@BCPFileFormat VARCHAR(100)
		,@BCPFileFormatFull VARCHAR(100)
		,@BCPFileFormatFile VARCHAR(100)
		,@BCPFileTabInfo VARCHAR(100)
		,@BCPFileStage VARCHAR(100)
		,@BCPFileStageFull VARCHAR(100)

	SET @BCPFileFormat = 'BCPFileFormat_' + CAST(@FileProcessID AS VARCHAR)
		SET @BCPFileFormatFull = 'etl.' + @BCPFileFormat
		SET @BCPFileFormatFile = @BCPFileFormat
	SET @BCPFileTabInfo = 'BCPFileTabInfo_' + CAST(@FileProcessID AS VARCHAR)
	SET @BCPFileStage = 'BCPFileStage_' + CAST(@FileProcessID AS VARCHAR)
		SET @BCPFileStageFull = 'etl.' + @BCPFileStage
	
	IF @bTabDelimited = 1
		SET @vcFieldTerminator = CHAR(9)

	SELECT @vcCmd = '
	IF OBJECT_ID(''etl.' + @BCPFileFormat + ''') IS NOT NULL
		DROP TABLE etl.' + @BCPFileFormat + '
	
		CREATE TABLE etl.' + @BCPFileFormat + ' (txt VARCHAR(200), Rowid INT IDENTITY(1,1))
		ALTER TABLE etl.' + @BCPFileFormat + ' ADD CONSTRAINT ' + @BCPFileFormat + '_PK PRIMARY KEY (RowID)

	IF OBJECT_ID(''etl.' + @BCPFileTabInfo + ''') IS NOT NULL
		DROP TABLE etl.' + @BCPFileTabInfo + '
	
		CREATE TABLE etl.' + @BCPFileTabInfo + ' (txt VARCHAR(200), Rowid INT IDENTITY(1,1))
		ALTER TABLE etl.' + @BCPFileTabInfo + ' ADD CONSTRAINT ' + @BCPFileTabInfo + '_PK PRIMARY KEY (RowID)

	IF OBJECT_ID(''etl.' + @BCPFileStage + ''') IS NOT NULL
		DROP TABLE etl.' + @BCPFileStage + '

		SELECT * INTO etl.' + @BCPFileStage + ' FROM etl.BCPFileStage_TemplateFlat
		ALTER TABLE etl.' + @BCPFileStage + ' ADD CONSTRAINT ' + @BCPFileStage + '_PK PRIMARY KEY (RowFileID)
	'

	IF @Debug >= 1 PRINT CHAR(13) + 'spBcpFileImportDynamic: Create BCP Objects: ' + CHAR(13) + @vcCmd
	IF @Debug <= 1 EXEC (@vcCmd)


-- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	IF @Debug >= 1 PRINT CHAR(13) + 'spBcpFileImportDynamic: Initialize BCPFileFormat'

	SELECT @vcCmd = '
	INSERT INTO etl.' + @BCPFileFormat + ' (txt) VALUES (''<?xml version="1.0"?>'')
	INSERT INTO etl.' + @BCPFileFormat + ' (txt) VALUES (''<BCPFORMAT '')
	INSERT INTO etl.' + @BCPFileFormat + ' (txt) VALUES (''xmlns="http://schemas.microsoft.com/sqlserver/2004/bulkload/format" '')
	INSERT INTO etl.' + @BCPFileFormat + ' (txt) VALUES (''xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">'')
	INSERT INTO etl.' + @BCPFileFormat + ' (txt) VALUES (''  <RECORD>'')
	'

	IF @Debug >= 1 PRINT CHAR(13) + 'spBcpFileImportDynamic: Initialize BCPFileFormat: ' + CHAR(13) + @vcCmd
	IF @Debug <= 1 EXEC (@vcCmd)
	
	-- 

	IF @Debug >= 1 PRINT CHAR(13) + 'spBcpFileImport: INSERT INTO BCPFileFormat: @iColCnt: ' + CAST(@iColCnt AS VARCHAR)

	SET @iCnt = 1
	WHILE @iCnt <= @iColCnt
		BEGIN
			SELECT @vcCmd = '
			INSERT INTO etl.' + @BCPFileFormat + ' (txt) VALUES (''<FIELD ID="' + CONVERT(VARCHAR(10),@iCnt) + '" xsi:type="CharTerm" TERMINATOR=' 
													+ CASE WHEN @iCnt = @iColCnt 
															THEN CASE WHEN @vcRowTerminator IS NULL 
																		THEN '"\n"' 
																		ELSE '"' + @vcRowTerminator + '"'
																		END
														ELSE CASE		
																WHEN @bTabDelimited = 1 THEN '"\t"'
																WHEN @vcFieldTerminator IS NULL THEN '"|"' 
																ELSE '"' + @vcFieldTerminator +'"'
																END
														END 
													+ CASE WHEN @bBcpParmIsFixedWidth = 1
															THEN ' MAX_LENGTH="8000"/>'
														ELSE ' MAX_LENGTH="255"/>'
														END
													+ ''')'
			IF @Debug >= 1 PRINT CHAR(13) + 'spBcpFileImportDynamic: Initialize BCPFileFormat: ' + CHAR(13) + @vcCmd
			IF @Debug <= 1 EXEC (@vcCmd)

			SET @iCnt = @iCnt + 1

		END
	
	SELECT @vcCmd = '
	INSERT INTO etl.' + @BCPFileFormat + ' (txt) VALUES (''  </RECORD> '')
	INSERT INTO etl.' + @BCPFileFormat + ' (txt) VALUES (''    <ROW> '')
	'

	IF @Debug >= 1 PRINT CHAR(13) + 'spBcpFileImportDynamic: Initialize BCPFileFormat: ' + CHAR(13) + @vcCmd
	IF @Debug <= 1 EXEC (@vcCmd)


	SET @iCnt = 1
	WHILE @iCnt <= @iColCnt
		BEGIN
			SELECT @vcCmd = '
			INSERT INTO etl.' + @BCPFileFormat + ' (txt) VALUES (''     <COLUMN SOURCE="' + CONVERT(VARCHAR(10),@iCnt) + '" NAME="Col' + CONVERT(VARCHAR(10),@iCnt) + '" xsi:type="SQLVARYCHAR"/>'
													+ ''')'

			IF @Debug >= 1 PRINT CHAR(13) + 'spBcpFileImportDynamic: Initialize BCPFileFormat: ' + CHAR(13) + @vcCmd
			IF @Debug <= 1 EXEC (@vcCmd)

			SET @iCnt = @iCnt + 1
		END

	SELECT @vcCmd = '
	INSERT INTO etl.' + @BCPFileFormat + ' (txt) VALUES (''  </ROW>'')
	INSERT INTO etl.' + @BCPFileFormat + ' (txt) VALUES (''</BCPFORMAT> '')
	'

	IF @Debug >= 1 PRINT CHAR(13) + 'spBcpFileImportDynamic: Initialize BCPFileFormat: ' + CHAR(13) + @vcCmd
	IF @Debug <= 1 EXEC (@vcCmd)

	--
	
	SELECT @lcExportQuery = '"SELECT txt FROM CHSStaging.etl.' + @BCPFileFormat + '"'

	IF @Debug >= 1 PRINT CHAR(13) + 'spBcpFileImport: EXEC spBcpFile: Export BCPFileFormat.txt'

	EXEC etl.spBcpFileDynamic 
		'CHSStaging' 
		,@BCPFileFormatFull
		,'E'
		,@vcPath
		,@BCPFileFormatFile
		,''
		,@lcExportQuery = @lcExportQuery
		,@Debug = @Debug


-- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	IF @Debug >= 1 PRINT CHAR(13) + 'spBcpFileImportDynamic: EXEC etl.spBCPFileStageTableCreate_Flat'
	/*
	IF @Debug <= 1
	EXEC etl.spBCPFileStageTableCreate_Flat @FileProcessID*/

-- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	IF @Debug >= 1 PRINT CHAR(13) + 'spBcpFileImport: EXEC etl.spBcpFile Import'

	SET @lcAddParam = '/f ' + @vcPath + '\' + @BCPFileFormatFile + '.txt'
						+ CASE 
							WHEN @iMaxRow IS NOT NULL
								THEN ' /L ' + CONVERT(VARCHAR(10),@iMaxRow)
							ELSE ''
							END
						+ CASE 
							WHEN @iMinRow IS NOT NULL 
								THEN ' /F ' + CONVERT(VARCHAR(10),@iMinRow)
							ELSE ''
							END

	IF @Debug >= 1 
		BEGIN
			PRINT CHAR(13) + 'spBcpFileImport: EXEC etl.spBcpFile: Import BCPFileStage'
			PRINT '@vcPath: ' + @vcPath
			PRINT '@vcTxtFile: ' + @vcTxtFile
			PRINT '@lcAddParam: ' + @lcAddParam
		END
	
	IF @Debug <= 1
	EXEC etl.spBcpFileDynamic
		@lcDB = 'CHSStaging' -- char(50)
		,@lcTab = @BCPFileStage -- char(50)
		,@lcType = 'I' -- char(1)
		,@lcPath = @vcPath -- varchar(200)
		,@lcFileName = @vcTxtFile -- varchar(100)
		,@lcDelim = NULL -- varchar(1)
		,@lcAddParam = @lcAddParam
		,@Debug = @Debug
	
	--

	SELECT @vcCmd = '
	SELECT @BCPFileStageRowCnt = COUNT(*) FROM CHSStaging.etl.' + @BCPFileStage + '
	UPDATE CHSStaging.etl.' + @BCPFileStage + ' SET FileLogID = ' + CAST (@FileLogID AS VARCHAR)

	IF @Debug >= 1 PRINT CHAR(13) + 'spBcpFileImportDynamic: Update/Count BCPFileStage: ' + CHAR(13) + @vcCmd
	IF @Debug <= 1 EXEC sp_executesql @vcCmd, N'@BCPFileStageRowCnt INT OUT', @BCPFileStageRowCnt OUT
	IF @Debug >= 1 PRINT 'BCP Records Imported: ' + CAST(@BCPFileStageRowCnt AS VARCHAR)

-- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
-- Remove \n \r from last col

	IF @Debug >= 1 PRINT CHAR(13) + 'spBcpFileImport: Remove \n \r from last col'

	SELECT @vcCmd = 'UPDATE CHSStaging.etl.' + @BCPFileStage + ' SET Col' + CAST(@iColCnt AS VARCHAR) + ' = REPLACE(REPLACE(Col' + CAST(@iColCnt AS VARCHAR) + ', CHAR(13), ''''), CHAR(10), '''')'

	IF @Debug >= 1
		PRINT @vcCMd
		
	IF @Debug <= 1
		EXEC (@vcCMD)

-- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
-- Remove quotes

	IF @bRemoveTextQuotes = 1
	BEGIN
		IF @Debug >= 1 PRINT CHAR(13) + 'spBcpFileImport: IF @bRemoveTextQuotes = 1'

		SELECT @vcCmd = 'UPDATE CHSStaging.etl.' + @BCPFileStage + ' SET Col1  = REPLACE(col1,''"'','''')'

		SET @iCnt = 2

		WHILE @iCnt <= @iColCnt
		BEGIN

			SELECT @vcCmd = @vcCmd + ',' + CHAR(13) + ' Col' + CONVERT(VARCHAR(10),@iCnt) 
							+ ' = REPLACE(col' + CONVERT(VARCHAR(10),@iCnt) + ',''"'','''')'
		
			SET @iCnt = @iCnt + 1
		END

		IF @Debug >= 1
			PRINT @vcCMd
		
		IF @Debug <= 1
			EXEC (@vcCMD)
	END -- IF @bRemoveTextQuotes = 1





GO
