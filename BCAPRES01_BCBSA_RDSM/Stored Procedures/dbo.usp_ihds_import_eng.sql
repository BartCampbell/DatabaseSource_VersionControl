SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



/*************************************************************************************
Procedure:	usp_ihds_import_eng
Author:		Leon Dowling
Copyright:	© 2010
Date:		2010.2.05
Purpose:	
Parameters:	
	@vcPath				: The path of the text file. Must be from the perspective of the SQL Server
	@vcTxtFile			: the name of the text file.  Include the file extension
	@vcTargDB			: target database name
	@vcTargSchema		: target schema name.  If Null will use 'dbo'
	@vcTargTab			: Target table.  If null and @bMoveToTarget, a new table is created with @vcTxtfile name + CCYYMMDD of current date
	@iMinRow			: 1st row to import data
	@iMaxRow			: max row to import data.  choosing a lower number will allow a test to see what kind of data will be imported
	@bShowTop10Results  : show top 10 rows from target table,  utb_ihds_import_dtl, or the new file that is created @vcTxtfile + CCYYMMDD 
	@bMoveToTarget		: will move data to target table or to the @vcTxtfile name + CCYYMMDD 
	@iTargColCount      : enter the desired column count.  if not entered and @vcTargTab exists, will use column count without ('RowID','RowFileID','JobRunTaskFileID','LoadInstanceID','LoadInstanceFileID')
	@bColNameInFirstRow : does the import file have the column names in the first row
	@bSHowFirstRowInResult : keep the 1st row in the result set 
	@bMoveToProd        : 
	@iLoadInstanceID    : 
	@vcFieldTerminator  : 
	
Depends On:	
Calls:		
Called By:	
Returns:	0 = success
Notes:		None
Process:	
Change Log:
5/16 - Add @bTabDelimited 
12/06/2016 = fix CHAR(13)
Test Script:	

EXEC usp_ihds_import_eng
	@vcPath = 'L:\BCBSA.Datafiles\2017\',
	@vcTxtFile = 'Imp_Claim.2017-02-02.dat',
	@vcTargDB = 'BCBSA_RDSM',
	@vcTargSchema = 'dbo',
	@vcTargTab = 'imp_claim',
	@iMinRow = 1,
	@iMaxRow = null,
	@bShowTop10Results = 0,
	@bMoveToTarget = 1,
	@iTargColCount = NULL,
	@bColNameInFirstRow = 0,
	@bSHowFirstRowInResult = 0,
	@bMoveToProd = 1,
	@iLoadInstanceID = 1,
	@vcFieldTerminator = '\t',
	@bCompareFirstRowWithTargetColumns = 0,
	@vcRowTerminator = '\n',
	@bUseTargStructure  = 0,
	@bCreateTableBasedOnLine1 = 1


EXEC [usp_ihds_import_eng]
		@vcPath = '\\fs01\FileStore\StFrancis\Wellpoint\~Incoming\STFRANCIS_JUN2013_MAY2014_AUG2014\',
		@vcTxtFile = 'STFRANCI_MEMBERS_FNL.txt',
		@vcTargDB ='STFRAN_RDSM',
		@vcTargSchema ='Wellpoint',
		@vcTargTab = 'STFRANCI_MEMBERS_FNL',
		@iMaxRow =NULL,
		@iMinRow =NULL,
		@bShowTop10Results =0,
		@bMoveToTarget =1,
		@iTargColCount =null,
		@bColNameInFirstRow =0,
		@bSHowFirstRowInResult =0,
		@bMoveToProd =1,
		@iLoadInstanceID = 1,
		@vcFieldTerminator ='|',
		@bCompareFirstRowWithTargetColumns =0,
		@vcRowTerminator ='\n',
		@bUseTargStructure =1,
		@bCreateTableBasedOnLine1 =0,
		@bDebug = 0,
		@bTabDelimited = 1


select char('
	
SELECT dbo.ufn_CountChar('', '|' )	

ToDo:		
- add param for
   field terminiator
   row terminator
- add code at the end to undo this action
- add tests at the beginning to see that all files are in place based on params
- change max(len) code to use row names if they exists
*************************************************************************************/

--/*
CREATE PROC [dbo].[usp_ihds_import_eng]

	@vcPath VARCHAR(1000),
	@vcTxtFile VARCHAR(1000),
	@vcTargDB VARCHAR(100),
	@vcTargSchema VARCHAR(100),
	@vcTargTab VARCHAR(100),
	@iMaxRow INT,
	@iMinRow INT,
	@bShowTop10Results BIT,
	@bMoveToTarget BIT,
	@iTargColCount INT,
	@bColNameInFirstRow BIT,
	@bSHowFirstRowInResult BIT,
	@bMoveToProd BIT,
	@iLoadInstanceID INT,
	@vcFieldTerminator VARCHAR(10),
	@bCompareFirstRowWithTargetColumns BIT,
	@vcRowTerminator VARCHAR(10),
	@bUseTargStructure BIT = 0,
	@bCreateTableBasedOnLine1 BIT = 0,
	@bDebug BIT = 1,
	@bRemoveTextQuotes BIT = 0,
	@bTabDelimited BIT = 0

AS
--*/

