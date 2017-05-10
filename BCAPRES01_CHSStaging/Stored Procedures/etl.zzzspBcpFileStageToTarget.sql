SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


/****************************************************************************************************************************************************
Purpose:				Import data from BCPFileStageRDSM to the target table.
Depenedents:			etl.spBcpFile

Usage

DECLARE @RowCntRDSM INT, @FileLogXML XML, @FileConfigXML XML, @FileProcessXML XML
DECLARE
	@FileLogID INT = 1002126
	,@FileConfigID INT = 100196
	,@FileProcessID INT = 1001

SET @FileLogXML = (		SELECT * FROM CHSStaging.etl.FileLog WHERE FileLogID = @FileLogID FOR XML PATH				)
SET @FileConfigXML = (	SELECT * FROM CHSStaging.etl.FileConfig WHERE FileConfigID = @FileConfigID FOR XML PATH		)
SET @FileProcessXML = (	SELECT * FROM CHSStaging.etl.FileProcess WHERE FileProcessID = @FileProcessID FOR XML PATH	)

EXEC CHSStaging.etl.spBcpFileStageToTarget
	@FileLogID = @FileLogID -- 1000904 -- INT
	,@FileProcessID = @FileProcessID -- 3001 -- INT
	,@FileLogXML = @FileLogXML --'<row><FileLogID>1000000</FileLogID><FileConfigID>100246</FileConfigID><CentauriClientID>112556</CentauriClientID><FilePathIntake>\\fs01.imihealth.com\FileStore\StFrancis\Anthem\MA</FilePathIntake><FileNameIntake>CTStFrancisMEDICARE_case_mgmt_03132017.txt</FileNameIntake><FileLogDate>2017-04-18T12:09:42.957</FileLogDate><FileSize>77371</FileSize><FileThread>4</FileThread><FileThreadPriority>2</FileThreadPriority><RowCntFile>711</RowCntFile><RowCntImport>711</RowCntImport><DateFile>2017-03-13T00:00:00</DateFile><FileLogSessionID>1000000</FileLogSessionID></row>'
	,@FileConfigXML = @FileConfigXML --'<row><FileConfigID>100246</FileConfigID><FileProcessID>1001</FileProcessID><FileSetID>100022</FileSetID><CentauriClientID>112556</CentauriClientID><IsActive>1</IsActive><FilePriority>0</FilePriority><FileActionCd>1</FileActionCd><FileNamePattern>CTStFrancisMEDICARE_case_mgmt_&lt;MMDDYYYY&gt;.txt</FileNamePattern><AllowDups>0</AllowDups><FreqID>0</FreqID><SQLDestServer>IMIETL05.IMIHealth.com</SQLDestServer><SQLDestDB>StFran_RDSM</SQLDestDB><SQLDestSchema>AnthemMA</SQLDestSchema><SQLDestTable>CTStFrancis_Case_Mgmt</SQLDestTable><SQLDestTrunc>0</SQLDestTrunc><BcpParmColCount>11</BcpParmColCount><BcpParmFieldTerminator>|</BcpParmFieldTerminator><BcpParmRowTerminator>\n</BcpParmRowTerminator><BcpParmIsTabDelimited>0</BcpParmIsTabDelimited><BcpParmIsFixedWidth>0</BcpParmIsFixedWidth><BcpParmRemoveTextQuotes>1</BcpParmRemoveTextQuotes><HasHeader>1</HasHeader><HasFooter>0</HasFooter><RowsToSkip>0</RowsToSkip><EmailNotification>Michael.Vlk@CentauriHS.com</EmailNotification><IMIClientName>STFRAN</IMIClientName><CreateDate>2017-04-12T14:55:16.870</CreateDate><LastUpdated>2017-04-13T08:31:55.627</LastUpdated></row>'
	,@FileProcessXML = @FileProcessXML --'<row><FileProcessID>1001</FileProcessID><SQLDestTableColIgnoreListProcess>''RowID'',''RowFileID'',''JobRunTaskFileID'',''LoadInstanceID'',''LoadInstanceFileID''</SQLDestTableColIgnoreListProcess><IsActive>1</IsActive><CreateDate>2017-02-10T08:28:00.517</CreateDate><LastUpdated>2017-02-10T08:28:00.517</LastUpdated><FileProcessDesc>IHDS RDSM Standard Files</FileProcessDesc></row>'
	,@RowCntRDSM = @RowCntRDSM OUTPUT --INT OUTPUT
	,@Debug = 1 -- INT = 1

SELECT @RowCntRDSM

UPDATE CHSStaging.ETL.FileLog SET RowCntRDSM = @RowCntRDSM WHERE FileLogID = @FileLogID

SELECT * -- SELECT COUNT(*) -- DELETE 
	FROM CHSStaging.mmr.MMR_Stage WHERE FileLogID = 1000905

Change Log:
----------------------------------------------------------------------------------------------------------------------------------------------------- 
2016-11-15	Michael Vlk			- Create
2016-12-27	Michael Vlk			- Switch from table BCPFileStage to BCPFileStageRDSM. Original will be on central server and then copied for use to RDSM server for final load.
2017-01-06	Michael Vlk			- Update logic to not copy first row if @HasHeader
2017-02-10	Michael Vlk			- Use dynamic objects based on the FileProcessID
2017-03-01	Michael Vlk			- Merge former RDSM(IMI) and DV versions into single proc
2017-03-24	Michael Vlk			- Handle when DateFile is NULL. COALESCE(@DateFile,'1900-01-01')
2017-04-12	Michael Vlk			- Change Parm RDSMTruncTarget to SQLDestTrunc
2017-04-13	Michael Vlk			- Multi-thread update
2017-04-20	Michael Vlk			- Add logic to not Insert to IMIAdmin.dbo.ClientProcessInstanceFile if exists
****************************************************************************************************************************************************/
CREATE PROC [etl].[zzzspBcpFileStageToTarget]
	@FileLogID INT
	,@FileProcessID INT
	,@FileLogXML XML
	,@FileConfigXML XML
	,@FileProcessXML XML
	,@RowCntRDSM INT OUTPUT
	,@Debug INT = 0

