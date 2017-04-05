SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/*************************************************************************************
Procedure:	imietl.prRDSMStagingQME_DiffReport
Author:		Leon Dowling
Copyright:	© 2016
Date:		2016.01.01
Purpose:	
Parameters: 
Depends On:	
Calls:		
Called By:	
Returns:	None
Notes:		
Update Log:
12/29/2016 - Remove link for RDSM Eligibility to mpi_output_member
Test Script: 

exec [imiETL].[prRDSMStagingQME_DiffReport]
	@iLoadInstanceID = 1,
	@bDebug			= 1,
	@vcQMESQLServer = 'IMIETL05',
	@vcQMEDB 		= 'BCBSAZ_HEDIS2017_QME',
	@vcQMEStagDB	 = 'BCBSAZ_QINet_Staging',
	@vcQMEStagSchema = 'QI2017Feb',
	@iDataSEtId      = 6

SELECT SrcTabDB, SrcTabSchema, SrcTabName, RejecteReason, COUNT(*) cnt
	FROM BCBSA_CGF_Staging.dbo.Labresult_Rejected
	GROUP BY SrcTabDB, SrcTabSchema, SrcTabName, RejecteReason
UNION
SELECT SrcTabDB, SrcTabSchema, SrcTabName, RejecteReason, COUNT(*) cnt
	FROM BCBSA_CGF_Staging.dbo.MedicalClaim_Rejected
	GROUP BY SrcTabDB, SrcTabSchema, SrcTabName, RejecteReason
UNION
SELECT SrcTabDB, SrcTabSchema, SrcTabName, RejecteReason, COUNT(*) cnt
	FROM BCBSA_CGF_Staging.dbo.PharmacyClaim_Rejected
	GROUP BY SrcTabDB, SrcTabSchema, SrcTabName, RejecteReason
UNION
SELECT SrcTabDB, SrcTabSchema, SrcTabName, RejecteReason, COUNT(*) cnt
	FROM BCBSA_CGF_Staging.dbo.SupplementalClaim_Rejected
	GROUP BY SrcTabDB, SrcTabSchema, SrcTabName, RejecteReason

*/
--SELECT * FROM BCBSAZ_HEDIS2017_QME.Batch.DataRuns
--/*
CREATE PROC [imiETL].[prRDSMStagingQME_DiffReport]

	@iLoadInstanceID INT = 1,
	@bDebug BIT = 0,
	@vcQMESQLServer VARCHAR(50) = 'IMIETL05',
	@vcQMEDB VARCHAR(50)		= 'BCBSAZ_HEDIS2017_QME',
	@vcQMEStagDB	VARCHAR(50)	 = 'BCBSAZ_QINet_Staging',
	@vcQMEStagSchema VARCHAR(50) = 'QI2017Jan',
	@iDataSEtID INT



AS
--*/
/*--------------------------------
DECLARE @iLoadInstanceID INT = 1,
	@bDebug BIT = 1

--*/------------------------------


DECLARE @vcCmd VARCHAR(8000),
	@vcCmd2 VARCHAR(8000),
	@nvCmd NVARCHAR(4000),
	@nvCmd2 NVARCHAR(4000),
	@i INT


-- Config Table
IF OBJECT_ID('tempdb..#config') IS NOT NULL 
	DROP TABLE #config

CREATE TABLE #config
	(RowID INT IDENTITY(1,1),
	Valtype VARCHAR(50),

	SourceSystem VARCHAR(50),
	Client VARCHAR(20),

	RDSMDB VARCHAR(50),
	RDSMSchema VARCHAR(50),
	RDSMTab VARCHAR(50),

	RDSMRejDB VARCHAR(50),
	RDSMRejSchema VARCHAR(50),
	RDSMRejTab VARCHAR(50),

	StagDB VARCHAR(50),
	StagSchema VARCHAR(50),
	StagTab VARCHAR(50),
	StagDataSource VARCHAR(50),

	QMEStagDB VARCHAR(50),
	QMEStagSchema VARCHAR(50),
	QMEStagTab VARCHAR(50),

	QMESQLServer VARCHAR(50),
	QMEDB VARCHAR(50),
	QMEDataSource VARCHAR(50))