/*---------------------------------------------------------------------------


DECLARE @vcPath VARCHAR(1000),
	@vcTxtFile VARCHAR(1000),
	@vcTargDB VARCHAR(100),
	@vcTargSchema VARCHAR(100),
	@vcTargTab VARCHAR(100),
	@iMaxRow INT,
	@iMinRow INT,
	@bShowTop10Results BIT,
	@bMoveToTarget BIT,
	@iTargColCount INT,
	@bColNameInFirstRow BIT,
	@bSHowFirstRowInResult BIT,
	@bMoveToProd BIT,
	@iLoadInstanceID INT,
	@vcFieldTerminator VARCHAR(10),
	@bCompareFirstRowWithTargetColumns BIT,
	@vcRowTerminator VARCHAR(10),
	@bUseTargStructure BIT,
	@bCreateTableBasedOnLine1 BIT,
	@bDebug BIT,
	@bRemoveTextQuotes BIT ,
	@bTabDelimited BIT 

DROP TABLE aetna.StFrancis_Claims2

SELECT 
	@vcPath = '\\imifs02\FileStore\StFrancis\Aetna\20140220\',
	@vcTxtFile = 'STFrancis_Claims2014_022014.txt',
	@vcTargDB = 'StFran_RDSM',
	@vcTargSchema = 'aetna',
	@vcTargTab = 'StFrancis_Claims2',
	@iMinRow = 1,
	@iMaxRow =NULL,
	@bShowTop10Results = 1,
	@bMoveToTarget = 1,
	@iTargColCount = null,
	@bColNameInFirstRow = 1,
	@bSHowFirstRowInResult = 1,
	@bMoveToProd = 1,
	@iLoadInstanceID = 1,
	@vcFieldTerminator = '|',
	@bCompareFirstRowWithTargetColumns = 1,
	@vcRowTerminator = NULL,
	@bUseTargStructure = 0,
	@bCreateTableBasedOnLine1  = 1,
	@bDebug = 1,
	@bRemoveTextQuotes = 0,
	@bTabDelimited = 1
				

--*/----------------------------------------------------------------------------

DECLARE @vcCmd VARCHAR(max),
	@vcCmd2 VARCHAR(MAX),
	@iColCnt INT,
	@iCnt INT,
	@lcExportQuery VARCHAR(2000),
	@lcAddParam VARCHAR(2000),
	@vcTab VARCHAR(100),
	@vcNewColName VARCHAR(100),
	@iLoadInstanceFileID INT,
	@iTempTableRowLen INT,
	@iMaxOrdinalPos INT,
	@iTotalRecordsAdded INT
	
IF @bTabDelimited = 1
	SET @vcFieldTerminator = CHAR(9)

IF OBJECT_ID('utb_ihds_import_format') IS NOT NULL
	DROP TABLE utb_ihds_import_format
	
CREATE TABLE utb_ihds_import_format (txt VARCHAR(200), Rowid INT IDENTITY(1,1))

ALTER TABLE utb_ihds_import_format ADD CONSTRAINT pk PRIMARY KEY (rowid)

IF OBJECT_ID('utb_ihds_import_fmt_tabinfo') IS NOT NULL
	DROP TABLE utb_ihds_import_fmt_tabinfo
	
CREATE TABLE utb_ihds_import_fmt_tabinfo (txt VARCHAR(200), Rowid INT IDENTITY(1,1))

ALTER TABLE utb_ihds_import_fmt_tabinfo ADD CONSTRAINT pk1 PRIMARY KEY (rowid)

IF OBJECT_ID('tempdb..#targStructure') IS NOT NULL
	DROP TABLE #TargStructure
	
CREATE TABLE #TargStructure (ColName VARCHAR(100), ColOrder INT, ColLen INT)

set @vcCmd = @vcTargSchema+'.' + @vcTargTab

IF OBJECT_ID(@vcCmd) IS NOT NULL AND @bCreateTableBasedOnLine1 = 1
BEGIN

	PRINT '-----------------------------------------------------------'
	PRINT '@bCreateTableBasedOnLine1 is set to True and the table ' + @vcCmd + ' Already Exists'
	PRINT 'DROP TABLE ' + @vcCmd + ' and try again'
	PRINT '-----------------------------------------------------------'
	
	RETURN

END

IF @bCreateTableBasedOnLine1 = 1
BEGIN

	IF OBJECT_ID('tempdb..##crtab') is not null
		drop table ##crTab

	create table ##crTab (txt VARCHAR(8000))

	SET @lcAddParam = '/L 1'

	EXEC dbo.usp_export_table
		@lcDB = @vcTargDB, -- char(50)
		@lcTab = '##crtab', -- char(50)
		@lcType = 'I', -- char(1)
		@lcPath = @vcPath, -- varchar(200)
		@lcFileName = @vcTxtFile, -- varchar(100)
		@lcDelim = @vcFieldTerminator, -- varchar(1)
		@lcAddParam = @lcAddParam

	SELECT @vcCmd = txt FROM ##crTab

	SET @vcCmd2 = 'CREATE TABLE ' + @vcTargSchema+'.' + @vcTargTab 
					+'(RowID INT IDENTITY(1,1), ' +CHAR(13)
					+'RowFileID INT, ' +CHAR(13)
					+'JobRunTaskFileID Uniqueidentifier, ' +CHAR(13)
					+'LoadInstanceID INT, ' +CHAR(13)
					+'LoadInstanceFileID INT' 

	WHILE CHARINDEX(@vcFieldTerminator,@vcCmd) <> 0 
	BEGIN
		SET @vcCmd2 = @vcCmd2 + ',' + CHAR(13) +'['
						+   REPLACE(
							REPLACE(
							REPLACE(
						    REPLACE(
							REPLACE(SUBSTRING(@vcCmd,1,CHARINDEX(@vcFieldTerminator,@vcCmd)-1),
							'/',''),
							' ',''),
							'-',''),
							'"','') ,
							CHAR(13),'')
							+ '] VARCHAR(200)'
		
		SET @vcCmd = SUBSTRING(@vcCmd,CHARINDEX(@vcFieldTerminator,@vcCmd)+ 1,2000)

	END

	SET @vcCmd2 = @vcCmd2 + ',' + CHAR(13) + '[' 
					+   REPLACE(
						REPLACE(
					    REPLACE(
						REPLACE(
						REPLACE(@vcCmd,
						'/',''),
						' ',''),
						'-',''),
						'"',''),
						CHAR(13),'')
						+ '] VARCHAR(200))'
	
	EXEC (@vcCmd2)

	IF @bDebug = 1
		PRINT @vcCmd2

