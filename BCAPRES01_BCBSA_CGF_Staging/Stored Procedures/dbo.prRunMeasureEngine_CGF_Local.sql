SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/*************************************************************************************
Procedure:	[prRunMeasureEngine]
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

EXEC prPullFromStaging
	@iCnt = 10,
	@vcTargSchema = 'T10', 
	@vcClient = 'MCCOM',
	@vcSrcStagingDB  = 'SCV_IMIStaging',
	@vcTargQIStagDB  = 'SCV_QINet_Staging'

exec prSetQiNetSyn 'T100.'

select ProductType, count(*) from eligibility group by producttype

--select count(*) from SCV_imistaging.dbo.member
--SELECT COUNT(*) FROM Member 

--select count(*) from SCV_imistaging.dbo.claimlineitem
--SELECT COUNT(*) FROM claimlineitem


EXEC [prRunMeasureEngine_CGF_Local]
	@EngineDB           = 'BCBSA_CGF_QME',
	@CalculateMbrMonths = 1,
	@FileFormatID		= 3,
	@MeasureSetID		= 28, -- Hybrid 2015
	@OwnerID			= 1, 
	@ReturnFileFormatID = 4,
	@SeedDate			= '12/31/2017',
	@bUseLatestBatchID = 0

ToDo:		
*************************************************************************************/


--/*
CREATE PROC [dbo].[prRunMeasureEngine_CGF_Local]

@EngineDB VARCHAR(50) ,
@BatchSize int = 100,
@CalculateMbrMonths BIT = 0,
@FileFormatID INT = 3,
@MeasureSetID INT = 6,
@OwnerID INT = 15,
@ReturnFileFormatID INT = 4,
@RollingMonths TINYINT = 1,
@RollingMonthsInterval INT = 1,
@SeedDate SMALLDATETIME ,
@TargetDatabase nvarchar(128) = NULL,
@Top INT = 0,
@bResetAll BIT = 0,
@iProcPerSvc INT = 5,
@bProduction BIT = 1,
@bUseLatestBatchID BIT = 0


AS
--*/
--USE SCV_PROD_QINet_MeasureEngine;

--WHILE @@TRANCOUNT > 0 ROLLBACK;

/*-----------------------------------------------------



DECLARE @EngineDB VARCHAR(50)		= NULL;
DECLARE @BatchSize INT				= 100;
DECLARE @CalculateMbrMonths BIT		= 1;
DECLARE @FileFormatID INT			= 3;	--SELECT * FROM IMI_CGF_QME.Cloud.FileFormats
DECLARE @MeasureSetID INT			= 19;	--SELECT * FROM IMI_CGF_QME.Measure.MeasureSets
DECLARE @OwnerID INT				= 1;	--SELECT * FROM IMI_CGF_QME.Batch.DataOwners
DECLARE @ReturnFileFormatID INT		= 4;	
DECLARE @RollingMonths TINYINT		= 1;
DECLARE @RollingMonthsInterval INT	= 1; 
DECLARE @SeedDate SMALLDATETIME		= NULL;
DECLARE @TargetDatabase nvarchar(128)	= NULL;
DECLARE @Top INT					= NULL;
DECLARE @bUseLatestBatchID BIT		= 0;

--*/--------------------------------------------------------

-- Parameters

DECLARE @BeginInitSeedDate smalldatetime;
DECLARE @DataRunID int;
DECLARE @DataSetID int;
DECLARE @DefaultIhdsProviderId int;
DECLARE @EndInitSeedDate smalldatetime;
DECLARE @HedisMeasureID varchar(10);
DECLARE @MeasureID int;
DECLARE @Result int;
DECLARE @Cmd VARCHAR(8000);
DECLARE @nCmd NVARCHAR(4000);

--Determined automatically:

IF @TargetDatabase IS NULL 
	SELECT @TargetDatabase = MAX(TABLE_CATALOG)
		FROM INFORMATION_SCHEMA.COLUMNS 

SELECT @BeginInitSeedDate = DATEADD(dd, 1, DATEADD(yy, -1, @SeedDate)), @EndInitSeedDate = @SeedDate;

if @bUseLatestBatchID = 1
BEGIN

	SELECT @ncmd = 'SELECT @DataSetID = MAX(DataSetID) FROM ' + @EngineDB + '.Batch.DataSets where OwnerID = ' + CONVERT(VARCHAR(10),@OwnerID)

	EXEC sp_executesql @ncmd, N'@DataSetID INT OUTPUT', @DataSEtID = @DataSetID OUTPUT

END


SET @Cmd = 'EXEC ' + @EngineDB + '.dbo.SetDbRecoveryOption @RecoveryModel = N''SIMPLE'''
EXEC (@Cmd)


/**********************************************************************************************************************/
/*** PROCESS MEASURES**************************************************************************************************/
/**********************************************************************************************************************/

SET @cmd = 'EXEC	' + @EngineDB + '.dbo.RunEngine ' + CHAR(13)
		+ '@BatchSize = 100000000, ' + CHAR(13)
		+ '@SeedDate = ''' + CONVERT(VARCHAR(8),@EndInitSeedDate,112) + ''', '  + CHAR(13)
		+ '@CalculateMbrMonths = ' + CONVERT(VARCHAR(1),@CalculateMbrMonths) + ', '  + CHAR(13)
--		+ '@DataRunID = @DataRunID OUTPUT,
		+ CASE WHEN @DataSetID IS NOT NULL THEN '@DataSetID = ' + CONVERT(VARCHAR(10),@DataSetID) + ' , ' ELSE '' END
--		+ '@EndInitSeedDate = ''' + CONVERT(VARCHAR(8),@EndInitSeedDate,112) + ''', ' + CHAR(13)
		+ '@FileFormatID = ' + CONVERT(VARCHAR(2),@FileFormatID) + ', ' + CHAR(13)
		+ '@HedisMeasureID = ' + CASE WHEN @HedisMeasureID IS NULL THEN 'NULL' ELSE CONVERT(VARCHAR(2),@HedisMeasureID) END+ ', ' + CHAR(13)
		+ '@MeasureSetID = ' + CONVERT(VARCHAR(2),@MeasureSetID) + ', ' + CHAR(13)
		+ '@OwnerID = ' + CONVERT(VARCHAR(2),@OwnerID) + ', ' + CHAR(13)
		+ '@ReturnFileFormatID = ' + CONVERT(VARCHAR(2),@ReturnFileFormatID) + ', ' + CHAR(13)
--		+ '@RollingMonths = ' + CONVERT(VARCHAR(2),@RollingMonths) + ', ' + CHAR(13)
--		+ '@RollingMonthsInterval = ' + CONVERT(VARCHAR(2),@RollingMonthsInterval) + ', ' + CHAR(13)
		+ '@TargetDatabase = ''' + @TargetDatabase + ''', ' + CHAR(13)
		+ '@Top = ' + CASE WHEN @Top IS NULL THEN 'NULL' ELSE CONVERT(VARCHAR(10),@Top) END + ';' + CHAR(13)

PRINT @Cmd
EXEC (@cmd)
--SELECT @Result AS [Result], @DataRunID AS [DataRunID], @DataSetID AS [DataSetID];

--SELECT GETDATE() AS [Date/Time Run:];
--SELECT * FROM Batch.Batches WHERE DataRunID = @DataRunID;

GO