/*Old Verisk Format

INSERT into #config
    SELECT 
		Valtype		= 'Encounter',
		SourceSystem = 'ClientExtract',
		Client      = 'BCBSAZ',
		RDSMDB		= 'BCBSAZ_RDSM',
		RDSMSchema	= 'VERISKFMT',
		RDSMTab		= 'VisitIn',

		RDSMRejDB	= 'BCBSA_CGF_Staging',
		RDSMRejSchema = 'dbo',
		RDSMRejTab	= 'MedicalClaim_Rejected',

		StagDB		= 'BCBSA_CGF_Staging',
		StagSchema	= 'dbo',
		StagTab		= 'ClaimLineItem',
		StagDataSource = 'VeriskFmt.VisitIN',

		QMEStagDB	= @vcQMEStagDB,
		QMEStagSchema = @vcQMEStagSchema,
		QMEStagTab	= 'ClaimLineItem',

		QMESqlServer = @vcQMESQLServer,
		QMEDB                    = @vcQMEDB,
		QMEDataSource='VeriskFmt.VisitIN'

    UNION 
	SELECT 
		Valtype		= 'Member',
		SourceSystem = 'ClientExtract',
		Client      = 'BCBSAZ',
		RDSMDB		= 'BCBSAZ_RDSM',
		RDSMSchema	= 'VERISKFMT',
		RDSMTab		= 'MemberIn',

		RDSMRejDB	= NULL,
		RDSMRejSchema = NULL,
		RDSMRejTab	= NULL,

		StagDB		= 'BCBSA_CGF_Staging',
		StagSchema	= 'dbo',
		StagTab		= 'Member',
		StagDataSource = 'VeriskFmt.MemberIn',

		QMEStagDB	= @vcQMEStagDB,
		QMEStagSchema = @vcQMEStagSchema,
		QMEStagTab	= 'Member',

		QMESqlServer = @vcQMESQLServer,
		QMEDB                    = @vcQMEDB,
		QMEDataSource= 'VeriskFmt.MemberIn'

	UNION
    SELECT 
		Valtype		= 'Encounter',
		SourceSystem = 'ClientExtract',
		Client      = 'BCBSAZ',
		RDSMDB		= 'BCBSAZ_RDSM',
		RDSMSchema	= 'VERISKFMT',
		RDSMTab		= 'RxIn',

		RDSMRejDB	= NULL,
		RDSMRejSchema = NULL,
		RDSMRejTab	= NULL,

		StagDB		= 'BCBSA_CGF_Staging',
		StagSchema	= 'dbo',
		StagTab		= 'PharmacyClaim',
		StagDataSource = 'VeriskFmt.RXIn',

		QMEStagDB	= @vcQMEStagDB,
		QMEStagSchema = @vcQMEStagSchema,
		QMEStagTab	= 'PharmacyClaim',
		
		QMESqlServer = @vcQMESQLServer,
		QMEDB                    = @vcQMEDB,
		QMEDataSource='VeriskFmt.RXIn'

	UNION
    SELECT 
		Valtype		= 'Encounter',
		SourceSystem = 'ClientExtract',
		Client      = 'BCBSAZ',
		RDSMDB		= 'BCBSAZ_RDSM',
		RDSMSchema	= 'VERISKFMT',
		RDSMTab		= 'LabIn',

		RDSMRejDB	= NULL,
		RDSMRejSchema = NULL,
		RDSMRejTab	= NULL,

		StagDB		= 'BCBSA_CGF_Staging',
		StagSchema	= 'dbo',
		StagTab		= 'LabResult',
		StagDataSource = 'VeriskFmt.LabIn',

		QMEStagDB	= @vcQMEStagDB,
		QMEStagSchema = @vcQMEStagSchema,
		QMEStagTab	= 'LabResult',

		QMESqlServer = @vcQMESQLServer,
		QMEDB                    = @vcQMEDB,
		QMEDataSource='VeriskFmt.LabIn'

	UNION
    SELECT 
		Valtype		= 'Eligibility',
		SourceSystem = 'ClientExtract',
		Client      = 'BCBSAZ',
		RDSMDB		= 'BCBSAZ_RDSM',
		RDSMSchema	= 'VERISKFMT',
		RDSMTab		= 'EnrollmentIn',

		RDSMRejDB	= NULL,
		RDSMRejSchema = NULL,
		RDSMRejTab	= NULL,

		StagDB		= 'BCBSA_CGF_Staging',
		StagSchema	= 'dbo',
		StagTab		= 'Eligibility',
		StagDataSource = 'VeriskFmt.EnrollmentIn',

		QMEStagDB	= @vcQMEStagDB,
		QMEStagSchema = @vcQMEStagSchema,
		QMEStagTab	= 'Eligibility',

		QMESqlServer = @vcQMESQLServer,
		QMEDB                    = @vcQMEDB,
		QMEDataSource='VeriskFmt.EnrollmentIn'

	UNION
    SELECT 
		Valtype		= 'Provider',
		SourceSystem = 'ClientExtract',
		Client      = 'BCBSAZ',
		RDSMDB		= 'BCBSAZ_RDSM',
		RDSMSchema	= 'VERISKFMT',
		RDSMTab		= 'ProviderIn',

		RDSMRejDB	= NULL,
		RDSMRejSchema = NULL,
		RDSMRejTab	= NULL,

		StagDB		= 'BCBSA_CGF_Staging',
		StagSchema	= 'dbo',
		StagTab		= 'Provider',
		StagDataSource = 'VeriskFmt.ProviderIn',

		QMEStagDB	= @vcQMEStagDB,
		QMEStagSchema = @vcQMEStagSchema,
		QMEStagTab	= 'Provider',

		QMESqlServer = @vcQMESQLServer,
		QMEDB                    = @vcQMEDB,
		QMEDataSource='VeriskFmt.ProviderIn'
*/

