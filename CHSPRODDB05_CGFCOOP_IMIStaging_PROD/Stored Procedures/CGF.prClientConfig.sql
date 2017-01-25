SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


/*************************************************************************************
Procedure:	
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
7/31/2014 - build syn server+db from clientconfig
8/22/2014 - add IMIStagin_PRod_SErver and DB

Process:	
Test Script: 
ToDo:		

*/

CREATE  PROC [CGF].[prClientConfig]

AS

IF OBJECT_ID('cgf.ClientConfig') IS NOT NULL
	DROP TABLE cgf.ClientConfig

CREATE TABLE cgf.ClientConfig
	(ClientName VARCHAR(100),
	QME_Server VARCHAR(100),
	QME_DB VARCHAR(100),
	QME_Staging_Server VARCHAR(100),
	QME_Staging_DB VARCHAR(100),
	IMIStaging_Server VARCHAR(100),
	IMIStaging_DB VARCHAR(100),
	IMIStaging_Prod_Server VARCHAR(100),
	IMIStaging_PRod_DB VARCHAR(100),

	QME_FullBuildSchema VARCHAR(100),
	QME_OwnerID INT,
	QME_MeasureSetID INT,
	RollingMonths INT,
	RollingMonthsInterval INT,
	SeedDateLagMonths INT
	)


INSERT INTO cgf.ClientConfig
SELECT ClientName = 'DHMP',
		QME_Server = 'IMIETL01',
		QME_DB = 'DHMP_PROD_QME',
		QME_Staging_Server = 'IMIETL01',
		QME_Staging_DB = 'DHMP_QINet_Staging',
		IMIStaging_Server = 'IMISQL14',
		IMIStaging_DB = 'DHMP_IMIStaging',
		IMIStaging_Prod_Server = 'IMISQL14',
		IMIStaging_PRod_DB = 'DHMP_IMIStaging_PROD',
		QME_FullBuildSchema = 'DHMPFull' , 
		QME_OwnerID = 18,
		QME_MeasureSetID = 9,
		RollingMonths = 1,
		RollingMonthsInterval = 1,
		SeedDateLagMonths = 3



-- Configure QME Synonyms

DECLARE @tTabLIst TABLE (RowID INT IDENTITY(1,1), 
							SchemaName VARCHAR(100),
							TabName VARCHAR(100))

INSERT INTO @tTabLIst SELECT 'Batch','DataRuns'
INSERT INTO @tTabLIst SELECT 'Measure','MeasureXrefs'
INSERT INTO @tTabLIst SELECT 'Measure','MetricXrefs'
INSERT INTO @tTabLIst SELECT 'Measure','Metrics'
INSERT INTO @tTabLIst SELECT 'Result','MeasureDetail'
INSERT INTO @tTabLIst SELECT 'Measure','ExclusionTypes'
INSERT INTO @tTabLIst SELECT 'Measure','AgeBands'
INSERT INTO @tTabLIst SELECT 'Measure','AgeBandSegments'
INSERT INTO @tTabLIst SELECT 'Member','Genders'
INSERT INTO @tTabLIst SELECT 'Product','Payers'
INSERT INTO @tTabLIst SELECT 'Product','ProductLines'
INSERT INTO @tTabLIst SELECT 'Result','ResultTypes'
INSERT INTO @tTabLIst SELECT 'Batch','DataSets'
INSERT INTO @tTabLIst SELECT 'Measure','MeasureSets'
INSERT INTO @tTabLIst SELECT 'Measure','MemberMonths'
INSERT INTO @tTabLIst SELECT 'Batch','DataSets'
INSERT INTO @tTabLIst SELECT 'Batch','DataOwners'
INSERT INTO @tTabLIst SELECT 'Batch','Batches'
INSERT INTO @tTabLIst SELECT 'Result','DataSetMemberKey'
INSERT INTO @tTabLIst SELECT 'Result','DataSetProviderKey'
INSERT INTO @tTabLIst SELECT 'Result','DataSetMedicalGroupKey'
INSERT INTO @tTabLIst SELECT 'member','Members'
INSERT INTO @tTabLIst SELECT 'Member','EnrollmentPopulations'
INSERT INTO @tTabLIst SELECT 'member','EnrollmentGroups'


EnrollmentGroups
DECLARE @i INT,
	@vcCmd VARCHAR(4000)
SELECT @i = MIN(Rowid) FROM @tTabLIst

WHILE @i IS NOT NULL 
BEGIN


	SELECT @vcCmd = 'CGF_SYN.' + TabName
		FROM @tTabLIst
		WHERE RowID = @i

	IF OBJECT_ID(@vcCmd) IS NOT NULL 
	BEGIN
		SELECT @vcCmd = 'DROP SYNONYM CGF_SYN.' + TabName
			FROM @tTabLIst
			WHERE RowID = @i

		PRINT @vcCmd
		EXEC (@vcCMD)
	END

	SELECT @vcCmd = 'CREATE SYNONYM CGF_SYN.' + TabName 
					+ ' FOR ' + b.QME_Server + '.' + b.QME_DB + '.' + SchemaName + '.' + TabName
		FROM @tTabLIst a
			INNER JOIN cgf.ClientConfig b
				ON 1 = 1
		WHERE RowID = @i

	PRINT @vcCmd
	EXEC (@vcCMD)

	SELECT @i = MIN(Rowid) 
		FROM @tTabLIst
		WHERE Rowid > @i


