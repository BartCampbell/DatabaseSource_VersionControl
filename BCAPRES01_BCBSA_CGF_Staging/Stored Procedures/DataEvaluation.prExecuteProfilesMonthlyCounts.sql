SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/************************************************************************************* 
Procedure:	DataEvaluation.prExecuteProfilesMonthlyCounts
Author:		Leon Dowling 
Copyright:	c 2016 
Date:		2016.11.19 
Purpose:	 
Parameters: 
Depends On: 
Calls:		 
Called By:	 
Returns:	None 
Notes:		None 
Update Log: 
Test Script: 
  
exec  DataEvaluation.prExecuteProfilesMonthlyCounts

	@bDebug =1,
	@bExec  = 1,
	@vcEndOfYearDate = '20161231' ,
	@vcSpecificTargetTable  = NULL,--'Member',
	@iSpecificProfileID  = NULL
	
*************************************************************************************/  
--/*
CREATE PROC [DataEvaluation].[prExecuteProfilesMonthlyCounts]

	@bDebug BIT = 0,
	@bExec BIT = 0,
	@vcEndOfYearDate VARCHAR(8) ,
	@vcSpecificTargetTable VARCHAR(100) = 'Member',
	@iSpecificProfileID INT --= 1013


AS

DECLARE @bDebugLev2 BIT = 1

IF OBJECT_ID('tempdb..#OutputSQL') IS NOT NULL
	DROP TABLE #OutputSQL

IF OBJECT_ID('tempdb..#OutputResults') IS NOT NULL
	DROP TABLE #OutputResults

TRUNCATE TABLE dbo.HEDISDefinitionProfileMonthlyCountResults

CREATE TABLE #OutputSQL
(
	ID INT IDENTITY(1, 1)
	,ReportName VARCHAR(200)
	,ClientName VARCHAR(200)
	,ProfileID INT
	,ProfileName VARCHAR(200)
	,DBName VARCHAR(500)
	,SchemaName VARCHAR(500)
	,Order_no INT
	,SQLCommand VARCHAR(4000)
	,SourceDataFile VARCHAR(100)
	,ReturnValue VARCHAR(20)
	,bDetailReport BIT 
	,[Date] DATETIME
)

CREATE TABLE #OutputResults
(
	ProfileID INT
	,RowCt INT
	,[Date] DATETIME
)
/********TODO: NEED TO CHANGE TABLES TO VARIABLE TAGS************************************************************/
DECLARE @MaxDate VARCHAR(8) = CONVERT(VARCHAR(8), GETDATE(), 112)
DECLARE @MinDate VARCHAR(8) = CONVERT(VARCHAR(8), CONVERT (DATETIME,
							(SELECT MIN([Date])
							FROM (
											  SELECT MIN(CONVERT (DATETIME, enr_start))	AS Date FROM BCBSAZ_RDSM.VeriskFmt.EnrollmentIn		
										UNION SELECT MIN(CONVERT (DATETIME, DOS))				FROM BCBSAZ_RDSM.VeriskFmt.LabIn				
										UNION SELECT MIN(CONVERT (DATETIME, RX_SERV_DT))		FROM BCBSAZ_RDSM.VeriskFmt.RXIn				
										UNION SELECT MIN(CONVERT (DATETIME, SERV_DT))			FROM BCBSAZ_RDSM.VeriskFmt.VisitIn			
										UNION SELECT MIN(CONVERT (DATETIME, DateofService))		FROM BCBSAZ_RDSM.HEDIS2017.LabResults		
										UNION SELECT MIN(CONVERT (DATETIME, DateServiceBegin))	FROM BCBSAZ_RDSM.HEDIS2017.MedicalClaimHeader
										UNION SELECT MIN(CONVERT (DATETIME, DateEffective))		FROM BCBSAZ_RDSM.HEDIS2017.MemberEligibility  WHERE CASE WHEN ISDATE(DATEEFFECTIVE) = 0 THEN '19000101' END <> '19000101'	
										UNION SELECT MIN(CONVERT (DATETIME, DateDispensed))		FROM BCBSAZ_RDSM.HEDIS2017.PharmacyClaims	
								) A))
							,112)