END

IF @iTargColCount IS NULL
BEGIN	
	SELECT  @iColCnt = COUNT(*)
		FROM INFORMATION_SCHEMA.COLUMNS
		WHERE table_name = @vcTargTab
			AND TABLE_SCHEMA = @vcTargSchema
			AND Column_name NOT IN ('RowID','RowFileID','JobRunTaskFileID','LoadInstanceID','LoadInstanceFileID')

	INSERT INTO #TargStructure
	SELECT Column_name,
			ordinal_position - 5,
			ColLen = CASE WHEN character_maximum_length IS NOT NULL THEN character_maximum_length
							WHEN numeric_precision is not null THEN numeric_precision + 10
							ELSE 50
							END
		FROM INFORMATION_SCHEMA.COLUMNS
		WHERE table_name = @vcTargTab
			AND TABLE_SCHEMA = @vcTargSchema
			AND Column_name NOT IN ('RowID','RowFileID','JobRunTaskFileID','LoadInstanceID','LoadInstanceFileID')

END

ELSE

	SET @iColCnt = @iTargColCount

IF ( OBJECT_ID('utb_ihds_import_dtl') IS NOT NULL )
BEGIN 
	DROP TABLE utb_ihds_import_dtl
END 

SET @iCnt = 1

TRUNCATE TABLE utb_ihds_import_format 

INSERT INTO utb_ihds_import_format SELECT '<?xml version="1.0"?>'
INSERT INTO utb_ihds_import_format SELECT '<BCPFORMAT '
INSERT INTO utb_ihds_import_format SELECT 'xmlns="http://schemas.microsoft.com/sqlserver/2004/bulkload/format" '
INSERT INTO utb_ihds_import_format SELECT 'xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">'
INSERT INTO utb_ihds_import_format SELECT '  <RECORD>'

--PRINT '@iColCnt = ' + CONVERT(VARCHAR(10),@iColCnt)

IF @bDebug = 1
	SET NOCOUNT ON



SET @iCnt = 1
WHILE @iCnt <= @iColCnt
BEGIN
	
	INSERT INTO utb_ihds_import_format SELECT '<FIELD ID="' + CONVERT(VARCHAR(10),@iCnt) + '" xsi:type="CharTerm" TERMINATOR=' 
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
													END + ' MAX_LENGTH="200"/>'
	SET @iCnt = @iCnt + 1

END
INSERT INTO utb_ihds_import_format SELECT '  </RECORD> '
INSERT INTO utb_ihds_import_format SELECT '    <ROW> '
SET @iCnt = 1
WHILE @iCnt <= @iColCnt
BEGIN

	INSERT INTO utb_ihds_import_format SELECT '     <COLUMN SOURCE="' + CONVERT(VARCHAR(10),@iCnt) + '" NAME="Col' + CONVERT(VARCHAR(10),@iCnt) + '" xsi:type="SQLVARYCHAR"/>'

	SET @iCnt = @iCnt + 1

END
IF @bDebug = 1
	SET NOCOUNT OFF

INSERT INTO utb_ihds_import_format SELECT '  </ROW>'
INSERT INTO utb_ihds_import_format SELECT '</BCPFORMAT> '
 

SELECT @lcExportQuery = '"SELECT txt FROM ' + @vcTargDB + '.dbo.utb_ihds_import_format"'

exec usp_export_table @vcTargDB,'utb_ihds_import_format','E',@vcPath,'utb_ihds_import_format.txt','', @lcExportQuery = @lcExportQuery



--IF @bUseTargStructure = 0 AND FLOOR(8000/@iColCnt) < 200 
--	SET @bUseTargStructure = 1

IF @bUseTargStructure = 0
	SELECT @vcCmd = 'CREATE TABLE utb_ihds_import_dtl (Col1 VARCHAR(200)'
ELSE 
	SELECT @vcCmd = 'CREATE TABLE utb_ihds_import_dtl (Col1 VARCHAR(' + CONVERT(VARCHAR(10),ColLen) + ')'
		FROM #TargStructure
		WHERE ColOrder = 1



SET @iCnt = 2

IF @bDebug = 1
	SET NOCOUNT oN

