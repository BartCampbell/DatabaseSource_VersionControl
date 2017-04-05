SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


/*************************************************************************************
Procedure:	[IHDSBuildMaster]
Author:		Leon Dowling
Copyright:	© 2012
Date:		2012.01.01
Purpose:	Mange the build process from RDS load to Dimension model build
Parameters:		@bTestBuild BIT,
				@vcTestNameChar CHAR(1),
				@bUpdateRDSM BIT,
				@vcVERISKRDSMPath VARCHAR(100),
				@bUpdateStaging BIT,
				@bRunMPI BIT,
				@bUpdateDW01 BIT,
				@bUpdateHedis BIT,
				@vcHEDISStartDate VARCHAR(8),
				@vcHEDISEndDate   VARCHAR(8),
				@vcHEDISCurYearMonth  VARCHAR(8),
				@bRunProfiles BIT,
				@bMoveToProd BIT,
				@bProcessVERISK BIT,
				@bProcessMCACO BIT,
				@dRunDate DATETIME = NULL,
				@bRunMara BIT,
				@vcMaraStartDate VARCHAR(8),
				@vcMaraEndDate VARCHAR(8),
				@vcDWStartDate VARCHAR(8),
				@vcDWEndDate VARCHAR(8),
				@bUpdateHedisV2 BIT,
				@iBatchSize INT
Depends On:	
Calls:		
Called By:	
Returns:	None
Notes:		

-- Review count of members by first character of last name
SELECT LEFT(Last_name,1), COUNT(*) FROM MMCC_IHDS_DW01_Prod.dbo.Member_dim GROUP BY LEFT(Last_name,1) ORDER BY COUNT(*) desc

-- Move DW01 TO DW01_PROD
EXEC IMI_IHDS_DW01..[usp_move_dw01_prod]	
GO
EXEC IMI_IHDS_DW01..usp_send_mail 'leon.dowling@imihealth.com', 'leon.dowling@imihealth.com', 'IMI complete', 'On IMISQL15'

-- Truncate staging	
BEGIN

	DECLARE @vcTab1 VARCHAR(100),
		@vcSQL VARCHAR(2000)

	SELECT  @vcTab1 = MIN(TableName)
	FROM BCBSA_CGF_Staging..etl_staging_Tables
	
	WHILE @vcTab1 IS NOT NULL
	BEGIN
	
		SET @vcSQL = 'TRUNCATE TABLE BCBSA_CGF_Staging..' + @vcTab1
			
		EXEC (@vcSQL)

		SELECT  @vcTab1 = MIN(TableName)
			FROM BCBSA_CGF_Staging..etl_staging_Tables
			WHERE TableName > @vcTab1

	END

END

truncate table  mpi_pre_load_dtl_member
truncate table mpi_pre_load_member
truncate table mpi_pre_load_dtl_prov
truncate table mpi_pre_load_prov


select client, count(*) from member group by client
select LEFT(NameLast,1), count(*) from imisql10.dhmp_imistaging.dbo.member group by LEFT(NameLast,1) order by count(*) desc
--SELECT LEFT(Last_name,1), COUNT(*) FROM MMCC_IHDS_DW01_Prod.dbo.Member_dim GROUP BY LEFT(Last_name,1) ORDER BY COUNT(*) desc
Process:	
Test Script: 
	EXEC IHDSBuildMaster
		@bProcessVERISK = 1,
		@vcVERISKRDSMPath  = '',
					
		@bUpdateRDSM     = 0,
		@bRunMpi		 = 1,
		@bUpdateStaging  = 1,
		@bResetStaging   = 1,
				
		@bRunProfiles	 = 0,
		@bMoveToProd     = 0


SELECT Stag_cnt = COUNT(*) FROM member
SELECT RDSM_cnt = COUNT(*) FROM RDSM.Member

select Stag_clmcnt = count(*) from claim 
select Stag_claimlinecnt = count(*) from ClaimLIneItem 
select Rdsm_ClaimLineCnt = count(*), Rdsm_Claimcnt = COUNT(DISTINCT claimnumber) FROM rdsm.ClaimInOutPatient

SELECT Stag_cnt = COUNT(*) FROM dbo.Provider
SELECT RDSM_cnt = COUNT(*) FROM RDSM.provider

select Stag_cnt = count(*) from pharmacyclaim
Select RDSM_cnt = count(*) FROM RDSM.RxClaim

ToDo:		
*************************************************************************************/


--/*
CREATE PROC [dbo].[IHDSBuildMaster]

	@bUpdateRDSM BIT = 0,
	@bUpdateStaging BIT,
	@bResetStaging BIT = 0,
	@bRunMPI BIT,
	@bRunProfiles BIT = 0,
	@bMoveToProd BIT = 0,
	
	@dRunDate DATETIME = NULL

AS
--*/

/*------------------------------------------------------------------
declare 
	
	@bUpdateRDSM BIT = 0,
	@bUpdateStaging BIT,
	@bResetStaging BIT = 0,
	@bRunMPI BIT,
	@bRunProfiles BIT = 0,
	@bMoveToProd BIT = 0,
	
	@dRunDate DATETIME = NULL
	

--SELECT LEFT(Last_name,1), COUNT(*) FROM MMCC_IHDS_DW01_Prod.dbo.Member_dim GROUP BY LEFT(Last_name,1) ORDER BY COUNT(*) desc

SELECT 

	@bUpdateRDSM     = 0,
	@bRunMpi		 = 1,
	@bUpdateStaging  = 1,
	
	@bRunProfiles	 = 0,
	@bMoveToProd     = 0,
	@dRunDate = GETDATE()
--*/------------------------------------------------------------------------------------------