;WITH DateCTE AS 
(
	SELECT DISTINCT FirstDayOfMonth AS [Date] FROM CHSStaging.dbo.DateDimension
	WHERE DateKey BETWEEN @MinDate AND @MaxDate
	--ORDER BY FirstDayOfMonth
)

INSERT INTO #OutputSQL 
(
		ReportName
		,ClientName 
		,ProfileID
		,ProfileName
		,DBName
		,SchemaName
		,Order_no
		,SourceDataFile
		,bDetailReport
		,[Date]
)
SELECT
		ReportName = r.Description
		,ClientName = rc.Client
		,dp.ProfileID
		,dp.ProfileName + CONVERT(VARCHAR(10), dt.[Date], 21) AS ProfileName
		,DBName = rc.RDSMDB
		,SchemaName = rc.RDSMSchema
		,dp.Order_no
		,SourceDataFile = rc.SourceDataFile
		,dp.bDetailReport
		,dt.[Date]
FROM DataEvaluation.ProfileDefinitionsMonthlyCount dp
INNER JOIN DataEvaluation.Report r
	ON dp.ReportId = r.ReportId
INNER JOIN DataEvaluation.ReportConfig rc
	ON r.ReportCategoryId = rc.ReportCategoryID
INNER JOIN DateCTE dt
	ON 1 = 1
ORDER BY ProfileID, Date

declare @vcCmd VARCHAR(8000),
	@vcCmd2 VARCHAR(8000),
	@i INT,
	@vcStagingTable VARCHAR(50),
	@vcRDSMDBSchemaTab VARCHAR(1000),
	@iProfileID INT,
	@vcSQLSelect VARCHAR(2000),
	@vcSQLFrom VARCHAR(2000),
	@vcSQLWhere VARCHAR(2000),
	@vcProfileName VARCHAR(1000),
	@vcMetaTag VARCHAR(50),
	@iMetaTagStartPos INT,		
	@iMetaTagLen INT,
	@vcMetaTagReplacement VARCHAR(1000),
	@vcRDSMDB VARCHAR(200),
	@vcRDSMSchema VARCHAR(200),
	@vcRDSMTab VARCHAR(200),
	@vcStandardDefinition INT,
	@vcNonStandardSQL VARCHAR(8000)

DECLARE @tTargTabList TABLE (RowId INT IDENTITY(1,1), TargTable VARCHAR(50))

INSERT INTO @tTargTabList
	SELECT DISTINCT TargTable
		FROM dbo.etl_mapping_document


--Staging Table Loop
SELECT @vcStagingTable = MIN(TargTable)
	FROM etl_mapping_Document
	WHERE TargTable = ISNULL(@vcSpecificTargetTable,TargTable)

