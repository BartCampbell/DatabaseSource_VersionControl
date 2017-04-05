SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/************************************************************************************* 
Procedure:	DataEvaluation.prExecuteProfiles
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
2016.12.01	CQT-184		MWu			Added HEDIS_TEST table/code to allow result validation against legacy code.			


Test Script: 
  
exec  DataEvaluation.prExecuteProfiles
	@bDebug =1,
	@bExec  = 1,
	@vcEndOfYearDate = '20161231' ,
	@vcSpecificTargetTable  = null,--'Claim',
	@iSpecificProfileID  = null--1114
	
*************************************************************************************/  
--/*
CREATE PROC [DataEvaluation].[prExecuteProfiles]

	@bDebug BIT = 0,
	@bExec BIT = 0,
	@vcEndOfYearDate VARCHAR(8) ,
	@vcSpecificTargetTable VARCHAR(100) = 'Member',
	@iSpecificProfileID INT --= 1013S


AS
--*/
IF 1 = 2
BEGIN
	SELECT * from DataEvaluation.ProfileDefinitions
	SELECT * from etl_mapping_document WHERE TargTable = 'ClaimLIneItem'


END

TRUNCATE TABLE dbo.HEDISDefinitionProfileResults

IF OBJECT_ID('tempdb..#OutputSQL') IS NOT NULL
	DROP TABLE #OutputSQL

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
)

SELECT
		ReportName = r.Description
		,ClientName = rc.Client
		,dp.ProfileID
		,dp.ProfileName
		,DBName = rc.RDSMDB
		,SchemaName = rc.RDSMSchema
		,dp.Order_no
		,SourceDataFile = rc.SourceDataFile
		,dp.bDetailReport
FROM DataEvaluation.ProfileDefinitions dp
INNER JOIN DataEvaluation.Report r
	ON dp.ReportId = r.ReportId
INNER JOIN DataEvaluation.ReportConfig rc
	ON r.ReportCategoryId = rc.ReportCategoryID

DECLARE @bDebugLev2 BIT = 1