AS

SET NOCOUNT ON

DECLARE 
	@vcCmd NVARCHAR(MAX)
	,@vcCmd2 NVARCHAR(MAX)
	,@SQLDestTableColList VARCHAR(MAX) = ''
	,@SQLSrcTableColList VARCHAR(MAX) = ''
	,@iCnt INT
	,@SQLSrcOrdinalPosCur INT
	,@SQLSrcOrdinalPosLast INT
	,@SQLDestFQN VARCHAR(100) 
	,@DebugMsgVar VARCHAR(100)

-- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
IF @Debug >= 1 PRINT CHAR(13) + 'spBcpFileStageToTarget: Get Parms'

	-- Get FileConfig Parms

	DECLARE
		@FileConfigID INT
		,@SQLDestDB VARCHAR (100)
		,@SQLDestSchema VARCHAR(100)
		,@SQLDestTable VARCHAR(100)
		,@BcpParmColCount INT
		,@RowsToSkip INT
		,@HasHeader INT
		,@HasFooter INT
		,@BcpParmIsFixedWidth INT
		,@SQLDestTrunc INT
		,@FilePathIntake VARCHAR(1000)
		,@FileNameIntake VARCHAR(1000)
		,@DateFile VARCHAR(1000)
		,@SQLDestTableColIgnoreListProcess VARCHAR(1000)
		,@SQLDestTableColIgnoreListConfig VARCHAR(1000)
		,@BCPFileStage VARCHAR(100)
		,@BCPFileStageFull VARCHAR(100)
		,@IMIClientName VARCHAR(100)

	--

	SET @BCPFileStage = 'BCPFileStage_' + CAST(@FileLogID AS VARCHAR)
		SET @BCPFileStageFull = 'etl.' + @BCPFileStage
	
	-- FileLog

	SELECT
		@FilePathIntake = tr.a.value('(FilePathIntake/text())[1]', 'varchar(255)') + CASE WHEN RIGHT(tr.a.value('(FilePathIntake/text())[1]', 'varchar(255)'),1) <> '\' THEN '\' ELSE '' END
		,@FileNameIntake = tr.a.value('(FileNameIntake/text())[1]', 'varchar(255)')
		,@DateFile = tr.a.value('(DateFile/text())[1]', 'varchar(255)')
	FROM @FileLogXML.nodes('/row') AS tr ( a )

	-- FileConfig

	SELECT
		@FileConfigID =			tr.a.value('(FileConfigID/text())[1]', 'int')
		,@SQLDestDB =			tr.a.value('(SQLDestDB/text())[1]', 'varchar(100)')
		,@SQLDestSchema =		tr.a.value('(SQLDestSchema/text())[1]', 'varchar(100)')
		,@SQLDestTable =		tr.a.value('(SQLDestTable/text())[1]', 'varchar(100)')
		,@BcpParmColCount =		tr.a.value('(BcpParmColCount/text())[1]', 'int')
		,@RowsToSkip =			ISNULL(tr.a.value('(RowsToSkip/text())[1]', 'int'),0) + ISNULL(tr.a.value('(HasHeader/text())[1]', 'int'),0)
		,@HasHeader =			ISNULL(tr.a.value('(HasHeader/text())[1]', 'int'),0)
		,@HasFooter =			ISNULL(tr.a.value('(HasFooter/text())[1]', 'int'),0)
		,@BcpParmIsFixedWidth =	ISNULL(tr.a.value('(BcpParmIsFixedWidth/text())[1]', 'int'),0)
		,@IMIClientName =		tr.a.value('(IMIClientName/text())[1]', 'varchar(100)')
		,@SQLDestTrunc =		ISNULL(tr.a.value('(SQLDestTrunc/text())[1]', 'int'),0)
		,@SQLDestTableColIgnoreListConfig = tr.a.value('(SQLDestTableColIgnoreListConfig/text())[1]', 'varchar(1000)')
	FROM @FileConfigXML.nodes('/row') AS tr ( a )

	-- FileProcess

	SELECT
		@SQLDestTableColIgnoreListProcess = tr.a.value('(SQLDestTableColIgnoreListProcess/text())[1]', 'varchar(1000)')
	FROM @FileProcessXML.nodes('/row') AS tr ( a )

	IF @Debug >= 1 PRINT CHAR(13) + 'spBcpFileStageToTarget: @SQLDestTableColIgnoreListProcess:' + CHAR(13) + @SQLDestTableColIgnoreListProcess

	IF @Debug >= 1 SELECT @FileLogID,@FileConfigID,@SQLDestDB,@SQLDestSchema,@SQLDestTable,@BcpParmColCount,@RowsToSkip,@HasHeader,@HasFooter,@BcpParmIsFixedWidth,@IMIClientName

	SET @SQLDestFQN = @SQLDestDB + '.'
				+ CASE WHEN @SQLDestSchema IS NOT NULL 
					THEN @SQLDestSchema + '.' 
					ELSE '.' 
					END
				+ @SQLDestTable 


-- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
IF @Debug >= 1 PRINT CHAR(13) + 'spBcpFileStageToTarget: Build @SQLSrcTableColList / @SQLDestTableColList'

	CREATE TABLE #SQLTargetDef (COLUMN_NAME VARCHAR(100),ORDINAL_POSITION INT,CHARACTER_MAXIMUM_LENGTH INT)

	SELECT @vcCmd = '
	INSERT INTO #SQLTargetDef
	SELECT COLUMN_NAME,ORDINAL_POSITION,CHARACTER_MAXIMUM_LENGTH
	FROM ' + @SQLDestDB + '.INFORMATION_SCHEMA.COLUMNS
	WHERE table_name = ''' + @SQLDestTable + '''
		AND TABLE_SCHEMA = ''' + @SQLDestSchema + ''''
		+ CASE WHEN @SQLDestTableColIgnoreListProcess IS NOT NULL OR @SQLDestTableColIgnoreListConfig IS NOT NULL THEN '
		AND COLUMN_NAME NOT IN (' 
				+ CASE WHEN @SQLDestTableColIgnoreListProcess IS NOT NULL THEN @SQLDestTableColIgnoreListProcess ELSE '' END
				+ CASE WHEN @SQLDestTableColIgnoreListProcess IS NOT NULL AND @SQLDestTableColIgnoreListConfig IS NOT NULL THEN ',' ELSE '' END
				+ CASE WHEN @SQLDestTableColIgnoreListConfig IS NOT NULL THEN @SQLDestTableColIgnoreListConfig ELSE '' END
			+ ')'
			ELSE '' END + '
	ORDER BY ORDINAL_POSITION'

	IF @Debug >= 1 PRINT CHAR(13) + 'spBcpFileStageToTarget: EXEC INSERT INTO #SQLTargetDef: ' + CHAR(13) + @vcCmd
	EXEC (@vcCmd)

	-- 

	SET @SQLSrcTableColList = ''
	SET @iCnt = 1
	SELECT @SQLSrcOrdinalPosCur = MIN(ORDINAL_POSITION) FROM #SQLTargetDef
	SET @SQLSrcOrdinalPosLast = 1

	WHILE @SQLSrcOrdinalPosCur IS NOT NULL
		BEGIN
			SELECT 
				@SQLSrcTableColList = @SQLSrcTableColList + CHAR(9)
					+ CASE @BcpParmIsFixedWidth
						WHEN 0 THEN '[' + COLUMN_NAME + ']' + ' = [Col' + CAST(@iCnt AS VARCHAR) + ']' 
						WHEN 1 THEN '[' + COLUMN_NAME + ']' + ' = SUBSTRING(Col1,' + CAST(@SQLSrcOrdinalPosLast AS VARCHAR) + ',' + CAST(CHARACTER_MAXIMUM_LENGTH AS VARCHAR) + ')'
						END
					+ ','
					+ CHAR(13)
				,@SQLDestTableColList = @SQLDestTableColList + CHAR(9) + '[' + COLUMN_NAME + '],' + CHAR(13)
				,@SQLSrcOrdinalPosLast = @SQLSrcOrdinalPosLast + CHARACTER_MAXIMUM_LENGTH
			FROM #SQLTargetDef
			WHERE ORDINAL_POSITION = @SQLSrcOrdinalPosCur

			SELECT @SQLSrcOrdinalPosCur = MIN(ORDINAL_POSITION) FROM #SQLTargetDef WHERE ORDINAL_POSITION > @SQLSrcOrdinalPosCur
			SET @iCnt = @iCnt + 1
		END

	IF @Debug >= 1 PRINT CHAR(13) + 'spBcpFileStageToTarget: @SQLDestTableColList: ' + CHAR(13) + ISNULL(@SQLDestTableColList,'!!!Error-Missing')
	IF @Debug >= 1 PRINT CHAR(13) + 'spBcpFileStageToTarget: @SQLSrcTableColList: ' + CHAR(13) + ISNULL(@SQLSrcTableColList,'!!!Error-Missing')


-- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
IF @Debug >= 1 PRINT CHAR(13) + 'spBcpFileStageToTarget: IMI LoadInstanceFileID' + CASE WHEN @IMIClientName IS NULL THEN ': Skipped' ELSE '' END


	IF @IMIClientName IS NOT NULL AND NOT EXISTS (SELECT 1 FROM IMIAdmin.dbo.ClientProcessInstanceFile WHERE LoadInstanceFileID = @FileLogID)
		BEGIN
			SELECT @vcCmd = '
			SET IDENTITY_INSERT IMIAdmin.dbo.ClientProcessInstanceFile ON

			INSERT INTO IMIAdmin.dbo.ClientProcessInstanceFile 
				(LoadInstanceID,LoadInstanceFileID,InboundFileName,InboundFilePath,InboundMachine,DateReceived,DateFile) 
				VALUES (0,' + CAST(@FileLogID AS VARCHAR) + ',''' + @FileNameIntake + ''',''' + @FilePathIntake + ''',''' + @@SERVERNAME + ''',''' + CAST(GETDATE() AS VARCHAR) + ''',''' + CAST(COALESCE(@DateFile,'1900-01-01') AS VARCHAR) + ''')

			SET IDENTITY_INSERT IMIADmin.dbo.ClientProcessInstanceFile OFF'

		IF @Debug >=1 PRINT CHAR(13) + 'spBcpFileStageToTarget: IMI LoadInstanceFileID: ' + CHAR(13) + @vcCmd

		IF @Debug <= 1 EXEC (@vcCmd)

		END

-- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
IF @Debug >= 1 PRINT CHAR(13) + 'spBcpFileStageToTarget: @SQLDestTrunc: ' + CASE WHEN @SQLDestTrunc <> 1 THEN 'Skipped' ELSE '' END

	IF @SQLDestTrunc = 1
	 BEGIN
	 	SELECT @vcCmd = 
			'TRUNCATE TABLE ' + @SQLDestFQN

		IF @Debug >=1 PRINT CHAR(13) + 'spBcpFileStageToTarget: @SQLDestTrunc: ' + CHAR(13) + @vcCmd

		IF @Debug <= 1 EXEC (@vcCmd)
	END

-- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
IF @Debug >= 1 PRINT CHAR(13) + 'spBcpFileStageToTarget: Build INSERT INTO:'

	SELECT @vcCmd = 
			'INSERT INTO ' + @SQLDestFQN + ' (' + CHAR(13) 
				+ CHAR(9) + 'RowFileID,' + CHAR(13)
				+ CHAR(9) + 'JobRunTaskFileID,' + CHAR(13)
				+ CHAR(9) + 'LoadInstanceID,' + CHAR(13)
				+ CHAR(9) + 'LoadInstanceFileID,' + CHAR(13) 
				+ LEFT(@SQLDestTableColList,LEN(@SQLDestTableColList) - 2) + CHAR(13)
				+ CHAR(9) + ') ' + CHAR(13)  		
			+ 'SELECT' + CHAR(13)
				+ CHAR(9) + 'RowFileID = RowFileID, ' + CHAR(13)
				+ CHAR(9) + 'JobRunTaskFileID = NULL, ' + CHAR(13)
				+ CHAR(9) + 'LoadInstanceID = ' + CONVERT(VARCHAR(10),0) + ', ' + CHAR(13) -- @LoadInstanceID
				+ CHAR(9) + 'LoadInstanceFileID = ' +  CONVERT(VARCHAR(10), @FileLogID) + ', ' + CHAR(13) -- @LoadInstanceFileID
				+ LEFT(@SQLSrcTableColList,LEN(@SQLSrcTableColList) - 2) + CHAR(13)
			+ 'FROM BCPStaging.etl.' + @BCPFileStage + CHAR(13) 
			+ CASE WHEN @HasHeader = 1 THEN 'WHERE RowFileID > 1' + CHAR(13) ELSE '' END
			+ 'ORDER BY RowFileID'
/*								
	SELECT @vcCmd = 
			'INSERT INTO ' + @SQLDestFQN + ' (' + CHAR(13) 
				+ LEFT(@SQLDestTableColList,LEN(@SQLDestTableColList) - 2) + ',' + CHAR(13)
				--+ CHAR(9) + 'FileLogID' + CHAR(13)
				+ CHAR(9) + ') ' + CHAR(13)  		
			+ 'SELECT' + CHAR(13)
				+ LEFT(@SQLSrcTableColList,LEN(@SQLSrcTableColList) - 2) + ',' + CHAR(13)
				--+ CHAR(9) + 'FileLogID = ' +  CONVERT(VARCHAR(10),@FileLogID) + CHAR(13) 
			+ 'FROM BCPStaging.etl.' + @BCPFileStage + CHAR(13) 
			+ CASE WHEN @HasHeader = 1 THEN 'WHERE RowFileID > 1' + CHAR(13) ELSE '' END
			+ 'ORDER BY RowFileID'
*/
	IF @Debug >= 1 PRINT CHAR(13) + 'spBcpFileStageToTarget: EXEC INSERT INTO: ' + CHAR(13) + @vcCmd
	IF @Debug <= 1 EXEC (@vcCmd)

-- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
IF @Debug >= 1 PRINT CHAR(13) + 'spBcpFileStageToTarget: Build Get Row Counts'

	IF @IMIClientName IS NOT NULL
		SELECT @vcCmd = 'SELECT @RowCntRDSM = COUNT(*) FROM ' + @SQLDestFQN + ' WHERE LoadInstanceFileID = ' + CAST(@FileLogID AS VARCHAR)
	ELSE
		SELECT @vcCmd = 'SELECT @RowCntRDSM = COUNT(*) FROM ' + @SQLDestFQN + ' WHERE FileLogID = ' + CAST(@FileLogID AS VARCHAR)

	IF @Debug >= 1 PRINT CHAR(13) + 'spBcpFileStageToTarget: EXEC Row Counts: ' + CHAR(13) + @vcCmd
	
	EXEC sp_executesql @vcCmd, N'@RowCntRDSM INT OUT', @RowCntRDSM OUT

	IF @Debug >= 1 PRINT CHAR(13) + 'spBcpFileStageToTarget: @RowCntRDSM: ' + CAST(@RowCntRDSM AS VARCHAR)
	
GO