IF @dRunDate IS NULL
	SET @dRunDate = GETDATE()


DECLARE @vcSQL VARCHAR(2000),
	@vcCmd VARCHAR(2000),
	@vcTab VARCHAR(100),
	@iLoadInstanceID INT


EXECUTE IMIAdmin..prInitializeInstance 'BCBSA', 'Staging Load', 0, NULL, NULL, @iLoadInstanceID OUTPUT 
--SET @iLoadInstanceID = 1074

PRINT '-----------------------------------------------------'
PRINT 'Proc: Start '
PRINT 'Start Time: ' + CONVERT(VARCHAR(20),GETDATE())
PRINT '@iLoadInstanceID: ' + CONVERT(VARCHAR(20), @iLoadInstanceID)

-- Update imiETL.BuildHistory
IF NOT EXISTS (SELECT * FROM imiETL.BuildHistory WHERE LoadInstanceID = @iLoadInstanceID)
	INSERT INTO imiETL.BuildHistory
	        (LoadInstanceID ,
	         UpdateRDSMflag ,
	         UpdateProfiles ,
	         RunMPI ,
	         UpdateStaging ,
	         RunDate
	         
	        )
	SELECT LoadInstanceID = @iLoadInstanceID,
	         UpdateRDSMflag = @bUpdateRDSM,
	         UpdateProfiles = @bRunProfiles,
	         RunMPI = @bRunMPI,
	         UpdateStaging = @bUpdateStaging,
	         RunDate = @dRunDate

IF @bUpdateRDSM = 1
BEGIN

	UPDATE imietl.BuildHistory SET RDSMUpdateStart = GETDATE()
		WHERE LoadInstanceID = @iLoadInstanceID

	DECLARE @vcMonth VARCHAR(10)
	
	--IF @bProcessVERISK = 1
	--BEGIN
		
	--	exec IMI_RDSM..prBuildVERISKTestData 
	--			@bTestBuild ,
	--			@vcTestNameChar , 
	--			@iLoadInstanceID,
	--			@iDupCnt 

	--END

	UPDATE imietl.BuildHistory SET RDSMUpdateEnd = GETDATE()
		WHERE LoadInstanceID = @iLoadInstanceID
		
END

IF @bRunMPI = 1
BEGIn

	UPDATE imietl.BuildHistory SET MPIStart = GETDATE()
		WHERE LoadInstanceID = @iLoadInstanceID
		
	PRINT '-----------------------------------------------------'
	PRINT 'Proc: Start RunMPI'
	PRINT 'Start Time: ' + CONVERT(VARCHAR(20),GETDATE())

	IF @bResetStaging = 1
	BEGIN
		TRUNCATE TABLE dbo.mpi_pre_load_dtl_member
		TRUNCATE TABLE dbo.mpi_pre_load_member
		TRUNCATE TABLE dbo.mpi_pre_load_dtl_prov
		TRUNCATE TABLE dbo.mpi_pre_load_prov
	END

	---- Update the mpi_preload_tables
    EXEC dbo.etl_mpi_preload_member
		@iLoadInstanceID = @iLoadInstanceID
	EXEC dbo.etl_mpi_preload_Provider
		@iLoadInstanceID = @iLoadInstanceID

	EXEC dbo.prBuildMPIXrefMember 
		@iLoadInstanceID = @iLoadInstanceID

	EXEC dbo.prBuildMPIXrefProvider 
		@iLoadInstanceID = @iLoadInstanceID
		
	UPDATE imietl.BuildHistory SET MPIEnd = GETDATE()
		WHERE LoadInstanceID = @iLoadInstanceID

END


IF @bUpdateStaging = 1
BEGIN

	UPDATE imietl.BuildHistory SET StagingUpdateStart = GETDATE()
		WHERE LoadInstanceID = @iLoadInstanceID

	PRINT '-----------------------------------------------------'
	PRINT 'Proc: Start UpdateStaging'
	PRINT 'Start Time: ' + CONVERT(VARCHAR(20),GETDATE())

	EXEC dbo.prProcessStaging 
		@iLoadInstanceID=@iLoadInstanceID, -- int
		@dRunDate=@dRunDate, -- datetime
		@bResetStaging = @bResetStaging
	
	UPDATE imietl.BuildHistory SET StagingUpdateEnd = GETDATE()
		WHERE LoadInstanceID = @iLoadInstanceID

END

IF @bMoveToProd = 1
BEGIN

	PRINT '-----------------------------------------------------'
	PRINT 'Proc: Start MoveToPRod'
	PRINT 'Start Time: ' + CONVERT(VARCHAR(20),GETDATE())

	EXEC dbo.prMoveStagingToProd 
		@iLoadInstanceID = @iLoadInstanceID

END

UPDATE imietl.BuildHistory SET BuildEnd = GETDATE()
	WHERE LoadInstanceID = @iLoadInstanceID

PRINT '-----------------------------------------------------'
PRINT 'Proc: END process_IMI'
PRINT 'Start Time: ' + CONVERT(VARCHAR(20),GETDATE())

--GO
SET @vcCmd = 'On ' + @@SERVERNAME 
EXEC usp_send_mail 'leon.dowling@imihealth.com', 'leon.dowling@imihealth.com', 'VERISK complete', @vcCmd



GO