/***HEDIS2017***/
	INSERT into #config
    SELECT 
		Valtype		= 'Encounter',
		SourceSystem = 'ClientExtract',
		Client      = 'BCBSAZ',
		RDSMDB		= 'BCBSAZ_RDSM',
		RDSMSchema	= 'HEDIS2017',
		RDSMTab		= 'MedicalClaimDetail',

		RDSMRejDB	= 'BCBSA_CGF_Staging',
		RDSMRejSchema = 'dbo',
		RDSMRejTab	= 'MedicalClaim_Rejected',

		StagDB		= 'BCBSA_CGF_Staging',
		StagSchema	= 'dbo',
		StagTab		= 'ClaimLineItem',
		StagDataSource = 'HEDIS2017.MedicalClaimDetail',

		QMEStagDB	= @vcQMEStagDB,
		QMEStagSchema = @vcQMEStagSchema,
		QMEStagTab	= 'ClaimLineItem',

		QMESqlServer = @vcQMESQLServer,
		QMEDB        = @vcQMEDB,
		QMEDataSource='HEDIS2017.MedicalClaimHeader'
	UNION
    SELECT 
		Valtype		= 'Encounter',
		SourceSystem = 'ClientExtract',
		Client      = 'BCBSAZ',
		RDSMDB		= 'BCBSAZ_RDSM',
		RDSMSchema	= 'HEDIS2017',
		RDSMTab		= 'SupplementalClaimDetail',

		RDSMRejDB	= 'BCBSA_CGF_Staging',
		RDSMRejSchema = 'dbo',
		RDSMRejTab	= 'SupplementalClaim_Rejected',

		StagDB		= 'BCBSA_CGF_Staging',
		StagSchema	= 'dbo',
		StagTab		= 'ClaimLineItem',
		StagDataSource = 'HEDIS2017.SupplementalClaimDetail',

		QMEStagDB	= @vcQMEStagDB,
		QMEStagSchema = @vcQMEStagSchema,
		QMEStagTab	= 'ClaimLineItem',

		QMESqlServer = @vcQMESQLServer,
		QMEDB        = @vcQMEDB,
		QMEDataSource='HEDIS2017.SupplementalClaimHeader'


    UNION 
	SELECT 
		Valtype		= 'Member',
		SourceSystem = 'ClientExtract',
		Client      = 'BCBSAZ',
		RDSMDB		= 'BCBSAZ_RDSM',
		RDSMSchema	= 'HEDIS2017',
		RDSMTab		= 'MemberDemographics',

		RDSMRejDB	= NULL,
		RDSMRejSchema = NULL,
		RDSMRejTab	= NULL,

		StagDB		= 'BCBSA_CGF_Staging',
		StagSchema	= 'dbo',
		StagTab		= 'Member',
		StagDataSource = 'HEDIS2017.MemberDemographics',

		QMEStagDB	= @vcQMEStagDB,
		QMEStagSchema = @vcQMEStagSchema,
		QMEStagTab	= 'Member',

		QMESqlServer = @vcQMESQLServer,
		QMEDB        = @vcQMEDB,
		QMEDataSource='HEDIS2017.MemberDemographics'

	UNION
    SELECT 
		Valtype		= 'Encounter',
		SourceSystem = 'ClientExtract',
		Client      = 'BCBSAZ',
		RDSMDB		= 'BCBSAZ_RDSM',
		RDSMSchema	= 'HEDIS2017',
		RDSMTab		= 'PharmacyClaims',

		RDSMRejDB	= NULL,
		RDSMRejSchema = NULL,
		RDSMRejTab	= NULL,

		StagDB		= 'BCBSA_CGF_Staging',
		StagSchema	= 'dbo',
		StagTab		= 'PharmacyClaim',
		StagDataSource = 'HEDIS2017.PharmacyClaim',

		QMEStagDB	= @vcQMEStagDB,
		QMEStagSchema = @vcQMEStagSchema,
		QMEStagTab	= 'PharmacyClaim',
		
		QMESqlServer = @vcQMESQLServer,
		QMEDB        = @vcQMEDB,
		QMEDataSource='HEDIS2017.PharmacyClaim'

	UNION
    SELECT 
		Valtype		= 'Encounter',
		SourceSystem = 'ClientExtract',
		Client      = 'BCBSAZ',
		RDSMDB		= 'BCBSAZ_RDSM',
		RDSMSchema	= 'HEDIS2017',
		RDSMTab		= 'LabResults',

		RDSMRejDB	= NULL,
		RDSMRejSchema = NULL,
		RDSMRejTab	= NULL,

		StagDB		= 'BCBSA_CGF_Staging',
		StagSchema	= 'dbo',
		StagTab		= 'LabResult',
		StagDataSource = 'HEDIS2017.LabResults',

		QMEStagDB	= @vcQMEStagDB,
		QMEStagSchema = @vcQMEStagSchema,
		QMEStagTab	= 'LabResult',

		QMESqlServer = @vcQMESQLServer,
		QMEDB        = @vcQMEDB,
		QMEDataSource='HEDIS2017.LabResults'

	UNION
    SELECT 
		Valtype		= 'Eligibility',
		SourceSystem = 'ClientExtract',
		Client      = 'BCBSAZ',
		RDSMDB		= 'BCBSAZ_RDSM',
		RDSMSchema	= 'HEDIS2017',
		RDSMTab		= 'MemberEligibility',

		RDSMRejDB	= NULL,
		RDSMRejSchema = NULL,
		RDSMRejTab	= NULL,

		StagDB		= 'BCBSA_CGF_Staging',
		StagSchema	= 'dbo',
		StagTab		= 'Eligibility',
		StagDataSource = 'HEDIS2017.MemberEligibility',

		QMEStagDB	= @vcQMEStagDB,
		QMEStagSchema = @vcQMEStagSchema,
		QMEStagTab	= 'Eligibility',

		QMESqlServer = @vcQMESQLServer,
		QMEDB        = @vcQMEDB,
		QMEDataSource='HEDIS2017.MemberEligibility'

	UNION
    SELECT 
		Valtype		= 'Provider',
		SourceSystem = 'ClientExtract',
		Client      = 'BCBSAZ',
		RDSMDB		= 'BCBSAZ_RDSM',
		RDSMSchema	= 'HEDIS2017',
		RDSMTab		= 'Provider',

		RDSMRejDB	= NULL,
		RDSMRejSchema = NULL,
		RDSMRejTab	= NULL,

		StagDB		= 'BCBSA_CGF_Staging',
		StagSchema	= 'dbo',
		StagTab		= 'Provider',
		StagDataSource = 'HEDIS2017.Provider',

		QMEStagDB	= @vcQMEStagDB,
		QMEStagSchema = @vcQMEStagSchema,
		QMEStagTab	= 'Provider',

		QMESqlServer = @vcQMESQLServer,
		QMEDB        = @vcQMEDB,
		QMEDataSource='HEDIS2017.Provider'


