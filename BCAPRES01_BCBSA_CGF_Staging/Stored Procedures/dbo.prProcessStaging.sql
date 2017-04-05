SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO







/*************************************************************************************
Procedure:	prProcessStaging
Author:		Dennis Deming
Copyright:	© 2008
Date:		2008.04.14
Purpose:	To manage the IMI Load Process, Step 1
Parameters:	@iLoadInstanceID	int..............OPT...IMIAdmin..ClientProcessInstance.LoadInstanceID
		@vcClient		varchar( 100 )...OPT...IMIAdmin..Client.ClientName
		@vcLoadType		varchar( 100 )...OPT...IMIAdmin..Process.Description
		@bitIsIncremental	bit..............OPT...1 = Load is incremental
Depends On:	dbo.Claim
		dbo.ClaimExtension
		dbo.ClaimLineItem
		dbo.ClaimLineItemExtension
		dbo.Eligibility
		dbo.EligibilityExtension
		dbo.etl_client_build
		dbo.Member
 		dbo.MemberExtension
		dbo.MemberProvider
		dbo.Pharmacy
		dbo.PharmacyClaim
		dbo.PharmacyClaimDeleted
		dbo.PharmacyClaimExtension
		dbo.PharmacyClaimRejected
		dbo.PharmacyExtension
		dbo.Provider
		dbo.ProviderAddress
		dbo.ProviderExtension
		dbo.ProviderMedicalGroup
		dbo.ProviderSpecialty
		IMIAdmin..vwClientProcessInstance
		IMIAdmin..ClientProcessInstanceMetrics
		IMIAdmin..StatusLog 
Calls:		dbo.etl_build_client_proc
		dbo.etl_prLoadDataStore_@vcClient
		dbo.prBuildMPIXref
		dbo.prRefreshAlchemyXref
		dbo.prRunProcessTest
		IMIAdmin..fxSetStatus
		IMIAdmin..prInitializeInstance
Called By:	prLoadDataStore
Returns:	0 = success
Notes:		None
Process:	1.	Declare/initialize variables
		2.	Validate parameters
		3.	Run IMIAdmin..prInitializeInstance as required
		4.	Run Level 1 Profiles (Rem Out per MWS)
		5.1 Remove auto statistics
		5.2	Delete existing data for the client
		6.	Get the mpi preload data
		7.	Build the MPI Output (Rem Out per MWS)
		8.	Refresh alchemy data
		9.	Build the IMIStaging files
		10.	UPDATE ihds_pharmacyclaim_id 
		11. Test the IMIStaging build
UpdateLoag 
3/30/2017 - Leon: Update For BCBSA
Test Script:	

	EXECUTE [prProcessStaging]
		@iLoadInstanceID = 1,
		@vcClient	= null,--'Etransx',
		@dRunDate = NULL,
		@bIncrementalUpdate = 0,
		@bResetStaging = 1,
		@bLoadCHSData BIT = 0

select  * 
	from etl_staging_table_stat
	WHERE RunDate = (SELECT MAX(RunDate) from etl_staging_table_stat)

ToDo:		
*************************************************************************************/
--/*
CREATE PROCEDURE [dbo].[prProcessStaging]
	@iLoadInstanceID	int = NULL,
	@vcClient		varchar( 100 ) = NULL,
	@dRunDate DATETIME = NULL,
	@bIncrementalUpdate BIT = 0,
	@bResetStaging BIT = 0
AS
--*/

