SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


/*************************************************************************************
Procedure:	CGF.prRunQME
Author:		Leon Dowling
Copyright:	© 2014
Date:		2014.01.01
Purpose:	
Parameters: 
Depends On:	
Calls:		
Called By:	
Returns:	None
Notes:		
Update Log:
8/20/2014 - Add SrcServer
8/22/2014 - Add move to prod, add @VcSeeDate parameter
Process:	
Test Script: 

-- Make sure engines are on:
exec imisql15.imi_qinet_mastercontrol.dbo.[prQMEServiceStatus]


EXEC CGF.prRunQME
	@bUpdateQInetStaging = 1,
	@bRunMeasureEngine   = 1,
	@bPullResults        = 1,
	@bMoveToProd = 0,
	@iMemberCountLimit   = NULL,
	@vcSeedDate = '20131231'

GO
EXEC usp_send_mail 'leon.dowling@imihealth.com', 'leon.dowling@imihealth.com', 'DHMP QME complete', 'On IMIETL01'


*/

CREATE PROC [CGF].[prRunQME]

@bUpdateQInetStaging BIT = 0,
@bRunMeasureEngine BIT = 0,
@bPullResults BIT = 0,
@iMemberCountLimit INT = NULL,
@bMoveToProd BIT = 0,
@vcSeedDate VARCHAR(8) = NULL

AS

/*---------------------------------------------------
DECLARE @bUpdateQInetStaging BIT = 1
DECLARE @bRunMeasureEngine BIT = 1
DECLARE @bPullResults BIT = 1
DECLARE @iMemberCountLimit INT = 100
--*/-------------------------------------------------

DECLARE @bDebug BIT = 1
DECLARE @bExec BIT = 1

DECLARE @vcCmd VARCHAR(MAX)
--,	@vcSeedDate VARCHAR(8)

-- Make sure Config is current
EXEC cgf.prClientConfig