IF OBJECT_ID('tempdb..#Out') IS NOT NULL 
	drop TABLE #out

CREATE TABLE #out
	(OutRowID INT IDENTITY,
	ConfigRowID INT,
	SourceSystem VARCHAR(50),
	ValType VARCHAR(50),
	Client VARCHAR(50),
	RDSMCNT INT,
	StagingCnt INT,
	StagingQMECnt INT,
	QMECnt INT)


SELECT @i = MIN(RowID)
	FROM #config

WHILE @i IS NOT NULL 
BEGIN

	IF @bDebug = 1
	BEGIN
		SELECT @vcCmd = '-----------------------------------------------------' + CHAR(13)
						+ 'Valtype      = ' + ISNULL(ValType,'NULL') + CHAR(13)
						+ 'RDSMDB     = ' + ISNULL(RDSMDB,'NULL') + CHAR(13)
						+ 'RDSMSchema = ' + ISNULL(RDSMSchema,'NULL') + CHAR(13)
						+ 'RDSMTab	  =	' + ISNULL(RDSMTab,'NULL') + CHAR(13)
			FROM #config
			WHERE RowID = @i
		PRINT @vcCmd
	END

	IF 'Encounter' IN (SELECT Valtype 
							FROM #config
							WHERE RowID = @i
							)
		SELECT @vcCmd = 'SELECT ConfigRowID = ' + CONVERT(VARCHAR(10),RowID) + ', ' + CHAR(13)
						+' SourceSystem = ''' + SourceSystem + ''', ' + CHAR(13)
						+' ValType = ''' + valtype + ''', ' + CHAR(13)
						+' Client = ''' + Client + ''', ' + CHAR(13)
						+' RDSMCNT = RDSM.RDSM_CNT, '+ CHAR(13)
						+' StagingCnt = Stag.Stag_CNT, '+ CHAR(13)
						+' StagingQMECnt = qme_stag.qme_stag_cnt, '+ CHAR(13)
						+' QMECnt = qme.qme_cnt '+ CHAR(13)
						+' FROM ' + CHAR(13)
						--RDSM
						+' (SELECT RDSM_Cnt = COUNT(*)  ' + CHAR(13)
						+'  FROM ' + RDSMDB + '.' + RDSMSchema + '.' + RDSMTab + ' a '+ CHAR(13)
						+ CASE WHEN RDSMRejDB IS NOT NULL 
							THEN '    LEFT JOIN ' + RDSMRejDB + '.' + RDSMRejSchema +'.'+ RDSMRejTab + ' rej '+ CHAR(13)
								+'	    ON rej.RowID = a.RowID '+ CHAR(13)
								+'	    AND rej.Client = ''' + Client + '''' + CHAR(13)
								+'	    AND rej.SrcTabDB = ''' + RDSMDB + ''''+ CHAR(13)
								+'	    AND rej.SrcTabSchema = ''' + RDSMSchema + ''''+ CHAR(13)
								+'	    AND rej.SrcTabName = ''' + RDSMTab + ''''+ CHAR(13)
								+'  WHERE rej.RowID IS NULL '+ CHAR(13)
							ELSE '' END
						+' ) rdsm ' + CHAR(13)
						-- Stag
						+' FULL OUTER JOIN ' + CHAR(13)
						+' 	(SELECT stag_cnt = COUNT(*) '+ CHAR(13)
						+' 		FROM ' + StagDB + '.' + StagSchema + '.' + StagTab + CHAR(13)
						+' 		WHERE CHARINDEX(''' + StagDataSource + ''',DataSource) > 0' + CHAR(13)
						+' 	) stag ' + CHAR(13)
						+' 	ON 1 = 1 ' + CHAR(13)
						-- QME Stag
						+' FULL OUTER JOIN  ' + CHAR(13)
						+' 	(SELECT qme_stag_cnt = COUNT(*) ' + CHAR(13)
						+' 		FROM ' + QMEStagDB + '.' + QMEStagSchema + '.' + QMESTagTab + CHAR(13)
						+' 		WHERE CHARINDEX(''' + StagdataSource + ''',DataSource) > 0' + CHAR(13)
						+' 	) qme_stag' + CHAR(13)
						+' 	ON 1 = 1' + CHAR(13)
						-- QME
						+' FULL OUTER JOIN ' + CHAR(13)
						+' 	(SELECT QME_cnt = COUNT(*)' + CHAR(13)
						+' 		FROM ' + QMESqlServer + '.' + QMEDB + '.Claim.ClaimLines cli ' + CHAR(13)
						+' 			INNER JOIN ' + QMESqlServer + '.' + QMEDB + '.Batch.DataSetSources dss ' + CHAR(13)
						+' 				ON dss.DataSetID = cli.DataSetID' + CHAR(13)
						+' 				AND dss.DataSourceID = cli.DataSourceID' + CHAR(13)
						+'              AND cli.dataSetID = ' + CONVERT(VARCHAR(2),@iDataSetID) + CHAR(13)
						+' 		WHERE CHARINDEX(''' + QMEDatasource + ''',dss.DataSource) > 0'+ CHAR(13)
						+' 	) QME'+ CHAR(13)
						+' 	ON 1 = 1'+ CHAR(13)
			FROM #config
			WHERE RowID = @i




	IF 'Member' IN (SELECT Valtype 
							FROM #config
							WHERE RowID = @i
							)
		SELECT @vcCmd = 'SELECT ConfigRowID = ' + CONVERT(VARCHAR(10),RowID) + ', ' + CHAR(13)
						+' SourceSystem = ''' + SourceSystem + ''', ' + CHAR(13)
						+' ValType = ''' + valtype + ''', ' + CHAR(13)
						+' Client = ''' + Client + ''', ' + CHAR(13)
						+' RDSMCNT = RDSM.RDSM_CNT, '+ CHAR(13)
						+' StagingCnt = Stag.Stag_CNT, '+ CHAR(13)
						+' StagingQMECnt = qme_stag.qme_stag_cnt, '+ CHAR(13)
						+' QMECnt = qme.qme_cnt '+ CHAR(13)
						+' FROM ' + CHAR(13)
						--RDSM
						+' (SELECT RDSM_Cnt = COUNT(DISTINCT mom.IHDS_Member_ID)  ' + CHAR(13)
						+'  FROM ' + RDSMDB + '.' + RDSMSchema + '.' + RDSMTab + ' m '+ CHAR(13)
						+' 	  INNER JOIN ' + StagDB + '.dbo.mpi_output_member mom ' + CHAR(13)
						+'      ON ''' + Client + ''' = mom.clientid ' + CHAR(13)
						+' 	    AND ''' + RDSMTab + ''' = mom.src_table_name ' + CHAR(13)
						+' 	    AND ''' + RDSMDB + ''' = mom.src_db_name ' + CHAR(13)
						+' 	    AND ''' + RDSMSchema +''' = mom.src_schema_name ' + CHAR(13)
						+' 	    AND m.RowID = mom.src_rowid ' + CHAR(13)
						+' ) rdsm ' + CHAR(13)
						-- Stag
						+' FULL OUTER JOIN ' + CHAR(13)
						+' 	(SELECT stag_cnt = COUNT(*) '+ CHAR(13)
						+' 		FROM ' + StagDB + '.' + StagSchema + '.' + StagTab + CHAR(13)
						+' 		WHERE DataSource = ''' + StagDataSource + '''' + CHAR(13)
						+' 	) stag ' + CHAR(13)
						+' 	ON 1 = 1 ' + CHAR(13)
						-- QME Stag
						+' FULL OUTER JOIN  ' + CHAR(13)
						+' 	(SELECT qme_stag_cnt = COUNT(*) ' + CHAR(13)
						+' 		FROM ' + QMEStagDB + '.' + QMEStagSchema + '.' + QMESTagTab + CHAR(13)
						+' 		WHERE DataSource = ''' + StagdataSource + '''' + CHAR(13)
						+' 	) qme_stag' + CHAR(13)
						+' 	ON 1 = 1' + CHAR(13)
						-- QME
						+' FULL OUTER JOIN ' + CHAR(13)
						+' 	(SELECT QME_cnt = COUNT(*)' + CHAR(13)
						+' 		FROM ' + QMESqlServer + '.' + QMEDB + '.member.Members mm ' + CHAR(13)
						+' 			INNER JOIN ' + QMESqlServer + '.' + QMEDB + '.Batch.DataSetSources dss ' + CHAR(13)
						+' 				ON dss.DataSetID = mm.DataSetID' + CHAR(13)
						+' 				AND dss.DataSourceID = mm.DataSourceID' + CHAR(13)
						+'              AND mm.dataSetID = ' + CONVERT(VARCHAR(2),@iDataSetID) + CHAR(13)
						+' 		WHERE dss.DataSource = ''' + QMEDatasource + ''''+ CHAR(13)
						+' 	) QME'+ CHAR(13)
						+' 	ON 1 = 1'+ CHAR(13)
			FROM #config
			WHERE RowID = @i


	IF 'Eligibility' IN (SELECT Valtype 
							FROM #config
							WHERE RowID = @i
							)
		SELECT @vcCmd = 'SELECT ConfigRowID = ' + CONVERT(VARCHAR(10),RowID) + ', ' + CHAR(13)
						+' SourceSystem = ''' + SourceSystem + ''', ' + CHAR(13)
						+' ValType = ''' + valtype + ''', ' + CHAR(13)
						+' Client = ''' + Client + ''', ' + CHAR(13)
						+' RDSMCNT = RDSM.RDSM_CNT, '+ CHAR(13)
						+' StagingCnt = Stag.Stag_CNT, '+ CHAR(13)
						+' StagingQMECnt = qme_stag.qme_stag_cnt, '+ CHAR(13)
						+' QMECnt = qme.qme_cnt '+ CHAR(13)
						+' FROM ' + CHAR(13)
						--RDSM
						+' (SELECT RDSM_Cnt = COUNT(*)  ' + CHAR(13)
						+'  FROM ' + RDSMDB + '.' + RDSMSchema + '.' + RDSMTab + ' m '+ CHAR(13)
						--+' 	  INNER JOIN ' + StagDB + '.dbo.mpi_output_member mom ' + CHAR(13)
						--+'      ON ''' + Client + ''' = mom.clientid ' + CHAR(13)
						--+' 	    AND ''' + RDSMTab + ''' = mom.src_table_name ' + CHAR(13)
						--+' 	    AND ''' + RDSMDB + ''' = mom.src_db_name ' + CHAR(13)
						--+' 	    AND ''' + RDSMSchema +''' = mom.src_schema_name ' + CHAR(13)
						--+' 	    AND m.RowID = mom.src_rowid ' + CHAR(13)
						+' ) rdsm ' + CHAR(13)
						-- Stag
						+' FULL OUTER JOIN ' + CHAR(13)
						+' 	(SELECT stag_cnt = COUNT(*) '+ CHAR(13)
						+' 		FROM ' + StagDB + '.' + StagSchema + '.' + StagTab + CHAR(13)
						+' 		WHERE DataSource = ''' + StagDataSource + '''' + CHAR(13)
						+' 	) stag ' + CHAR(13)
						+' 	ON 1 = 1 ' + CHAR(13)
						-- QME Stag
						+' FULL OUTER JOIN  ' + CHAR(13)
						+' 	(SELECT qme_stag_cnt = COUNT(*) ' + CHAR(13)
						+' 		FROM ' + QMEStagDB + '.' + QMEStagSchema + '.' + QMESTagTab + CHAR(13)
						+' 		WHERE DataSource = ''' + StagdataSource + '''' + CHAR(13)
						+' 	) qme_stag' + CHAR(13)
						+' 	ON 1 = 1' + CHAR(13)
						-- QME
						+' FULL OUTER JOIN ' + CHAR(13)
						+' 	(SELECT QME_cnt = COUNT(*)' + CHAR(13)
						+' 		FROM ' + QMESqlServer + '.' + QMEDB + '.member.Enrollment mm ' + CHAR(13)
						+' 			INNER JOIN ' + QMESqlServer + '.' + QMEDB + '.Batch.DataSetSources dss ' + CHAR(13)
						+' 				ON dss.DataSetID = mm.DataSetID' + CHAR(13)
						+' 				AND dss.DataSourceID = mm.DataSourceID' + CHAR(13)
						+'              AND mm.dataSetID = ' + CONVERT(VARCHAR(2),@iDataSetID) + CHAR(13)
						+' 		WHERE dss.DataSource = ''' + QMEDatasource + ''''+ CHAR(13)
						+' 	) QME'+ CHAR(13)
						+' 	ON 1 = 1'+ CHAR(13)
			FROM #config
			WHERE RowID = @i


	IF 'Provider' IN (SELECT Valtype 
							FROM #config
							WHERE RowID = @i
							)
		SELECT @vcCmd = 'SELECT ConfigRowID = ' + CONVERT(VARCHAR(10),RowID) + ', ' + CHAR(13)
						+' SourceSystem = ''' + SourceSystem + ''', ' + CHAR(13)
						+' ValType = ''' + valtype + ''', ' + CHAR(13)
						+' Client = ''' + Client + ''', ' + CHAR(13)
						+' RDSMCNT = RDSM.RDSM_CNT, '+ CHAR(13)
						+' StagingCnt = Stag.Stag_CNT, '+ CHAR(13)
						+' StagingQMECnt = qme_stag.qme_stag_cnt, '+ CHAR(13)
						+' QMECnt = qme.qme_cnt '+ CHAR(13)
						+' FROM ' + CHAR(13)
						--RDSM
						+' (SELECT RDSM_Cnt = COUNT(DISTINCT mop.ihds_prov_id_servicing)  ' + CHAR(13)
						+'  FROM ' + RDSMDB + '.' + RDSMSchema + '.' + RDSMTab + ' m '+ CHAR(13)
						+' 	  INNER JOIN ' + StagDB + '.dbo.mpi_output_provider mop ' + CHAR(13)
						+'      ON ''' + Client + ''' = mop.clientid ' + CHAR(13)
						+' 	    AND ''' + RDSMTab + ''' = mop.src_table_name ' + CHAR(13)
						+' 	    AND ''' + RDSMDB + ''' = mop.src_db_name ' + CHAR(13)
						+' 	    AND ''' + RDSMSchema +''' = mop.src_schema_name ' + CHAR(13)
						+' 	    AND m.RowID = mop.src_rowid ' + CHAR(13)
						+' ) rdsm ' + CHAR(13)
						-- Stag
						+' FULL OUTER JOIN ' + CHAR(13)
						+' 	(SELECT stag_cnt = COUNT(*) '+ CHAR(13)
						+' 		FROM ' + StagDB + '.' + StagSchema + '.' + StagTab + CHAR(13)
						+' 		WHERE DataSource = ''' + StagDataSource + '''' + CHAR(13)
						+' 	) stag ' + CHAR(13)
						+' 	ON 1 = 1 ' + CHAR(13)
						-- QME Stag
						+' FULL OUTER JOIN  ' + CHAR(13)
						+' 	(SELECT qme_stag_cnt = COUNT(*) ' + CHAR(13)
						+' 		FROM ' + QMEStagDB + '.' + QMEStagSchema + '.' + QMESTagTab + CHAR(13)
						+' 		WHERE DataSource = ''' + StagdataSource + '''' + CHAR(13)
						+' 	) qme_stag' + CHAR(13)
						+' 	ON 1 = 1' + CHAR(13)
						-- QME
						+' FULL OUTER JOIN ' + CHAR(13)
						+' 	(SELECT QME_cnt = COUNT(*)' + CHAR(13)
						+' 		FROM ' + QMESqlServer + '.' + QMEDB + '.provider.Providers mm ' + CHAR(13)
						+' 			INNER JOIN ' + QMESqlServer + '.' + QMEDB + '.Batch.DataSetSources dss ' + CHAR(13)
						+' 				ON dss.DataSetID = mm.DataSetID' + CHAR(13)
						+' 				AND dss.DataSourceID = mm.DataSourceID' + CHAR(13)
						+'              AND mm.dataSetID = ' + CONVERT(VARCHAR(2),@iDataSetID) + CHAR(13)
						+' 		WHERE dss.DataSource = ''' + QMEDatasource + ''''+ CHAR(13)
						+' 	) QME'+ CHAR(13)
						+' 	ON 1 = 1'+ CHAR(13)
			FROM #config
			WHERE RowID = @i
	
	IF @bDebug = 1
		PRINT @vcCmd

	INSERT INTO #out	
	EXEC (@vcCmd)

	SELECT @i = MIN(RowID)
		FROM #config
		WHERE RowID > @i

END


--QME Error
BEGIN

--DECLARE @vcCmd VARCHAR(8000), @bDebug BIT = 1

	IF OBJECT_ID('tempdb..#ClaimLineItem') IS NOT NULL
		DROP TABLE #ClaimLineItem

	CREATE TABLE #ClaimLineItem
		(ClaimID INT,
		ClaimLineItemID INT,
		ServicingProviderId INT,
		IHDS_Prov_ID_Servicing INT,
		IHDS_Member_ID INT,
		MemberID INT
		)
SELECT * FROM #config
	SELECT TOP 1  @vcCmd = 'SELECT cli.ClaimID, ' + CHAR(13)
					+ ' cli.ClaimLineItemID, ' + CHAR(13)
					+ ' c.ServicingProviderID, ' + CHAR(13)
					+ ' c.IHDS_prov_id_servicing, ' + CHAR(13)
					+ ' m.ihds_member_id, ' + CHAR(13)
					+ ' c.MemberID '  + CHAR(13)
					+ ' FROM  ' + StagDB + '.' + StagSchema + '.ClaimLineItem cli ' + CHAR(13)
		FROM #config
		WHERE StagTab = 'ClaimLineItem'

	SELECT TOP 1 @vcCmd = @vcCmd + ' INNER JOIN '+ StagDB + '.' + StagSchema + '.Claim c ' + CHAR(13)
							+ ' ON c.ClaimID = cli.ClaimID '+ CHAR(13)
		FROM #config
		WHERE StagTab = 'ClaimLineItem'

	SELECT TOP 1 @vcCmd = @vcCmd + ' INNER JOIN '+ StagDB + '.' + StagSchema + '.Member M ' + CHAR(13)
							+ ' ON c.MemberID = m.MemberID '+ CHAR(13)
		FROM #config
		WHERE StagTab = 'ClaimLineItem'

	IF @bDebug = 1
		PRINT @vcCmd

	INSERT INTO #ClaimLineItem
	        (ClaimID,
	         ClaimLineItemID,
	         ServicingProviderId,
	         IHDS_Prov_ID_Servicing,
	         IHDS_Member_ID,
	         MemberID
	        )
		EXEC (@vcCmd)

	



END


IF OBJECT_ID('imietl.RDSMStagingQME_DiffReport') IS NOT NULL 
	DROP TABLE imietl.RDSMStagingQME_DiffReport

SELECT c.RowID,
       c.Valtype,
       c.SourceSystem,
       c.Client,
       c.RDSMDB,
       c.RDSMSchema,
       c.RDSMTab,
       c.RDSMRejDB,
       c.RDSMRejSchema,
       c.RDSMRejTab,
       c.StagDB,
       c.StagSchema,
       c.StagTab,
       c.StagDataSource,
       c.QMEStagDB,
       c.QMEStagSchema,
       c.QMEStagTab,
	   c.QMESqlServer,
       c.QMEDB,
       c.QMEDataSource,
	   o.RDSMCNT,
       o.StagingCnt,
       o.StagingQMECnt,
       o.QMECnt
	INTO imietl.RDSMStagingQME_DiffReport
	FROM #config c
		INNER JOIN #out o
			ON c.RowID = o.OutRowID


IF @bDebug = 1
BEGIN
	SELECT * 
		FROM imietl.RDSMStagingQME_DiffReport

	SELECT RowID,
           Valtype,
           SourceSystem,
           Client,
           RDSMDB,
           RDSMSchema,
           RDSMTab,

           RDSMCNT,
           StagingCnt,
           StagingQMECnt,
           QMECnt,		 

		   QMEDiff = QMECnt - RDSMCnt
		FROM imietl.RDSMStagingQME_DiffReport
END
GO