/*----------------------------------------------
DECLARE @iLoadInstanceID	int = NULL,
	@vcClient		varchar( 100 ) = NULL,
	@dRunDate DATETIME = NULL

DECLARE @bIncrementalUpdate BIT = 0
DECLARE @bResetStaging BIT = 0

SELECT @dRunDate = GETDATE(),
	@iLoadInstanceID = 1
--*/----------------------------------------------	
--Begin normal run of loading the IMIStaging
BEGIN TRY
--	SET NOCOUNT ON

	IF @iLoadInstanceID IS NULL 
		--DECLARE @iLoadInstanceID INT
		EXECUTE IMIAdmin..prInitializeInstance 'VERISK', 'Staging Load', 0, NULL, NULL, @iLoadInstanceID OUTPUT 
	
	

	/*************************************************************************************
		1.	Declare/initialize variables
	*************************************************************************************/
	DECLARE	@iClientBuild	int,
		@iLogIDBegin	int,
		@iLogIDEnd	int,
		@sysMe		sysname,
		@vcOutput	varchar( 255 ),
		@vcSQL		varchar( max ),
		@nvcSQL	    NVARCHAR(2000),
		@vcTab VARCHAR(1000),
		@iCnt INT,
		@iCnt2 INT,
		@guidLoadGuid UNIQUEIDENTIFIER

	IF @dRunDate IS NULL
		SET @dRunDate = GETDATE()

	SET @sysMe = OBJECT_NAME( @@PROCID )

	-- Capture StatusLogID into @iLogIDBegin so we can update the LoadInstanceID later
    EXECUTE IMIAdmin..fxSetStatus @iLoadInstanceID, @sysMe, 'Started', NULL, @iLogIDBegin OUTPUT

	-- Log the code used to execute this run
	SET @vcOutput = 'Execution: prProcessStaging' +  
		' @iLoadInstanceID = ' + ISNULL( CAST( @iLoadInstanceID AS varchar( 12 )), 'NULL' ) + 
		', @vcClient = ' + ISNULL( '''' + @vcClient + '''', 'NULL' )  

	EXECUTE IMIAdmin.dbo.fxSetMetrics @iLoadInstanceID, 'prProcessStaging Started', 0, 'prProcessStaging', 'prProcessStaging Started', 0

    EXECUTE IMIAdmin..fxSetStatus @iLoadInstanceID, @sysMe, 'Running', @vcOutput


	INSERT INTO etl_LoadControl 
		(LoadInstanceID ,
		LoadGuid ,
		LoadStartDate ,
		MemberIncrFlag)
	SELECT @iLoadInstanceID,
		LoadGuid = NEWID(),
		LoadStartDate = GETDATE(),
		MemberIncrFlag = @bIncrementalUpdate

	SELECT @guidLoadGuid = LoadGuid
		FROM etl_LoadControl
		WHERE LoadInstanceID = @iLoadInstanceID


	/*************************************************************************************
		2.	Validate parameters
	*************************************************************************************/

	/*************************************************************************************
		3.	Run IMIAdmin..prInitializeInstance as required
	*************************************************************************************/
	
	/*************************************************************************************
		4.	Run Level 1 Profiles
	*************************************************************************************/
	/*************************************************************************************
		5.0	Remove auto stats from all base tables
	*************************************************************************************/
	EXECUTE IMIAdmin.dbo.fxSetMetrics @iLoadInstanceID, 'usp_remove_auto_stats started', 0, 'prProcessStaging', 'usp_remove_auto_stats started', 0

	SELECT  @vcTab = MIN(TableName)
		FROM etl_staging_Tables
		
	WHILE @vcTab IS NOT NULL
	BEGIN
	
		EXEC usp_remove_auto_stats @lcTab = @vcTab  , @lbexec = 1, @lbReCreateIndex = 0

		SELECT  @vcTab = MIN(TableName)
			FROM etl_staging_Tables
			WHERE TableName > @vcTab

	END

	/*************************************************************************************
		5.1	Capture Rec Count of Staging Tables Pre ETL
	*************************************************************************************/

	DELETE	
		FROM dbo.etl_staging_table_stat
		WHERE LoadInstanceID = @iLoadInstanceID


	SELECT  @vcTab = MIN(TableName)
		FROM etl_staging_Tables
		
	WHILE @vcTab IS NOT NULL
	BEGIN
	
		SELECT @vcSql = 'INSERT INTO dbo.etl_staging_table_stat ' + CHAR(13)
						+'			( RunDate , ' + CHAR(13)
						+'			  LoadInstanceID , ' + CHAR(13)
						+'			  StartTime , ' + CHAR(13)
						+'			  Client , ' + CHAR(13)
						+'			  StagingTableName , ' + CHAR(13)
						+'			  PreETLRecordCount  ' + CHAR(13)
						+'			) ' + CHAR(13)
						+'	SELECT RunDate = ''' + CONVERT(VARCHAR(20),@dRunDate) + ''', ' + CHAR(13)
						+'			LoadInstanceID = '+CONVERT(VARCHAR(10),@iLoadInstanceID) + ', ' + CHAR(13)
						+'			StartTime = GETDATE(), ' + CHAR(13)
						+'			Client , ' + CHAR(13)
						+'			StagingTableName = ''' + @vcTab + ''',' + CHAR(13)
						+'			PreETLRecordCount = COUNT(*) ' + CHAR(13)
						+'		FROM ' + @vcTab  + CHAR(13)
						+'		GROUP BY Client ' 
		
		
		PRINT @vcSQL

		EXEC (@vcSQL)		

		SELECT  @vcTab = MIN(TableName)
			FROM etl_staging_Tables
			WHERE TableName > @vcTab

	END


	/*************************************************************************************
		5.2	Delete existing data for the client
	*************************************************************************************/
	EXECUTE IMIAdmin.dbo.fxSetMetrics @iLoadInstanceID, 'Deletes started', 0, 'prProcessStaging', 'Deletes started', 0

	IF @bIncrementalUpdate = 0
	BEGIN
		SET @vcSQL = 'Delete for client: ' + @vcClient

		SELECT  @vcTab = MIN(TableName)
			FROM etl_staging_Tables
			
		WHILE @vcTab IS NOT NULL
		BEGIN
		
			IF @vcClient IS NULL
					OR @bResetStaging = 1
			BEGIN
				SET @nvcSQL = N'SELECT @iCnt = COUNT(*) FROM ' + @vcTab 
				EXEC sp_executesql @nvcSQL, N'@iCnt INT OUTPUT',@iCnt OUTPUT
				
				SET @vcSQL = 'TRUNCATE TABLE ' + @vcTab
				PRINT @vcSql
				EXEC (@vcSQL)
			
			END
			ELSE 
			BEGIN

				SET @nvcSQL = N'SELECT @iCnt = COUNT(*) FROM ' + @vcTab 
				EXEC sp_executesql @nvcSQL, N'@iCnt INT OUTPUT',@iCnt OUTPUT

				SET @nvcSQL = N'SELECT @iCnt2 = COUNT(*) FROM ' + @vcTab + ' WHERE Client = ''' + @vcClient + ''''
				EXEC sp_executesql @nvcSQL, N'@iCnt2 INT OUTPUT',@iCnt2 OUTPUT

				IF @iCnt = @iCnt2
				BEGIN
					SET @vcSQL = 'TRUNCATE TABLE ' + @vcTab
					EXEC (@vcSQL)
					
				END
				ELSE
				BEGIN
					SET @vcSQL = 'DELETE FROM ' + @vcTab + ' WHERE client = '''+@vcClient+''''
					EXEC (@vcSQL)
					SET @iCnt = @@ROWCOUNT
				END
			END
			
			EXECUTE IMIAdmin.dbo.fxSetMetrics 
				@iLoadInstanceID, 
				'Records Deleted', 
				@iCnt, 
				@vcTab, 
				@vcSQL , 
				@iCnt

			SELECT  @vcTab = MIN(TableName)
				FROM etl_staging_Tables
				WHERE TableName > @vcTab

		END
	END
	    
	/*************************************************************************************
		9.	Build the IMIStaging files
	*************************************************************************************/
	BEGIN
		EXEC dbo.etl_BCBSA_Member 
			@iLoadInstanceID = @iLoadInstanceID

		EXEC dbo.etl_BCBSA_Eligibility
			@iLoadInstanceID = @iLoadInstanceID
			
		EXEC dbo.etl_BCBSA_Provider
			@iLoadInstanceID = @iLoadInstanceID

		--EXEC etl_BCBSA_ProviderMedicalgroup 
		--	@iLoadInstanceID = @iLoadInstanceID

		--EXEC etl_BCBSA_MemberProvider
		--	@iLoadInstanceID = @iLoadInstanceID

		EXEC dbo.etl_BCBSA_MedicalClaims
			@iLoadInstanceID = @iLoadInstanceID
	
		EXEC dbo.etl_BCBSA_PharmacyClaim
			@iLoadInstanceID = @iLoadInstanceID

		--EXEC etl_BCBSA_LabResult
		--	@iLoadInstanceID = @iLoadInstanceID

		--EXEC dbo.etl_BCBSA_SupplementalClaims
		--	@iLoadInstanceID = @iLoadInstanceID

	END


	/*************************************************************************************
		10.	Capture Rec Count of Staging Tables Post ETL
	*************************************************************************************/

	SELECT  @vcTab = MIN(TableName)
		FROM etl_staging_Tables
		
	WHILE @vcTab IS NOT NULL
	BEGIN

		SELECT @vcSql = 'UPDATE a ' + CHAR(13)
						+' SET StopTime = GETDATE(), ' + CHAR(13)
						+'	PostETLRecordCount = b.cnt ' + CHAR(13)
						+' FROM dbo.etl_staging_table_stat a ' + CHAR(13)
						+'	INNER JOIN (SELECT client, COUNT(*) cnt FROM ' + @vcTab + ' GROUP BY client) b ' + CHAR(13)
						+'		ON a.client = b.client  ' + CHAR(13)
						+' WHERE a.LoadInstanceID = ' + CONVERT(VARCHAR(10),@iLoadInstanceID) + CHAR(13)
						+'	AND a.RunDate = ''' + CONVERT(VARCHAR(20),@dRunDate)+'''' + CHAR(13)  
						+'  AND a.StagingTableName = ''' + @vcTab + ''''
		
		PRINT @vcSQL
		EXEC (@vcSQL)		

		SELECT  @vcTab = MIN(TableName)
			FROM etl_staging_Tables
			WHERE TableName > @vcTab

	END

	EXECUTE IMIAdmin..fxSetStatus @iLoadInstanceID, @sysMe, 'Completed'
--/*
END TRY

BEGIN CATCH
	DECLARE	@iErrorLine		int, 
		@iErrorNumber		int,
		@iErrorSeverity		int,
		@iErrorState		int,
		@nvcErrorMessage	nvarchar( 2048 ), 
		@nvcErrorProcedure	nvarchar( 126 )

	-- capture error info so we can fail it up the line
	SELECT	@iErrorLine = ERROR_LINE(),
		@iErrorNumber = ERROR_NUMBER(),
		@iErrorSeverity = ERROR_SEVERITY(),
		@iErrorState = ERROR_STATE(),
		@nvcErrorMessage = ERROR_MESSAGE(),
		@nvcErrorProcedure = ERROR_PROCEDURE()
		
	INSERT INTO IMIAdmin..ErrorLog( ErrorLine, ErrorMessage, ErrorNumber, ErrorProcedure, ErrorSeverity,
		ErrorState, ErrorTime, InstanceID, UserName )
	SELECT	@iErrorLine, @nvcErrorMessage, @iErrorNumber, @nvcErrorProcedure, @iErrorSeverity,
		@iErrorState, GETDATE(), InstanceID, SUSER_SNAME()
	FROM	IMIAdmin..ClientProcessInstance
	WHERE	LoadInstanceID = @iLoadInstanceID
	
        EXECUTE IMIAdmin..fxSetStatus @iLoadInstanceID, @sysMe, 'Failed'
	
	RAISERROR( @nvcErrorMessage, @iErrorSeverity, @iErrorState );
END CATCH
--*/

GO