END
-- Select Metrics to report

IF OBJECT_ID('CGF.ClientMeasureFilter') IS NOT NULL
	DROP TABLE cgf.ClientMeasureFilter

CREATE TABLE cgf.ClientMeasureFilter (RowID INT IDENTITY(1,1), MeasureInit VARCHAR(3))

INSERT INTO cgf.ClientMeasureFilter
SELECT MeasureFilter = 'AAB' UNION
SELECT MeasureFilter = 'AAP' UNION
SELECT MeasureFilter = 'ABA' UNION
SELECT MeasureFilter = 'ADD' UNION
SELECT MeasureFilter = 'AMB' UNION
SELECT MeasureFilter = 'AMM' UNION
SELECT MeasureFilter = 'AMR' UNION
SELECT MeasureFilter = 'ART' UNION
SELECT MeasureFilter = 'ASM' UNION
SELECT MeasureFilter = 'AWC' UNION
SELECT MeasureFilter = 'BCS' UNION
SELECT MeasureFilter = 'CAP' UNION
SELECT MeasureFilter = 'CBP' UNION
SELECT MeasureFilter = 'CCS' UNION
SELECT MeasureFilter = 'CDC' UNION
SELECT MeasureFilter = 'CHL' UNION
SELECT MeasureFilter = 'CIS' UNION
SELECT MeasureFilter = 'CMC' UNION
SELECT MeasureFilter = 'COA' UNION
SELECT MeasureFilter = 'COL' UNION
SELECT MeasureFilter = 'CWP' UNION
SELECT MeasureFilter = 'DAE' UNION
SELECT MeasureFilter = 'DDE' UNION
--SELECT MeasureFilter = 'EBS' UNION
SELECT MeasureFilter = 'FPC' UNION
SELECT MeasureFilter = 'FSP' UNION
SELECT MeasureFilter = 'FUH' UNION
SELECT MeasureFilter = 'GSO' UNION
SELECT MeasureFilter = 'HPV' UNION
SELECT MeasureFilter = 'IAD' UNION
SELECT MeasureFilter = 'IET' UNION
SELECT MeasureFilter = 'IMA' UNION
SELECT MeasureFilter = 'IPU' UNION
SELECT MeasureFilter = 'LBP' UNION
--SELECT MeasureFilter = 'LDM' UNION
SELECT MeasureFilter = 'LSC' UNION
SELECT MeasureFilter = 'MMA' UNION
SELECT MeasureFilter = 'MPM' UNION
SELECT MeasureFilter = 'MPT' UNION
SELECT MeasureFilter = 'MRP' UNION
SELECT MeasureFilter = 'NCS' UNION
SELECT MeasureFilter = 'OMW' UNION
SELECT MeasureFilter = 'PBH' UNION
SELECT MeasureFilter = 'PCE' UNION
SELECT MeasureFilter = 'PCR' UNION
SELECT MeasureFilter = 'PPC' UNION
SELECT MeasureFilter = 'RAS' UNION
SELECT MeasureFilter = 'RCA' UNION
SELECT MeasureFilter = 'RCO' UNION
SELECT MeasureFilter = 'RDI' UNION
--SELECT MeasureFilter = 'RDM' UNION
SELECT MeasureFilter = 'RHY' UNION
SELECT MeasureFilter = 'SAA' UNION
SELECT MeasureFilter = 'SMC' UNION
SELECT MeasureFilter = 'SMD' UNION
SELECT MeasureFilter = 'SPR' UNION
SELECT MeasureFilter = 'SSD' UNION
SELECT MeasureFilter = 'TLM' UNION
SELECT MeasureFilter = 'URI' UNION
SELECT MeasureFilter = 'W15' UNION
SELECT MeasureFilter = 'W34' UNION
SELECT MeasureFilter = 'WCC' UNION
SELECT MeasureFilter = 'WOP' 

/*
SELECT DISTINCT 'SELECT MeasureFilter = ''' + Measure + ''' UNION'
	FROM CGF.ResultsByMember
	ORDER BY 'SELECT MeasureFilter = ''' + Measure + ''' UNION'

	SELECT EndSeedDate, 
		measuremetricdesc, 
		Denominator = SUM(isdenominator),
		Numerator = SUM(isnumerator),
		RatePerc = CONVERT(NUMERIC(11,2),(SUM(isnumerator)/(SUM(isdenominator)*1.0))*100)
	FROM CGF.ResultsByMember
	WHERE isdenominator = 1
	GROUP BY EndSeedDate, measuremetricdesc
	ORDER BY EndSeedDate, measuremetricdesc
*/

GO
