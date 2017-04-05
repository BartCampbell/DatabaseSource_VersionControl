SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


/****************************************************************************************************************************************************
Description:	Helper proc to call spBcpFileImport. Gets params for call given the FileLogID 
Depenedents:	etl.spBcpFileImport

Usage

DECLARE
	@LoadInstanceID INT
	,@LoadInstanceFileID INT

EXEC CHSStaging.etl.spRDSMLegacyIDsByFileLogID
	@FileLogID = 1000192 -- INT
	,@FileLogXML = '<row><FileLogID>1000192</FileLogID><FileConfigID>100082</FileConfigID><CentauriClientID>112564</CentauriClientID><FilePathIntake>\\fs01.imihealth.com\QI.Documents\Clients\PreferredOne\2017\Data\OutgoingAuditFiles_2017</FilePathIntake><FileNameIntake>t_mm_Audit_MedicalClaims_2017.txt</FileNameIntake><FileLogDate>2016-12-13T14:33:32.310</FileLogDate><RowCntImport>2592914</RowCntImport></row>'
	,@FileConfigXML = '<row><FileConfigID>100082</FileConfigID><FileProcessID>1</FileProcessID><CentauriClientID>112564</CentauriClientID><FilePathIntakeVolume>\\fs01.imihealth.com\QI.Documents</FilePathIntakeVolume><FilePathIntakePath>\Clients\PreferredOne\2017\Data\OutgoingAuditFiles_2017</FilePathIntakePath><FileNamePattern>t_mm_Audit_MedicalClaims_2017.txt</FileNamePattern><AllowDups>0</AllowDups><FreqID>0</FreqID><SQLDestServer>IMIETL04.IMIHealth.com</SQLDestServer><SQLDestDB>PREF1_RDSM</SQLDestDB><SQLDestSchema>PREF1</SQLDestSchema><SQLDestTable>Audit_MedicalClaims</SQLDestTable><EmailNotification>ETLPrecise@CentauriHS.com</EmailNotification><BcpParmColCount>51</BcpParmColCount><BcpParmFieldTerminator>|</BcpParmFieldTerminator><BcpParmRowTerminator>\n</BcpParmRowTerminator><BcpParmIsTabDelimited>0</BcpParmIsTabDelimited><BcpParmIsFixedWidth>0</BcpParmIsFixedWidth><BcpParmRemoveTextQuotes>1</BcpParmRemoveTextQuotes><HasHeader>1</HasHeader><HasFooter>0</HasFooter><RowsToSkip>0</RowsToSkip><IMIClientName>Pref1</IMIClientName><IsActive>1</IsActive><CreateDate>2016-12-13T14:26:04.143</CreateDate><LastUpdated>2016-12-13T14:26:04.143</LastUpdated></row>'
	,@LoadInstanceID = @LoadInstanceID OUTPUT-- INT OUTPUT
	,@LoadInstanceFileID = @LoadInstanceFileID OUTPUT -- INT OUTPUT
	,@Debug = 2 -- INT 

	SELECT @LoadInstanceID,@LoadInstanceFileID

Change Log:
----------------------------------------------------------------------------------------------------------------------------------------------------- 
2016-11-23	Michael Vlk			- Create
****************************************************************************************************************************************************/
CREATE PROC [etl].[spRDSMLegacyIDsByFileLogID]
	@FileLogID INT
	,@FileLogXML XML
	,@FileConfigXML XML
	,@LoadInstanceID INT OUTPUT
	,@LoadInstanceFileID INT OUTPUT
	,@Debug INT = 1
AS

	DECLARE
		@FileConfigID INT
		,@IMIClientName VARCHAR(100)		
		,@FilePathIntake VARCHAR(1000)
		,@FileNameIntake VARCHAR(1000)


	--

	SELECT
		@FilePathIntake = tr.a.value('(FilePathIntake/text())[1]', 'varchar(255)') + CASE WHEN RIGHT(tr.a.value('(FilePathIntake/text())[1]', 'varchar(255)'),1) <> '\' THEN '\' ELSE '' END
		,@FileNameIntake = tr.a.value('(FileNameIntake/text())[1]', 'varchar(255)')
	FROM @FileLogXML.nodes('/row') AS tr ( a )

	SELECT
		@FileConfigID = tr.a.value('(FileConfigID/text())[1]', 'int')
		,@IMIClientName = tr.a.value('(IMIClientName/text())[1]', 'varchar(100)')
	FROM @FileConfigXML.nodes('/row') AS tr ( a )

	IF @Debug >= 1 SELECT @FileLogID,@FileConfigID,@FilePathIntake,@FileNameIntake,@IMIClientName,@Debug

	-- 

	IF @Debug <= 1 EXECUTE IMIAdmin..prInitializeInstance @IMIClientName, 'Staging Load', 0, NULL, NULL, @LoadInstanceID OUTPUT 
	
	IF @Debug >= 1 PRINT '@LoadInstanceID: ' + CAST (@LoadInstanceID AS VARCHAR)

	--
	
	IF @Debug <= 1 
	INSERT INTO IMIAdmin.dbo.ClientProcessInstanceFile (
		LoadInstanceID,
		InboundFileName,
		InboundFilePath,
		InboundMachine,
		DateReceived
		)
	SELECT 
		LoadInstanceID  = @LoadInstanceID
		,InboundFileName = @FileNameIntake
		,InboundFilePath = @FilePathIntake
		,InboundMachine = @@SERVERNAME
		,DateReceived = GETDATE()
	
	IF @Debug <= 1 
	SELECT @LoadInstanceFileID = MAX(LoadInstanceFileID) -- SELECT *
		FROM imiadmin.dbo.ClientProcessInstanceFile 
		WHERE InboundFileName = @FileNameIntake
			AND InboundFilePath = @FilePathIntake

	IF @Debug >= 1 PRINT '@LoadInstanceFileID: ' + CAST (@LoadInstanceFileID AS VARCHAR)
	
	-- 

	IF @Debug <= 1 
	INSERT INTO CHSStaging.etl.FileLogRDSMXRef (
		FileLogID
		,LoadInstanceID
		,LoadInstanceFileID
		)
	VALUES (
		@FileLogID
		,@LoadInstanceID
		,@LoadInstanceFileID
		)







GO