WHILE @iCnt <= @iColCnt
BEGIN
	SELECT @iCnt
	IF @bUseTargStructure = 0
		SELECT @vcCmd = @vcCmd + ', Col' + CONVERT(VARCHAR(10),@iCnt) + ' VARCHAR(200)'
	ELSE 
		SELECT @vcCmd = @vcCmd + ', Col' + CONVERT(VARCHAR(10),@iCnt) + ' VARCHAR(' + CONVERT(VARCHAR(10),ColLen)+')'
			FROM #TargStructure
			WHERE ColOrder = @iCnt
	
	SET @iCnt = @iCnt + 1
END

IF @bDebug = 1
	SET NOCOUNT OFF

SELECT @vcCmd = @vcCmd + ',RowFileID INT IDENTITY(1,1) )'

IF @bDebug = 1
	PRINT @vcCMd

--/*
--SELECT @vcCMd
EXEC (@vcCMD)

SET @lcAddParam = '/f ' + @vcPath + 'utb_ihds_import_format.txt' -- varchar(100)
					+ CASE WHEN @iMaxRow IS NOT NULL 
								AND @bMoveToProd = 0
							THEN ' /L ' + CONVERT(VARCHAR(10),@iMaxRow)
							ELSE ''
					END
					+CASE WHEN @iMinRow IS NOT NULL THEN ' /F ' + CONVERT(VARCHAR(10),@iMinRow)
							ELSE ''
					END


EXEC dbo.usp_export_table
	@lcDB = @vcTargDB, -- char(50)
    @lcTab = 'utb_ihds_import_dtl', -- char(50)
    @lcType = 'I', -- char(1)
    @lcPath = @vcPath, -- varchar(200)
    @lcFileName = @vcTxtFile, -- varchar(100)
    @lcDelim = NULL, -- varchar(1)
    @lcAddParam = @lcAddParam

-- Remove quotes
IF @bRemoveTextQuotes = 1
BEGIN

	SELECT @vcCmd = 'UPDATE utb_ihds_import_dtl SET Col1  = REPLACE(col1,''"'','''')'

	SET @iCnt = 2
	IF @bDebug = 1
		SET NOCOUNT ON

	WHILE @iCnt <= @iColCnt
	BEGIN

		SELECT @vcCmd = @vcCmd + ',' + CHAR(13) + ' Col' + CONVERT(VARCHAR(10),@iCnt) 
						+ ' = REPLACE(col' + CONVERT(VARCHAR(10),@iCnt) + ',''"'','''')'
		
		SET @iCnt = @iCnt + 1
	END

	IF @bDebug = 1
		SET NOCOUNT OFF

	IF @bDebug = 1
		PRINT @vcCMd
		
	EXEC (@vcCMD)

END



SET @vcCmd = 'SELECT '

IF @vcTargTab IS NULL
BEGIN
	SELECT @vcCmd = @vcCmd + '[' + column_name + '] = MAX(LEN([' + column_name + '])),' + CHAR(13)
		FROM INFORMATION_SCHEMA.COLUMNS a
		WHERE table_name = 'utb_ihds_import_dtl'
			AND TABLE_SCHEMA = 'dbo'
			AND Column_name NOT IN ('RowID','RowFileID','JobRunTaskFileID','LoadInstanceID','LoadInstanceFileID')
		ORDER BY ORDINAL_POSITION		

	SELECT @vcCmd = LEFT(@vcCmd,LEN(@vcCmd) - 2) + ' FROM utb_ihds_import_dtl '
						+ CASE WHEN @bColNameInFirstRow = 1 THEN ' WHERE RowFileID > 1 ' ELSE '' END
	IF @bDebug = 1
		PRINT @vcCmd
		
	EXEC (@vcCmd)

END
ELSE
BEGIN
	SET @vcCmd2 = 'SELECT ' 
 
	IF OBJECT_ID('tempdb..#ColLenIssue') IS NOT NULL	
		DROP TABLE #ColLenIssue
		
	CREATE TABLE #ColLenIssue (FieldName VARCHAR(100),
								ColType VARCHAR(20),
								MaxColLen  INT,
								SrcFileMaxColLen  INT)
		
	SELECT @vcCmd = @vcCmd + '['+ b.column_name + '] = MAX(LEN([' + a.column_name + '])),' + CHAR(13),
		@vcCmd2 = 'select field_name = ''' + b.COLUMN_NAME + ''', ColType= ''' + b.DATA_TYPE + ''', MaxColLen = ' 
			+ CASE WHEN b.Data_type IN ('CHAR','VARCHAR') THEN CONVERT(VARCHAR(10),b.CHARACTER_MAXIMUM_LENGTH) ELSE '0' END
			+ ', SrcFileMaxColLen = MAX(LEN([' + a.Column_name + '])) FROM utb_ihds_import_dtl ' 
			+ CASE WHEN @bColNameInFirstRow = 1 THEN ' WHERE RowFileID > 1 ' ELSE '' END
			+ ' ' + CHAR(13)
		FROM INFORMATION_SCHEMA.COLUMNS a
			LEFT JOIN (SELECT *
						FROM INFORMATION_SCHEMA.COLUMNS 
						WHERE table_name = @vcTargTab
							AND TABLE_SCHEMA = @vcTargSchema
							AND Column_name NOT IN ('RowID','RowFileID','JobRunTaskFileID','LoadInstanceID','LoadInstanceFileID')
						) b
				ON a.ORDINAL_POSITION + 5 = b.ORDINAL_POSITION 
		WHERE a.table_name = 'utb_ihds_import_dtl'
			AND a.TABLE_SCHEMA = 'dbo'
			AND a.Column_name NOT IN ('RowID','RowFileID','JobRunTaskFileID','LoadInstanceID','LoadInstanceFileID')
			AND a.ORDINAL_POSITION = 1
		ORDER BY a.ORDINAL_POSITION		

 
	SELECT @vcCmd = @vcCmd +'['+ b.column_name + '] = MAX(LEN([' + a.column_name + '])),' + CHAR(13),
			@vcCmd2 = @vcCmd2 + 'UNION ALL select field_name = ''' + b.COLUMN_NAME + ''', ColType= ''' + b.DATA_TYPE + ''', MaxColLen = ' 
			+ CASE WHEN b.Data_type IN ('CHAR','VARCHAR') THEN CONVERT(VARCHAR(10),b.CHARACTER_MAXIMUM_LENGTH) ELSE '0' END
			+ ', SrcFileMaxColLen = MAX(LEN([' + a.Column_name + '])) FROM utb_ihds_import_dtl ' 
			+ CASE WHEN @bColNameInFirstRow = 1 THEN ' WHERE RowFileID > 1 ' ELSE '' END
			+ '' + CHAR(13)
		FROM INFORMATION_SCHEMA.COLUMNS a
			LEFT JOIN (SELECT *
						FROM INFORMATION_SCHEMA.COLUMNS 
						WHERE table_name = @vcTargTab
							AND TABLE_SCHEMA = @vcTargSchema
							AND Column_name NOT IN ('RowID','RowFileID','JobRunTaskFileID','LoadInstanceID','LoadInstanceFileID')
						) b
				ON a.ORDINAL_POSITION + 5 = b.ORDINAL_POSITION 
		WHERE a.table_name = 'utb_ihds_import_dtl'
			AND a.TABLE_SCHEMA = 'dbo'
			AND a.Column_name NOT IN ('RowID','RowFileID','JobRunTaskFileID','LoadInstanceID','LoadInstanceFileID')
			AND a.ORDINAL_POSITION > 1
		ORDER BY a.ORDINAL_POSITION		
	
	SELECT @vcCmd = LEFT(@vcCmd,LEN(@vcCmd) - 2) + ' FROM utb_ihds_import_dtl '
						+ CASE WHEN @bColNameInFirstRow = 1 THEN ' WHERE RowFileID > 1 ' ELSE '' END
	IF @bDebug = 1
	BEGIN
		PRINT @vcCmd
		EXEC (@vcCmd)
	END
	
	IF @bDebug = 1	
		PRINT @vcCmd2

	INSERT INTO #ColLenIssue
	EXEC (@vcCmd2)
	
	IF @bDebug = 1
		SELECT * FROM #colLenIssue
	
	IF @bDebug = 1
		SELECT * FROM #colLenIssue
			WHERE SrcFileMaxColLen > MaxColLen

END

-- Move to Target Table
IF @bMoveToTarget = 1
BEGIN
	-- create a holding table
	IF @vcTargTab IS NOT NULL
	BEGIN
		SET @vcTab = CASE WHEN @vcTargSchema IS NOT NULL THEN @vcTargSchema + '.' ELSE '' END
						+ @vcTargTab + '_' + CONVERT(VARCHAR(8),GETDATE(),112)

		IF OBJECT_ID(@vcTab) IS NOT NULL	
		BEGIN
			SET @vcCmd = 'DROP TABLE ' + @vcTab
			IF @bDebug = 1
				PRINT @vcCmd
			EXEC (@vcCmd)
		END

		SET @vcCmd = 'SELECT top 0 '

		SELECT @vcCmd = @vcCmd + '[' + column_name + '],' + CHAR(13)
			FROM INFORMATION_SCHEMA.COLUMNS
			WHERE table_name = @vcTargTab
				AND TABLE_SCHEMA = @vcTargSchema
				AND Column_name NOT IN ('RowID','RowFileID','JobRunTaskFileID','LoadInstanceID','LoadInstanceFileID')
			ORDER BY ORDINAL_POSITION		

		SET @vcCmd = LEFT(@vcCmd,LEN(@vcCmd) - 2) + ' INTO ' + @vcTab + ' FROM ' + @vcTargDb + '.' + @vcTargSchema + '.' + @vcTargTab

		IF @bDebug = 1
			PRINT @vcCmd
		EXEC (@vcCmd)

		SET @vcCmd = 'ALTER TABLE ' + @vcTab + ' ADD RowFileID INT IDENTITY(1,1)'
		IF @bDebug = 1
			PRINT @vcCmd
		EXEC (@vcCmd)

		SET @vcCmd = 'INSERT INTO ' + @vcTab + '('

		SELECT @vcCmd = @vcCmd + '['+ column_name + '],' + CHAR(13)
			FROM INFORMATION_SCHEMA.COLUMNS
			WHERE table_name = @vcTargTab
				AND TABLE_SCHEMA = @vcTargSchema
				AND Column_name NOT IN ('RowID','RowFileID','JobRunTaskFileID','LoadInstanceID','LoadInstanceFileID')
			ORDER BY ORDINAL_POSITION		

		SET @vcCmd = LEFT(@vcCmd,LEN(@vcCmd) - 2) + ') ' + CHAR(13) + 'SELECT '

		SELECT @iMaxOrdinalPos = MAX(ORDINAL_POSITION)
			FROM INFORMATION_SCHEMA.COLUMNS a
			WHERE a.table_name = 'utb_ihds_import_dtl'
				AND a.TABLE_SCHEMA = 'dbo'

		SELECT @vcCmd = @vcCmd + CASE WHEN a.ORDINAL_POSITION <> @iMaxOrdinalPos
										THEN '['+ a.column_name + '],' + CHAR(13)
										ELSE '['+a.column_name + '] = REPLACE(['+a.COLUMN_NAME+'],CHAR(13),''''), ' + CHAR(13)
										END
			FROM INFORMATION_SCHEMA.COLUMNS a
			WHERE a.table_name = 'utb_ihds_import_dtl'
				AND a.TABLE_SCHEMA = 'dbo'
				AND a.Column_name NOT IN ('RowID','RowFileID','JobRunTaskFileID','LoadInstanceID','LoadInstanceFileID')
			ORDER BY ORDINAL_POSITION		

		SET @vcCmd = LEFT(@vcCmd,LEN(@vcCmd) - 2) + ' FROM utb_ihds_import_dtl '
						+ CASE WHEN @bColNameInFirstRow = 1 THEN ' WHERE RowFileID > 1 ' ELSE '' END
						+ ' order by RowFileID'
		IF @bDebug = 1
			PRINT @vcCmd
		EXEC (@vcCmd)

		IF @bCompareFirstRowWithTargetColumns = 1 AND @bDebug = 1
		BEGIN
			SELECT	a.COLUMN_NAME, b.COLUMN_NAME
				FROM (SELECT *
						FROM INFORMATION_SCHEMA.COLUMNS
						WHERE TABLE_NAME = @vcTargTab
							AND TABLE_SCHEMA = @vcTargSchema
					) a
				FULL outer JOIN (SELECT *
								FROM INFORMATION_SCHEMA.COLUMNS
								WHERE RTRIM(TABLE_SCHEMA)+'.' + TABLE_NAME = @vcTab
					) b
					ON a.ORDINAL_POSITION = b.ORDINAL_POSITION  + 5
		END

		IF @bMoveToProd = 1

		BEGIN
			
			
			IF OBJECT_ID('tempdb..#LoadInstanceStatPre') IS NOT NULL 
				DROP TABLE #LoadInstanceStatPre
			
			CREATE TABLE #LoadInstanceStatPre
				(LoadInstanceFileID INT,
				PreLoadCnt INT)
			
			SET @vcCmd = 'SELECT LoadInstanceFileID, count(*) FROM ' 
						+ CASE WHEN @vcTargSchema IS NOT NULL THEN @vcTargSchema + '.' ELSE '' END
						+ @vcTargTab 
						+ ' GROUP BY LoadInstanceFileID'
			IF @bDebug = 1
				PRINT @vcCmd
			
			INSERT INTO #LoadInstanceStatPre
			        ( LoadInstanceFileID ,
			          PreLoadCnt 
			        )
			EXEC (@vcCmd)
	
			-- First see if the file already exists in imiadmin.dbo.ClientProcessInstanceFile
			
			INSERT INTO IMIAdmin.dbo.ClientProcessInstanceFile
			        ( LoadInstanceID ,
			          InboundFileName ,
			          InboundFilePath ,
			          InboundMachine ,
			          DateReceived
			        )
				SELECT LoadInstanceID  = @iLoadInstanceID,
			          InboundFileName = @vcTxtFile,
			          InboundFilePath = @vcPath,
			          InboundMachine = @@SERVERNAME,
			          DateReceived = GETDATE()
			
			SELECT @iLoadInstanceFileID = MAX(LoadInstanceFileID) 
				FROM imiadmin.dbo.ClientProcessInstanceFile 
				WHERE InboundFileName = @vcTxtFile
					AND InboundFilePath = @vcPath

			SET @vcTab = CASE WHEN @vcTargSchema IS NOT NULL THEN @vcTargSchema + '.' ELSE '' END
						+ @vcTargTab 
						
			SET @vcCmd = 'INSERT INTO ' + @vcTab + '('

			SELECT @vcCmd = @vcCmd + '[' + column_name + '],' + CHAR(13)
				FROM INFORMATION_SCHEMA.COLUMNS
				WHERE table_name = @vcTargTab
					AND TABLE_SCHEMA = @vcTargSchema
					AND Column_name NOT IN ('RowID')
				ORDER BY ORDINAL_POSITION		

			SELECT @vcCmd = LEFT(@vcCmd,LEN(@vcCmd) - 2) + ') ' + CHAR(13) 
					+ 'SELECT RowFileID = RowFileID, ' + CHAR(13)
					+ ' JobRunTaskFileID = null, ' + CHAR(13)
					+ ' LoadInstanceID = ' + CONVERT(VARCHAR(10),@iLoadInstanceID) + ', ' + CHAR(13)
					+ ' LoadInstanceFileID = ' +  CONVERT(VARCHAR(10),@iLoadInstanceFileID) + ', ' + CHAR(13)


			SELECT @iMaxOrdinalPos = MAX(ORDINAL_POSITION)
				FROM INFORMATION_SCHEMA.COLUMNS a
				WHERE a.table_name = 'utb_ihds_import_dtl'
					AND a.TABLE_SCHEMA = 'dbo'
					AND a.Column_name NOT IN ('RowID','RowFileID','JobRunTaskFileID','LoadInstanceID','LoadInstanceFileID')

			SELECT @vcCmd = @vcCmd + CASE WHEN a.ORDINAL_POSITION <> @iMaxOrdinalPos
											THEN '[' + a.column_name + '],' + CHAR(13)
											ELSE '{'+ a.column_name + '] = REPLACE(['+a.COLUMN_NAME+'],CHAR(13),''''), ' + CHAR(13)
											END
				FROM INFORMATION_SCHEMA.COLUMNS a
				WHERE table_name = 'utb_ihds_import_dtl'
					AND TABLE_SCHEMA = 'dbo'
					AND Column_name NOT IN ('RowID','RowFileID','JobRunTaskFileID','LoadInstanceID','LoadInstanceFileID')
				ORDER BY ORDINAL_POSITION		

			SET @vcCmd = LEFT(@vcCmd,LEN(@vcCmd) - 2) + ' FROM utb_ihds_import_dtl '
							+ CASE WHEN @bColNameInFirstRow = 1 THEN ' WHERE RowFileID > 1 ' ELSE '' END
							+ ' order by RowFileID'
			IF @bDebug = 1
				PRINT @vcCmd
			EXEC (@vcCmd)

			SET @iTotalRecordsAdded = @@ROWCOUNT
	
			IF OBJECT_ID('tempdb..#LoadInstanceStatPost') IS NOT NULL 
				DROP TABLE #LoadInstanceStatPost
			
			CREATE TABLE #LoadInstanceStatPost
				(LoadInstanceFileID INT,
				PostLoadCnt INT)
			
			SET @vcCmd = 'SELECT LoadInstanceFileID, count(*) FROM ' 
						+ CASE WHEN @vcTargSchema IS NOT NULL THEN @vcTargSchema + '.' ELSE '' END
						+ @vcTargTab 
						+ ' GROUP BY LoadInstanceFileID'
			IF @bDebug = 1
				PRINT @vcCmd
			
			INSERT INTO #LoadInstanceStatPost
			        ( LoadInstanceFileID ,
			          PostLoadCnt 
			        )
			EXEC (@vcCmd)
	
			IF @bDebug = 1
				SELECT	LoadInstanceFileID = ISNULL(pre.LoadInstanceFileID,post.LoadInstanceFileID),
						pre.PreLoadCnt,
						post.PostLoadCnt,
						Diff = ISNULL(post.PostLoadCnt,0) - pre.PreLoadCnt
					FROM #LoadInstanceStatPre pre
						FULL OUTER JOIN #LoadInstanceStatPost Post
							ON pre.LoadInstanceFileID = Post.LoadInstanceFileID


		END



	END
	ELSE
	BEGIN
		SET @vcTab = CASE WHEN @vcTargSchema IS NOT NULL THEN @vcTargSchema + '.' ELSE '' END
						+ REPLACE(REPLACE(REPLACE(@vcTxtFile,'.','_'),' ','_'),'-','_') + '_' + CONVERT(VARCHAR(8),GETDATE(),112)
		
		IF OBJECT_ID(@vcTab) IS NOT NULL	
		BEGIN
			SET @vcCmd = 'DROP TABLE ' + @vcTab
			IF @bDebug = 1
				PRINT @vcCmd
			EXEC (@vcCmd)
		END

		IF @bColNameInFirstRow = 1
		BEGIN
			
			IF OBJECT_ID('tempdb..#newcol') IS NOT NULL	
				DROP TABLE #newcol
				
			CREATE TABLE #newcol (oldcol VARCHAR(100), newcol VARCHAR(100))
			
			SET @iCnt = 1
			
			WHILE @iCnt <= @iColCnt
			BEGIN
							
				SET @vcCmd = 'SELECT ''Col' + CONVERT(VARCHAR(10),@iCnt) + ''', Col' + CONVERT(VARCHAR(10),@iCnt) + ' FROM utb_ihds_import_dtl WHERE RowFileID = 1' 
				IF @bDebug = 1
					PRINT @vcCmd
				
				INSERT INTO #newcol ( oldcol, newcol )
				EXEC (@vcCmd)
				
				SET @iCnt = @iCnt + 1
			END

			SET @vcCmd = ''
	
			SELECT @vcCmd = @vcCmd + 'Exec sp_rename ''utb_ihds_import_dtl.' + oldcol + ''',  ''' + RTRIM(LTRIM(newcol)) + ''', ''COLUMN''; ' + CHAR(13)
			--'ALTER TABLE utb_ihds_import_dtl RENAME COLUMN ' + oldcol + ' to ' + Newcol + ';' + CHAR(13)
				FROM #newcol	
				
			IF @bDebug = 1
				PRINT @vcCmd
			EXEC (@vcCmd)	

		END

	
		SET @vcCmd = 'SELECT * INTO ' + @vcTab + ' FROM utb_ihds_import_dtl '
					+CASE WHEN ISNULL(@bSHowFirstRowInResult,1) = 0 THEN ' WHERE RowFileID > 1' ELSE '' END
		IF @bDebug = 1
			PRINT @vcCmd
		EXEC (@vcCmd)

	END

END
ELSE
	IF @bCompareFirstRowWithTargetColumns = 1
	BEGIN
	
		IF OBJECT_ID('tempdb..#newcol2') IS NOT NULL	
			DROP TABLE #newcol2
			
		CREATE TABLE #newcol2 (oldcol VARCHAR(100), newcol VARCHAR(100))
		
		SET @iCnt = 1
		
		WHILE @iCnt <= @iColCnt
		BEGIN
						
			SELECT @vcCmd = 'SELECT ''Col' + CONVERT(VARCHAR(10),@iCnt) + ''', ''' + Column_name + '''' 
				FROM INFORMATION_SCHEMA.COLUMNS
				WHERE table_name = @vcTargTab
					AND TABLE_SCHEMA = @vcTargSchema
					AND ORDINAL_POSITION = @iCnt + 5
			
			IF @bDebug = 1
				PRINT @vcCmd
			
			INSERT INTO #newcol2 ( oldcol, newcol )
			EXEC (@vcCmd)
			
			SET @iCnt = @iCnt + 1
		END

		SET @vcCmd = ''

		SELECT @vcCmd = @vcCmd + 'Exec sp_rename ''utb_ihds_import_dtl.' + LTRIM(RTRIM(oldcol)) + ''',  ''' + LTRIM(RTRIM(newcol)) + ''', ''COLUMN''; ' + CHAR(13)
		--'ALTER TABLE utb_ihds_import_dtl RENAME COLUMN ' + oldcol + ' to ' + Newcol + ';' + CHAR(13)
			FROM #newcol2	
		
		IF @bDebug = 1	
			PRINT @vcCmd
		EXEC (@vcCmd)	
	
	END

IF @bShowTop10Results = 1
BEGIN
	IF @bMoveToTarget = 1
		IF @bMoveToProd = 1
			SELECT @vcCMd = 'SELECT TOP 10 * FROM ' + @vcTargDB + '.' + @vcTargSchema + '.' + @vcTargTab + ' WHERE LoadInstanceFileID = ' + CONVERT(VARCHAR(10),@iLoadInstanceFileID)
		ELSE
			SET @vcCmd = 'SELECT TOP 10 * FROM ' + @vcTab
	ELSE 
		SET @vcCmd = 'SELECT TOP 10 * from utb_ihds_import_dtl'
	
	IF @bDebug = 1
		PRINT @vcCmd
	EXEC (@vcCmd)
	
END

RETURN ISNULL(@iTotalRecordsAdded,0)
--*/