declare @vcCmd VARCHAR(8000),
	@vcCmd2 VARCHAR(8000),
	@vcCmd3 VARCHAR(8000),
	@vcCmd4 VARCHAR(8000),
	@i INT,
	@vcStagingTable VARCHAR(50),
	@vcRDSMDBSchemaTab VARCHAR(1000),
	@vcRDSMDBJoinTab VARCHAR(1000),
	@vcRDSMDBJoinTab2 VARCHAR(1000),
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
	@vcCmdCheck INT,
	@vcCmdCheck2 INT

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
			FROM DataEvaluation.ProfileDefinitions dh
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
					@vcSQLWhere = WHERESQL+ ' '
				FROM DataEvaluation.ProfileDefinitions
				WHERE ProfileID = @iProfileID
			IF @bDebugLev2 = 1
			BEGIN
				PRINT '------------------------------------'
				PRINT 'ProfileName = ' + ISNULL(@vcProfileName,'NULL')
				PRINT 'SQLSelect   = ' + ISNULL(@vcSQLSelect,'NULL')
				PRINT 'SQLFrom     = ' + ISNULL(@vcSQLFrom,'NULL')
				PRINT 'SQLWhere    = ' + ISNULL(@vcSQLWhere,'NULL')
			END
			

			SELECT @vcCmd = 'SELECT ' + @vcSQLSelect + CHAR(13)
								+ @vcSQLFrom + CHAR(13)
								+ ISNULL(@vcSQLWhere,'')+ CHAR(13)
			IF @bDebugLev2 = 1 PRINT 'SQLString = ' + @vcCmd

			SELECT @vcCmd= REPLACE(@vcCmd,'##ENDOFYEARDATE##',@vcEndOfYearDate)

			--Check for other RDSM tag
			IF CHARINDEX('.RDSMDB>',@vcCmd) > 0
			BEGIN

				SELECT @vcCmd = REPLACE(
									REPLACE(
										REPLACE(@vcCmd,'[<'+TargTable+'.RDSMDB>]',SrcDatabase),
										'[<'+TargTable+'.RDSMSchema>]',SrcSchema),
									'[<'+TargTable+'.RDSMTab>]',SrcTable)
					FROM dbo.etl_mapping_document
					WHERE CHARINDEX('<'+TargTable+'.RDSMDB>]',@vcCmd) > 0
					AND @vcRDSMDBSchemaTab = srcDatabase+'.'+SrcSchema+'.'+SrcTable

			END

			SELECT @vcCmd= REPLACE(@vcCmd,'[<' + TargTable + '.' + TargColumn + '>]',SrcColumn)
			FROM dbo.etl_mapping_document
			WHERE CHARINDEX('[<' + TargTable + '.' + TargColumn + '>]',@vcCmd) > 0 	
			AND @vcRDSMDBSchemaTab = srcDatabase+'.'+SrcSchema+'.'+SrcTable


				SELECT @vcRDSMDBJoinTab = MIN(srcDatabase+'.'+SrcSchema+'.'+SrcTable)
				FROM dbo.etl_mapping_document
				WHERE CHARINDEX('[<'+TargTable+'.RDSMDB>]',@vcCmd) > 0

				select @vcCmdCheck = 0

				--JOIN LOOPS
				WHILE @vcCmdCheck = 0 AND @vcRDSMDBJoinTab IS NOT NULL
				BEGIN
					SELECT @vcCmd3 = @vcCmd

					SELECT @vcCmd3 = REPLACE(
										REPLACE(
											REPLACE(@vcCmd3,'[<'+TargTable+'.RDSMDB>]',SrcDatabase),
											'[<'+TargTable+'.RDSMSchema>]',SrcSchema),
										'[<'+TargTable+'.RDSMTab>]',SrcTable)
					FROM dbo.etl_mapping_document
					WHERE CHARINDEX('[<'+TargTable+'.RDSMDB>]',@vcCmd) > 0
					AND @vcRDSMDBJoinTab = srcDatabase+'.'+SrcSchema+'.'+SrcTable

					SELECT @vcCmd3= REPLACE(@vcCmd3,'[<' + TargTable + '.' + TargColumn + '>]',SrcColumn)
					FROM dbo.etl_mapping_document
					WHERE CHARINDEX('[<' + TargTable + '.' + TargColumn + '>]',@vcCmd) > 0 
					AND @vcRDSMDBJoinTab = srcDatabase+'.'+SrcSchema+'.'+SrcTable

					IF CHARINDEX('[<',@vcCmd3) = 0
						BEGIN
							SELECT @vcCmdCheck= 1
							SELECT @vcCmd = @vcCmd3
						END
/*************************************************************************************************************************************/

					SELECT @vcRDSMDBJoinTab2 = MIN(srcDatabase+'.'+SrcSchema+'.'+SrcTable)
					FROM dbo.etl_mapping_document
					WHERE CHARINDEX('[<'+TargTable+'.RDSMDB>]',@vcCmd3) > 0

					select @vcCmdCheck2 = 0

					--JOIN LOOPS
					WHILE @vcCmdCheck = 0 AND @vcCmdCheck2 = 0 AND @vcRDSMDBJoinTab2 IS NOT NULL
					BEGIN
						SELECT @vcCmd4 = @vcCmd3

						SELECT @vcCmd4 = REPLACE(
											REPLACE(
												REPLACE(@vcCmd4,'[<'+TargTable+'.RDSMDB>]',SrcDatabase),
												'[<'+TargTable+'.RDSMSchema>]',SrcSchema),
											'[<'+TargTable+'.RDSMTab>]',SrcTable)
						FROM dbo.etl_mapping_document
						WHERE CHARINDEX('[<'+TargTable+'.RDSMDB>]',@vcCmd3) > 0
						AND @vcRDSMDBJoinTab2 = srcDatabase+'.'+SrcSchema+'.'+SrcTable

						SELECT @vcCmd4= REPLACE(@vcCmd4,'[<' + TargTable + '.' + TargColumn + '>]',SrcColumn)
						FROM dbo.etl_mapping_document
						WHERE CHARINDEX('[<' + TargTable + '.' + TargColumn + '>]',@vcCmd3) > 0 
						AND @vcRDSMDBJoinTab2 = srcDatabase+'.'+SrcSchema+'.'+SrcTable

						IF CHARINDEX('[<',@vcCmd4) = 0
						BEGIN
							SELECT @vcCmdCheck2= 1
							SELECT @vcCmdCheck= 1
							SELECT @vcCmd = @vcCmd4
						END

						SELECT @vcRDSMDBJoinTab2 = MIN(srcDatabase+'.'+SrcSchema+'.'+SrcTable)
						FROM dbo.etl_mapping_document
						WHERE CHARINDEX('[<'+TargTable+'.RDSMDB>]',@vcCmd3) > 0
						AND srcDatabase+'.'+SrcSchema+'.'+SrcTable > @vcRDSMDBJoinTab2 	

					END