WHILE @vcStagingtable IS NOT NULL
BEGIN
	IF @bDebug = 1 PRINT 'Process Staging Table: ' + @vcStagingTable
	-- RDSM Source Table Loop
	SELECT @vcRDSMDBSchemaTab = MIN(srcDatabase+'.'+SrcSchema+'.'+SrcTable)
		FROM etl_mapping_document
		WHERE TargTable = @vcStagingTable

	SELECT @vcRDSMDB = SrcDatabase,
		@vcRDSMSchema = SrcSchema,
		@vcRDSMTab = SrcTable
		FROM etl_mapping_document
		WHERE TargTable = @vcStagingTable
			AND @vcRDSMDBSchemaTab = srcDatabase+'.'+SrcSchema+'.'+SrcTable

	WHILE @vcRDSMDBSchemaTab IS NOT NULL
	BEGIN
		IF @bDebug = 1 PRINT 'Process RDSM Table: ' + ISNULL(@vcRDSMDBSchemaTab,'NULL')
		-- Profile Loop
		SELECT @iProfileID = MIN(ProfileID)
			FROM DataEvaluation.ProfileDefinitionsMonthlyCount dh
				INNER JOIN (SELECT DISTINCT TargTable FROM etl_Mapping_Document
								WHERE srcDatabase+'.'+SrcSchema+'.'+SrcTable = @vcRDSMDBSchemaTab
									AND TargTable = @vcStagingTable) flt
					ON dh.TargetStagingTable = flt.TargTable
			WHERE dh.ProfileID = ISNULL(@iSpecificProfileID,dh.ProfileID)

		WHILE @iProfileID IS NOT NULL
		BEGIN
			IF @bDebug = 1 PRINT 'Process ProfileID:' + ISNULL(CONVERT(VARCHAR(10),@iProfileID),'NULL')
			
			SELECT @vcProfileName = ProfileName,
					@vcSQLSelect = SELECTSQL + ' ',
					@vcSQLFrom = FROMSQL+ ' ',
					@vcSQLWhere = WHERESQL+ ' ',
					@vcStandardDefinition = bStandardDefinition,
					@vcNonStandardSQL = NonStandardSQL
				FROM DataEvaluation.ProfileDefinitionsMonthlyCount
				WHERE ProfileID = @iProfileID
			IF @bDebugLev2 = 1
			BEGIN
				PRINT '------------------------------------'
				PRINT 'ProfileName = ' + ISNULL(@vcProfileName,'NULL')
				PRINT 'SQLSelect   = ' + ISNULL(@vcSQLSelect,'NULL')
				PRINT 'SQLFrom     = ' + ISNULL(@vcSQLFrom,'NULL')
				PRINT 'SQLWhere    = ' + ISNULL(@vcSQLWhere,'NULL')
				PRINT 'StandardDefinition    = ' + ISNULL(CONVERT(VARCHAR, @vcStandardDefinition),'NULL')
				PRINT 'NonStandardSQL    = ' + ISNULL(@vcNonStandardSQL,'NULL')
			END
			
			IF ISNULL(@vcStandardDefinition, 1) = 0
			BEGIN
				SELECT @vcCmd =		@vcNonStandardSQL  + CHAR(13)
									+ 'SELECT ' + @vcSQLSelect + ', ''' +  CONVERT(VARCHAR,@iProfileID) + '''' + CHAR(13) 
									+ @vcSQLFrom + CHAR(13)
									+ ISNULL(@vcSQLWhere,'')+ CHAR(13)
			END
			ELSE 
				SELECT @vcCmd = 'SELECT ' + @vcSQLSelect + ', ''' +  CONVERT(VARCHAR,@iProfileID) + '''' + CHAR(13) 
									+ @vcSQLFrom + CHAR(13)
									+ ISNULL(@vcSQLWhere,'')+ CHAR(13)

			IF @bDebugLev2 = 1 PRINT 'SQLString = ' + @vcCmd

			SELECT @vcCmd= REPLACE(@vcCmd,'##ENDOFYEARDATE##',@vcEndOfYearDate)


			--Check for other RDSM tag
			IF CHARINDEX('.RDSMDB>',@vcCmd) > 0
			BEGIN

				SELECT @vcCmd = REPLACE(
									REPLACE(
										REPLACE(@vcCmd,'<'+TargTable+'.RDSMDB>',SrcDatabase),
										'<'+TargTable+'.RDSMSchema>',SrcSchema),
									'<'+TargTable+'.RDSMTab>',SrcTable)
					FROM dbo.etl_mapping_document
					WHERE CHARINDEX('<'+TargTable+'.RDSMDB>',@vcCmd) > 0
					AND @vcRDSMDBSchemaTab = srcDatabase+'.'+SrcSchema+'.'+SrcTable

			END

			SELECT @vcCmd= REPLACE(@vcCmd,'<' + TargTable + '.' + TargColumn + '>',SrcColumn)
			FROM dbo.etl_mapping_document
			WHERE CHARINDEX('<' + TargTable + '.' + TargColumn + '>',@vcCmd) > 0 
			AND @vcRDSMDBSchemaTab = srcDatabase+'.'+SrcSchema+'.'+SrcTable		
			
			IF @bDebug = 1 PRINT @vcCmd

			IF @bExec = 1
				--EXEC (@vcCmd)	

			IF @vcCmd is not null
			BEGIN TRY
				
				TRUNCATE TABLE #OutputResults

				INSERT INTO #OutputResults (RowCt, Date, ProfileID)
				EXEC (@vcCmd)		

				UPDATE s
				SET SQLCommand = @vcCmd
					,ReturnValue = r.RowCt
				FROM #OutputSQL s	
				INNER JOIN #OutputResults r
					ON s.ProfileID = r.ProfileID
					and s.Date = r.Date
					and s.SchemaName = @vcRDSMSchema
					and replace(s.SourceDataFile, '.txt','') = @vcRDSMTab

			END TRY BEGIN CATCH END CATCH
			
			--Select next profile
			SELECT @iProfileID = MIN(ProfileID)
				FROM DataEvaluation.ProfileDefinitionsMonthlyCount dh
					INNER JOIN (SELECT DISTINCT TargTable FROM etl_Mapping_Document
									WHERE srcDatabase+'.'+SrcSchema+'.'+SrcTable = @vcRDSMDBSchemaTab) flt
						ON dh.TargetStagingTable = flt.TargTable
				WHERE ProfileID > @iProfileID
					AND dh.ProfileID = ISNULL(@iSpecificProfileID,dh.ProfileID)


		END -- Profile Loop

		SELECT @vcRDSMDBSchemaTab = MIN(srcDatabase+'.'+SrcSchema+'.'+SrcTable)
			FROM etl_mapping_document
			WHERE TargTable = @vcStagingTable
				AND srcDatabase+'.'+SrcSchema+'.'+SrcTable > @vcRDSMDBSchemaTab

		SELECT @vcRDSMDB = SrcDatabase,
		@vcRDSMSchema = SrcSchema,
		@vcRDSMTab = SrcTable
		FROM etl_mapping_document
		WHERE TargTable = @vcStagingTable
			AND srcDatabase+'.'+SrcSchema+'.'+SrcTable = @vcRDSMDBSchemaTab

	END -- RDSM Source Table Loop

	SELECT @vcStagingTable = MIN(TargTable)
		FROM etl_mapping_Document
		WHERE TargTable = ISNULL(@vcSpecificTargetTable,TargTable)
			AND TargTable > @vcStagingTable

END--Staging Table Loop

INSERT INTO dbo.HEDISDefinitionProfileMonthlyCountResults
(
	ID
    ,ReportName
    ,ClientName
    ,ProfileID
    ,ProfileName
    ,DBName
    ,SchemaName
    ,Order_no
    ,SQLCommand
    ,SourceDataFile
    ,ReturnValue
    ,bDetailReport
	,[Date]
)
SELECT 
		ID
      ,ReportName
      ,ClientName
      ,ProfileID
      ,ProfileName
      ,DBName
      ,SchemaName
      ,Order_no
      ,SQLCommand
      ,SourceDataFile
      ,ReturnValue
      ,bDetailReport
	  ,[Date]
 FROM #OutputSQL

 DECLARE @LoadDateTime DATETIME = GETDATE()

 INSERT INTO dbo.HEDISDefinitionProfileMonthlyCountResultsHistory
(
	ID
    ,ReportName
    ,ClientName
    ,ProfileID
    ,ProfileName
    ,DBName
    ,SchemaName
    ,Order_no
    ,SQLCommand
    ,SourceDataFile
    ,ReturnValue
    ,bDetailReport
	,[Date]
	,LoadDateTime
)
SELECT 
		ID
      ,ReportName
      ,ClientName
      ,ProfileID
      ,ProfileName
      ,DBName
      ,SchemaName
      ,Order_no
      ,SQLCommand
      ,SourceDataFile
      ,ReturnValue
      ,bDetailReport
	  ,[Date]
	  ,@LoadDateTime
 FROM #OutputSQL
GO