-- Find Column Count
/*
IF OBJECT_ID('utb_ihds_import_tabinfo') IS NOT NULL	
	DROP TABLE utb_ihds_import_tabinfo
	
CREATE TABLE utb_ihds_import_tabinfo
(txt1 VARCHAR(200),
txt2 VARCHAR(200),	
txt3 VARCHAR(200),
txt4 VARCHAR(200),
txt5 VARCHAR(200),
txt6 VARCHAR(200),
txt7 VARCHAR(200),
txt8 VARCHAR(200),
txt9 VARCHAR(200))

INSERT INTO utb_ihds_import_format SELECT '<?xml version="1.0"?>'
INSERT INTO utb_ihds_import_format SELECT '<BCPFORMAT '
INSERT INTO utb_ihds_import_format SELECT 'xmlns="http://schemas.microsoft.com/sqlserver/2004/bulkload/format" '
INSERT INTO utb_ihds_import_format SELECT 'xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">'
INSERT INTO utb_ihds_import_format SELECT '  <RECORD>'

SET @iCnt = 1
WHILE @iCnt <= 9
BEGIN

	INSERT INTO utb_ihds_import_format SELECT '<FIELD ID="' + CONVERT(VARCHAR(10),@iCnt) + '" xsi:type="NativeFixed" TERMINATOR="'
											+ CASE WHEN @iCnt = 9 THEN '\n' ELSE '' END + '" MAX_LENGTH="200"/>'
	SET @iCnt = @iCnt + 1

END
INSERT INTO utb_ihds_import_format SELECT '  </RECORD> '
INSERT INTO utb_ihds_import_format SELECT '    <ROW> '
SET @iCnt = 1
WHILE @iCnt <= 9
BEGIN

	INSERT INTO utb_ihds_import_format SELECT '     <COLUMN SOURCE="' + CONVERT(VARCHAR(10),@iCnt) + '" NAME="txt' + CONVERT(VARCHAR(10),@iCnt) + '" xsi:type="SQLCHAR"/>'

	SET @iCnt = @iCnt + 1

END

INSERT INTO utb_ihds_import_format SELECT '  </ROW>'
INSERT INTO utb_ihds_import_format SELECT '</BCPFORMAT> '

SELECT @lcExportQuery = '"SELECT txt FROM ' + @vcTargDB + '.dbo.utb_ihds_import_format"'

exec usp_export_table @vcTargDB,'utb_ihds_import_fmt_tabinfo','E',@vcPath,'utb_ihds_import_fmt_tabinfo','', @lcExportQuery = @lcExportQuery



EXEC dbo.usp_export_table
	@lcDB = 'Premerus_IMIStaging', -- char(50)
    @lcTab = 'utb_ihds_import_tabinfo', -- char(50)
    @lcType = 'I', -- char(1)
    @lcPath = 'J:\Dataware\Premerus\20100205\', -- varchar(200)
    @lcFileName = 'Premerus_members_with_ct_or_mri.txt', -- varchar(100)
    @lcDelim = NULL, -- varchar(1)
    @lcAddParam = '/f J:\Dataware\Premerus\20100205\utb_ihds_import_fmt_tabinfo.txt' -- varchar(100)


SELECT TOP 10 * FROM utb_ihds_import_tabinfo
*/

GO