-- Pull data from Staging to QINet Staging
IF @bUpdateQInetStaging = 1
BEGIN
	
	SELECT @vcCmd = 'EXEC ' + cc.QME_Staging_Server 
						+ '.' + cc.QME_Staging_DB
						+ '.dbo.prPullFromStaging ' + CHAR(13)
						+ ' @iCnt = ' + CASE WHEN @iMemberCountLimit IS NULL THEN 'NULL' 
											ELSE CONVERT(VARCHAR(10),@iMemberCountLimit)
											END + ', ' + CHAR(13)
						+ ' @vcTargSchema = ''' + cc.QME_FullBuildSchema + ''',' + CHAR(13)
						+ ' @vcClient = NULL, '+ CHAR(13)
						+ ' @vcSrcStagingDB = ''' + cc.IMIStaging_DB + ''',' + CHAR(13)
						+ ' @vcSrcStagingServer = ''' + cc.IMIStaging_Server + ''',' + CHAR(13)
						+ ' @vcTargQIStagDB = ''' + cc.QME_Staging_DB + ''''
		FROM cgf.ClientConfig cc

	IF @bDebug = 1
		PRINT @vcCmD
	IF @bExec = 1	
		EXEC (@vcCmd)

	/*
	EXEC [prPullFromStaging] 
		@iCnt = NULL,
		@vcTargSchema = 'StFranFULL',
		@vcClient = NULL ,
		@vcSrcStagingDB = 'STFRAN_IMIStaging' ,
		@vcTargQIStagDB = 'STFRAN_QINET_Staging'
	*/

	SELECT @vcCmd = cc.QME_Staging_Server 
						+ '.' + cc.QME_Staging_DB
						+ '.dbo.prSetQiNetSyn ' 
						+ '''' + QME_FullBuildSchema + '.'''		
			FROM cgf.ClientConfig cc
	IF @bDebug = 1
		PRINT @vcCmD
	IF @bExec = 1	
		EXEC (@vcCmd)

	--EXEC prSetQiNetSyn 'StFranFULL.'

	/*	
	SELECT Client, COUNT(*) FROM member GROUP BY Client
	SELECT Client, COUNT(*) FROM STFRAN_QINet_Staging.dbo.Member GROUP BY Client
	*/


END

IF @bRunMeasureEngine = 1
BEGIN

	IF @vcSeedDate IS NULL 
		SELECT @vcSeedDate = CONVERT(VARCHAR(8),
									DATEADD(m,(-1*SeedDateLagMonths),
											LEFT(CONVERT(VARCHAR(8),GETDATE(),112),6)+'01')-1,
									112)
			FROM cgf.ClientConfig cc

	SELECT @vcCmd = cc.QME_Staging_Server 
						+ '.' + cc.QME_Staging_DB
						+ '.dbo.prRunMeasureEngine_PROD ' + CHAR(13)
			+'@EngineDB			= ''' + QME_DB + ''',' + CHAR(13)
			+'@BatchSize		= 100, '+ CHAR(13)
			+'@CalculateMbrMonths = 1, ' + CHAR(13)
			+'@FileFormatID		= 3, ' + CHAR(13)
			+'@MeasureSetID		= ' + CONVERT(VARCHAR(2),QME_MeasureSetID)+' , '+ CHAR(13)
			+'@OwnerID			= ' + CONVERT(VARCHAR(2),QME_OwnerID)+' , '+ CHAR(13)
			+'@ReturnFileFormatID = 4, ' + CHAR(13)
			+'@RollingMonths		= ' + CONVERT(VARCHAR(2),RollingMonths)+' , '+ CHAR(13)
			+'@RollingMonthsInterval = ' + CONVERT(VARCHAR(2),RollingMonthsInterval) + ', ' + CHAR(13)
			+'@SeedDate			= ''' + @vcSeedDate + ''', '+ CHAR(13)
			+'@bProduction		= 1 , ' + CHAR(13)
			+'@bUseLatestBatchID  = 0 '			+ CHAR(13)
		FROM cgf.ClientConfig cc

	IF @bDebug = 1
		PRINT @vcCmD
	IF @bExec = 1	
		EXEC (@vcCmd)

	/*EXEC StFran_QiNet_Staging.[dbo].[prRunMeasureEngine_PROD]
		@EngineDB			= 'STFRAN_PROD_QME',
		@BatchSize			= 100,
		@CalculateMbrMonths = 1,
		@FileFormatID		= 3,
		@MeasureSetID		= 9,
		@OwnerID			= 1,
		@ReturnFileFormatID = 4,
		@RollingMonths		= 1,
		@SeedDate			= '03/31/2014',
		@bProduction		= 1,
		@bUseLatestBatchID  = 0
	*/

	DECLARE @iMaxDataRunID INT
	SELECT @iMaxDataRunID = MAX(DataRunID) FROM CGF_SYN.DataRuns WITH (NOLOCK)

	WHILE EXISTS
		(SELECT DISTINCT  a.*, bb.BatchStatusID
			FROM CGF_SYN.Batches a WITH (NOLOCK)
				INNER JOIN CGF_SYN.DataRuns dr WITH (NOLOCK)
					ON a.DataRunID = dr.DataRunID
					AND dr.DataRunID = @iMaxDataRunID
				LEFT JOIN imietl03.MeasureEngine_Controller.batch.Batches bb WITH (NOLOCK)
					ON bb.SourceGuid = a.BatchGuid
			WHERE ISNULL(bb.batchstatusid,0) <> 32767
		) 
		WAITFOR DELAY '00:01:00'


END

IF @bPullResults = 1
BEGIN

	EXEC [CGF].[prBuildResultTables] 
		@bMinDataRunID	= NULL,
		@bMaxDataRunID	= NULL,
		@vcFilterInit	= NULL


END

IF @bMoveToProd = 1
BEGIN

	DECLARE @vcIMIStaging_Prod_Server VARCHAR(100),
		@vcIMIStaging_PRod_DB VARCHAR(100)
	
	SELECT 	@vcIMIStaging_Prod_Server = IMIStaging_Prod_Server,
			@vcIMIStaging_PRod_DB = IMIStaging_PRod_DB
		FROM cgf.ClientConfig

	EXEC [CGF].[prMoveToProd] @vcIMIStaging_PRod_DB


END

EXEC usp_send_mail 'leon.dowling@imihealth.com', 'leon.dowling@imihealth.com', 'STFRAN QME complete', 'On IMIETL01'

GO