/*************************************************************************************************************************************/


					SELECT @vcRDSMDBJoinTab = MIN(srcDatabase+'.'+SrcSchema+'.'+SrcTable)
					FROM dbo.etl_mapping_document
					WHERE CHARINDEX('[<'+TargTable+'.RDSMDB>]',@vcCmd) > 0
					AND srcDatabase+'.'+SrcSchema+'.'+SrcTable > @vcRDSMDBJoinTab 	

				END


			IF @vcCmd is not null
				BEGIN TRY

				UPDATE #OutputSQL
				SET SQLCommand = @vcCmd
				WHERE ProfileID = @iProfileID		
				AND REPLACE(SourceDataFile,'.txt', '') = @vcRDSMTab

				IF @bDebug = 1 
					PRINT @vcCmd

				IF (@bExec = 1)
				BEGIN
					SELECT @vcCmd2 = 'UPDATE #OutputSQL 
										SET ReturnValue = (' + @vcCmd + ')
									WHERE ProfileID = ' + CONVERT(varchar(4), @iProfileID)+
									' AND REPLACE(SourceDataFile,''.txt'', '''') = '''+@vcRDSMTab+''''
								 
						FROM #OutputSQL
						WHERE ProfileID = @iProfileID

					IF @bDebug = 1 
						PRINT @vcCmd2
						
					EXEC (@vcCmd2)
				END 
				ELSE 
					UPDATE #OutputSQL 
					SET ReturnValue = 'N/A'
					WHERE ProfileID = @iProfileID

				END TRY BEGIN CATCH END CATCH
			--Select next profile
			SELECT @iProfileID = MIN(ProfileID)
				FROM DataEvaluation.ProfileDefinitions dh
					INNER JOIN (SELECT DISTINCT TargTable FROM etl_Mapping_Document
									WHERE srcDatabase+'.'+SrcSchema+'.'+SrcTable = @vcRDSMDBSchemaTab) flt
						ON dh.TargetStagingTable = flt.TargTable
				WHERE ProfileID > @iProfileID
					AND dh.ProfileID = ISNULL(@iSpecificProfileID,dh.ProfileID)

		END-- Profile Loop

		SELECT @vcRDSMDBSchemaTab = MIN(srcDatabase+'.'+SrcSchema+'.'+SrcTable)
			FROM etl_mapping_document
			WHERE TargTable = @vcStagingTable
				--AND @vcRDSMDBSchemaTab = srcDatabase+'.'+SrcSchema+'.'+SrcTable
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

INSERT INTO dbo.HEDISDefinitionProfileResults
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
 FROM #OutputSQL

 DECLARE @LoadDateTime DATETIME = GETDATE()

 INSERT INTO dbo.HEDISDefinitionProfileResultsHistory
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
	  ,@LoadDateTime
 FROM #OutputSQL
GO
