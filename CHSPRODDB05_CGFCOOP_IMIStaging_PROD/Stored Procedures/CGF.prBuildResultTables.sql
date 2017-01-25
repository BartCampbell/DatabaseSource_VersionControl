SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


--SELECT * FROM 

--select * from CGF.ResultsByMember



--SELECT top 10 * 	FROM PREF1_QINet_Staging.dbo.CGF_ResultsByMember
   
/*
SELECT EndSeedDate, 
		measuremetricdesc, 
		Denominator = SUM(isdenominator),
		Numerator = SUM(isnumerator),
		RatePerc = CONVERT(NUMERIC(11,2),(SUM(isnumerator)/(SUM(isdenominator)*1.0))*100)
		
	FROM CGF.ResultsByMember
	WHERE isdenominator = 1
	GROUP BY EndSeedDate, measuremetricdesc
	ORDER BY EndSeedDate, measuremetricdesc

alter table t1000.memberprovider add MemberProviderID INT IDENTITY(1,1)

select *
FROM cgf.DataRuns AS BDR

*/


--alter VIEW CGF_ResultsByMember AS

--DROP VIEW CGF_ResultsByMember

/*

-- SETup Scripts
1. run this proc with 
	Chagne @DatabaseName, @QINetSource
	change databasesource by hand
2. update cgf_clientlist
	INSERT INTO cgf.ClientList (Client) SELECT  'Verisk'	
	SELECT * FROM cgf.ClientList

*/
/*************************************************************************************
Procedure:	CGF.prBuildResultTables
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
7/9/2014 - Change LOB to come from MeasureEngine
8/22/2014 - Change import specific table for performance
8/26/2014 - Add no lock, change pull from MeasureDetail to filter by datarunid, remove @vcFilterINit
8/26/2014 - Add Client measure filter
Process:	
Test Script: 

select * FROM IMIETL01.DHMP_PROD_QME.Batch.DataRuns 
	where datarunguid = '7B8DA32A-2AE6-4DDE-8F79-F9A14B8F2E93'

exec [CGF].[prBuildResultTables] 1,1

ToDo:		

*/


----Note: still need to change databasesource by hand
--/*
CREATE PROC [CGF].[prBuildResultTables] 

@bMinDataRunID INT = NULL,
@bMaxDataRunID INT = NULL

AS
	--SET NOCOUNT ON
--*/

/*-------------------------------------------
DECLARE @bMinDataRunID INT = 1
DECLARE @bMaxDataRunID INT = 1
--*/-------------------------------------------


IF @bMinDataRunID IS NULL
	SELECT @bMinDataRunID = MIN(DataRunID) FROM CGF_SYN.dataruns

IF @bMaxDataRunID IS NULL
	SELECT @bMaxDataRunID = MAX(DataRunID) FROM CGF_SYN.dataruns

DECLARE @vcCmd VARCHAR(2000)
DECLARE @DatabaseName VARCHAR(100) 

DECLARE @Cmd NVARCHAR(MAX)
DECLARE @CountRecords INT
DECLARE @CountRows INT
DECLARE @Result INT = 0
DECLARE @DataRunID INT
DECLARE @QINetSource VARCHAR(200) 
DECLARE @PrintSql BIT = 1
DECLARE @ExecuteSql BIT = 1

SELECT  @DatabaseName = IMIStaging_DB,
		@QINetSource = QME_DB
	FROM cgf.ClientConfig    


/*
USE [VERISK_PROD_QME]
GO
CREATE NONCLUSTERED INDEX idxCovIndex_leon
ON [Result].[MeasureDetail] ([DataRunID])
INCLUDE ([AgeMonths],[DataSetID],[DSMemberID],[MeasureXrefID],[MetricXrefID],[ProductLineID])
*/

-- from summaraize all, need to run refresh member key

DECLARE @bRunXref BIT = 1
DECLARE @bBuildResults BIT = 1

IF @bMinDataRunID IS NULL
	SET @bMinDataRunID = 0

IF @bMaxDataRunID IS NULL
	SELECT @bMaxDataRunID = MAX(DataRunID)
		FROM CGF_SYN.DataRuns

IF OBJECT_ID('tempdb..#dataruns') IS NOT NULL 
    DROP TABLE #dataRuns

SELECT *
    INTO #DataRuns
    FROM CGF_SYN.DataRuns AS BDR WITH (NOLOCK)
    WHERE DataRunID BETWEEN @bMinDataRunID AND @bMaxDataRunID

CREATE INDEX dk ON  #DataRuns (DataRunID, MeasureSetID, EndInitSeedDate, DataRunGuid)
CREATE STATISTICS sp ON  #DataRuns (DataRunID, MeasureSetID, EndInitSeedDate, DataRunGuid)

IF OBJECT_ID('CGF.MeasureDetail') IS NOT NULL 
	DROP TABLE CGF.MeasureDetail

SELECT *
	INTO CGF.MeasureDetail
	FROM CGF_SYN.MeasureDetail WITH (NOLOCK) 
	WHERE DataRunID BETWEEN @bMinDataRunID AND @bMaxDataRunID

-- Set Xref Tables
-- Xref Tables
IF @bRunXref = 1 
BEGIN
	--5) Export Measures...
    BEGIN
        IF OBJECT_ID(QUOTENAME(@DatabaseName) + '.CGF.[Measures]') IS NOT NULL 
            BEGIN
                SET @Cmd = 'DROP TABLE ' + QUOTENAME(@DatabaseName) + '.CGF.[Measures]'
                EXEC (@Cmd)
            END

        SET @Cmd = 'SELECT	
					MMXR.Abbrev AS Measure,
					MMXR.*
			INTO	' + QUOTENAME(@DatabaseName) + '.CGF.[Measures]  
			FROM	CGF_SYN.MeasureXrefs AS MMXR WITH (NOLOCK)
			
			CREATE CLUSTERED INDEX IX_Measures ON '
            + QUOTENAME(@DatabaseName)
            + '.CGF.[Measures] (MeasureXrefGuid ASC)
			CREATE INDEX IX_Measures_Measure ON '
            + QUOTENAME(@DatabaseName)
            + '.CGF.[Measures] (Measure ASC)'

        IF @Cmd IS NOT NULL 
            BEGIN
                IF @PrintSql = 1 
                    PRINT @Cmd		

                IF @ExecuteSql = 1 
                    BEGIN 
                        EXEC @Result = sys.sp_executesql @statement = @Cmd
						
                        SET @CountRows = @@ROWCOUNT
                        SET @CountRecords = ISNULL(@CountRecords,0)
                            + @CountRows
                    END
            END
    END
		
	--6) Export Metrics...
    BEGIN
        IF OBJECT_ID(QUOTENAME(@DatabaseName) + '.CGF.[Metrics]') IS NOT NULL 
            BEGIN
                SET @Cmd = 'DROP TABLE ' + QUOTENAME(@DatabaseName)
                    + '.CGF.[Metrics]'
                EXEC (@Cmd)
            END

        SET @Cmd = 'SELECT	MXXR.*,
					MMXR.MeasureXrefGuid,
					MXXR.Abbrev AS Metric,
					IsShown = CASE WHEN mi.Abbrev IS NULL THEN 0 ELSE 1 END,
					m.ScoreTypeID
			INTO	' + QUOTENAME(@DatabaseName) + '.CGF.[Metrics]
			FROM	CGF_SYN.MetricXrefs AS MXXR  WITH (NOLOCK)
					INNER JOIN CGF_SYN.MeasureXrefs AS MMXR  WITH (NOLOCK)
						ON MXXR.MeasureXrefID = MMXR.MeasureXrefID
					LEFT JOIN (SELECT Abbrev FROM CGF_SYN.Metrics m  WITH (NOLOCK) WHERE IsShown = 1 GROUP BY Abbrev) mi
						ON MXXR.Abbrev = mi.Abbrev
					INNER JOIN (select Abbrev, ScoreTypeID = MAX(ScoreTypeID) 
									from CGF_SYN.metrics m  WITH (NOLOCK)
									group by Abbrev
								) m
						ON mxxr.abbrev = m.abbrev
			
			CREATE CLUSTERED INDEX IX_Metrics ON '
            + QUOTENAME(@DatabaseName)
            + '.CGF.[Metrics] (MetricXrefGuid ASC)
			CREATE INDEX IX_Metrics_Metric ON '
            + QUOTENAME(@DatabaseName) + '.CGF.[Metrics] (Metric ASC)'

        IF @Cmd IS NOT NULL 
            BEGIN
                IF @PrintSql = 1 
                    PRINT @Cmd		

                IF @ExecuteSql = 1 
                    BEGIN 
                        EXEC @Result = sys.sp_executesql @statement = @Cmd
						
                        SET @CountRows = @@ROWCOUNT
                        SET @CountRecords = ISNULL(@CountRecords,0)
                            + @CountRows
                    END
            END

		--MeasureMetric
		IF OBJECT_ID(QUOTENAME(@DatabaseName) + '.CGF.[MeasureMetrics]') IS NOT NULL 
            BEGIN
                SET @Cmd = 'DROP TABLE ' + QUOTENAME(@DatabaseName) + '.CGF.[MeasureMetrics]'
                EXEC (@Cmd)
            END

        SET @Cmd = 'SELECT  DISTINCT 
							mmxr.MeasureXrefGuid,
							mxxr.MetricXrefGuid,
							Measure = MMXR.Abbrev,
							MeasureDesc = MMXR.Abbrev+''-''+mmxr.Descr,
							MeasureMetricDesc =  MMXR.Abbrev+''-''+CASE WHEN mxxr.Descr = ''Numerator'' THEN mmxr.Descr ELSE mxxr.Descr end
						INTO ' + QUOTENAME(@DatabaseName) + '.CGF.MeasureMetrics 
						FROM CGF.MeasureDetail AS t  WITH (NOLOCK) 
							INNER JOIN CGF_SYN.MeasureXrefs AS MMXR  WITH (NOLOCK) 
								ON t.MeasureXrefID = MMXR.MeasureXrefID
							INNER JOIN CGF_SYN.MetricXrefs AS MXXR WITH (NOLOCK) 
								ON t.MetricXrefID = MXXR.MetricXrefID
								'
        IF @Cmd IS NOT NULL 
            BEGIN
                IF @PrintSql = 1 
                    PRINT @Cmd		

                IF @ExecuteSql = 1 
                    BEGIN 
                        EXEC @Result = sys.sp_executesql @statement = @Cmd
						
                        SET @CountRows = @@ROWCOUNT
                        SET @CountRecords = ISNULL(@CountRecords,0)
                            + @CountRows
                    END
            END


    END
		
	--7) Export Exclusion Types...
    BEGIN
        IF OBJECT_ID(QUOTENAME(@DatabaseName) + '.CGF.[ExclusionTypes]') IS NOT NULL 
            BEGIN
                SET @Cmd = 'DROP TABLE ' + QUOTENAME(@DatabaseName)
                    + '.CGF.[ExclusionTypes]'
                EXEC (@Cmd)
            END

        SET @Cmd = 'SELECT	MXT.*,
					MXT.Abbrev AS ExclusionType
			INTO	' + QUOTENAME(@DatabaseName)
            + '.CGF.[ExclusionTypes]
			FROM	CGF_SYN.ExclusionTypes AS MXT WITH (NOLOCK) 
			
			CREATE CLUSTERED INDEX IX_ExclusionTypes ON '
            + QUOTENAME(@DatabaseName)
            + '.CGF.[ExclusionTypes] (ExclusionTypeGuid ASC)
			CREATE INDEX IX_ExclusionTypes_ExclusionType ON '
            + QUOTENAME(@DatabaseName)
            + '.CGF.[ExclusionTypes] (ExclusionType ASC)'

        IF @Cmd IS NOT NULL 
            BEGIN
                IF @PrintSql = 1 
                    PRINT @Cmd		

                IF @ExecuteSql = 1 
                    BEGIN 
                        EXEC @Result = sys.sp_executesql @statement = @Cmd
						
                        SET @CountRows = @@ROWCOUNT
                        SET @CountRecords = ISNULL(@CountRecords,0)
                            + @CountRows
                    END
            END
    END
		
	--8) Export Age Bands...
    BEGIN
        IF OBJECT_ID(QUOTENAME(@DatabaseName) + '.CGF.[AgeBands]') IS NOT NULL 
            BEGIN
                SET @Cmd = 'DROP TABLE ' + QUOTENAME(@DatabaseName)
                    + '.CGF.[AgeBands]'
                EXEC (@Cmd)
            END

        SET @Cmd = 'SELECT	MAB.*
			INTO	' + QUOTENAME(@DatabaseName) + '.CGF.[AgeBands]
			FROM	CGF_SYN.AgeBands AS MAB WITH (NOLOCK) 
			
			CREATE CLUSTERED INDEX IX_AgeBands ON '
            + QUOTENAME(@DatabaseName)
            + '.CGF.[AgeBands] (AgeBandGuid ASC)'

        IF @Cmd IS NOT NULL 
            BEGIN
                IF @PrintSql = 1 
                    PRINT @Cmd		

                IF @ExecuteSql = 1 
                    BEGIN 
                        EXEC @Result = sys.sp_executesql @statement = @Cmd
						
                        SET @CountRows = @@ROWCOUNT
                        SET @CountRecords = ISNULL(@CountRecords,0)
                            + @CountRows
                    END
            END
    END
		
	--9) Export Age Band Segments...
    BEGIN
        IF OBJECT_ID(QUOTENAME(@DatabaseName) + '.CGF.[AgeBandSegments]') IS NOT NULL 
            BEGIN
                SET @Cmd = 'DROP TABLE ' + QUOTENAME(@DatabaseName)
                    + '.CGF.[AgeBandSegments]'
                EXEC (@Cmd)
            END

        SET @Cmd = 'SELECT	MAB.*,
					MABS.AgeBandSegGuid,
					MABS.FromAgeMonths,
					MABS.FromAgeTotMonths,
					MABS.FromAgeYears,
					MG.Abbrev AS Gender,
					MABS.ToAgeMonths,
					MABS.ToAgeTotMonths,
					MABS.ToAgeYears,
					mabs.AgeBandSegID
			INTO	' + QUOTENAME(@DatabaseName)
            + '.CGF.[AgeBandSegments]
			FROM	CGF_SYN.AgeBands AS MAB WITH (NOLOCK) 
					INNER JOIN CGF_SYN.AgeBandSegments AS MABS WITH (NOLOCK) 
							ON MAB.AgeBandID = MABS.AgeBandID
					INNER JOIN CGF_SYN.Genders AS MG WITH (NOLOCK) 
							ON MABS.Gender = MG.Gender
							
			CREATE CLUSTERED INDEX IX_AgeBandSegments ON '
            + QUOTENAME(@DatabaseName)
            + '.CGF.[AgeBandSegments] (AgeBandSegGuid ASC)'

        IF @Cmd IS NOT NULL 
            BEGIN
                IF @PrintSql = 1 
                    PRINT @Cmd		

                IF @ExecuteSql = 1 
                    BEGIN 
                        EXEC @Result = sys.sp_executesql @statement = @Cmd
						
                        SET @CountRows = @@ROWCOUNT
                        SET @CountRecords = ISNULL(@CountRecords,0)
                            + @CountRows
                    END
            END
    END
		
	--10) Export Payers...
    BEGIN
        IF OBJECT_ID(QUOTENAME(@DatabaseName) + '.CGF.[Payers]') IS NOT NULL 
            BEGIN
                SET @Cmd = 'DROP TABLE ' + QUOTENAME(@DatabaseName)
                    + '.CGF.[Payers]'
                EXEC (@Cmd)
            END

        SET @Cmd = 'SELECT	PP.*,
					PP.Abbrev AS Payer
			INTO	' + QUOTENAME(@DatabaseName) + '.CGF.[Payers]
			FROM	CGF_SYN.Payers AS PP WITH (NOLOCK) 
			
			CREATE CLUSTERED INDEX IX_Payers ON '
            + QUOTENAME(@DatabaseName) + '.CGF.[Payers] (PayerGuid ASC)
			CREATE INDEX IX_Payers_Payer ON '
            + QUOTENAME(@DatabaseName) + '.CGF.[Payers] (Payer ASC)'

        IF @Cmd IS NOT NULL 
            BEGIN
                IF @PrintSql = 1 
                    PRINT @Cmd		

                IF @ExecuteSql = 1 
                    BEGIN 
                        EXEC @Result = sys.sp_executesql @statement = @Cmd
						
                        SET @CountRows = @@ROWCOUNT
                        SET @CountRecords = ISNULL(@CountRecords,0)
                            + @CountRows
                    END
            END
    END
		
	--11) Export Product Lines...
    BEGIN
        IF OBJECT_ID(QUOTENAME(@DatabaseName) + '.CGF.[ProductLines]') IS NOT NULL 
            BEGIN
                SET @Cmd = 'DROP TABLE ' + QUOTENAME(@DatabaseName)
                    + '.CGF.[ProductLines]'
                EXEC (@Cmd)
            END

        SET @Cmd = 'SELECT	PPL.*,
					PPL.Abbrev AS ProductLine
			INTO	' + QUOTENAME(@DatabaseName) + '.CGF.[ProductLines]
			FROM	CGF_SYN.ProductLines AS PPL WITH (NOLOCK) 
			
			CREATE CLUSTERED INDEX IX_ProductLines ON '
            + QUOTENAME(@DatabaseName)
            + '.CGF.[ProductLines] (ProductLineGuid ASC)
			CREATE INDEX IX_ProductLines_ProductLine ON '
            + QUOTENAME(@DatabaseName)
            + '.CGF.[ProductLines] (ProductLine ASC)'

        IF @Cmd IS NOT NULL 
            BEGIN
                IF @PrintSql = 1 
                    PRINT @Cmd		

                IF @ExecuteSql = 1 
                    BEGIN 
                        EXEC @Result = sys.sp_executesql @statement = @Cmd
						
                        SET @CountRows = @@ROWCOUNT
                        SET @CountRecords = ISNULL(@CountRecords,0)
                            + @CountRows
                    END
            END
    END
		
	--12) Export Result Types...
    BEGIN
        IF OBJECT_ID(QUOTENAME(@DatabaseName) + '.CGF.[ResultTypes]') IS NOT NULL 
            BEGIN
                SET @Cmd = 'DROP TABLE ' + QUOTENAME(@DatabaseName)
                    + '.CGF.[ResultTypes]'
                EXEC (@Cmd)
            END

        SET @Cmd = 'SELECT	RRT.*,
					RRT.Abbrev AS ResultType
			INTO	' + QUOTENAME(@DatabaseName) + '.CGF.[ResultTypes]
			FROM	CGF_SYN.ResultTypes AS RRT WITH (NOLOCK) 
			
			CREATE CLUSTERED INDEX IX_ResultTypes ON '
            + QUOTENAME(@DatabaseName)
            + '.CGF.[ResultTypes] (ResultTypeGuid ASC)
			CREATE INDEX IX_ResultTypes_ResultType ON '
            + QUOTENAME(@DatabaseName)
            + '.CGF.[ResultTypes] (ResultType ASC)'

        IF @Cmd IS NOT NULL 
            BEGIN
                IF @PrintSql = 1 
                    PRINT @Cmd		

                IF @ExecuteSql = 1 
                    BEGIN 
                        EXEC @Result = sys.sp_executesql @statement = @Cmd
						
                        SET @CountRows = @@ROWCOUNT
                        SET @CountRecords = ISNULL(@CountRecords,0)
                            + @CountRows
                    END
            END
    END

	--11) Export Data Runs
	BEGIN
		IF OBJECT_ID(QUOTENAME(@DatabaseName) + '.CGF.[DataRuns]') IS NOT NULL 
			BEGIN
				SET @Cmd = 'DROP TABLE ' + QUOTENAME(@DatabaseName)
					+ '.CGF.[DataRuns]'
				EXEC (@Cmd)
			END

		SET @Cmd = 'SELECT	BDR.BeginInitSeedDate AS BeginSeedDate,
							BDR.*,
							BDS.DataSetGuid,
							BDR.EndInitSeedDate AS EndSeedDate,
							MMS.Descr AS MeasureSet,
							MMM.Descr AS MemberMonths
					INTO	' + QUOTENAME(@DatabaseName) + '.CGF.[DataRuns]
					FROM	CGF_SYN.DataRuns AS BDR  WITH (NOLOCK) 
							INNER JOIN CGF_SYN.DataSets AS BDS WITH (NOLOCK) 
									ON BDR.DataSetID = BDS.DataSetID
							INNER JOIN CGF_SYN.MeasureSets AS MMS WITH (NOLOCK) 
									ON BDR.MeasureSetID = MMS.MeasureSetID
							INNER JOIN CGF_SYN.MemberMonths AS MMM WITH (NOLOCK) 
									ON BDR.MbrMonthID = MMM.MbrMonthID
			
					CREATE CLUSTERED INDEX IX_DataRuns ON '
			+ QUOTENAME(@DatabaseName) + '.CGF.[DataRuns] (DataRunGuid ASC)'

		IF @Cmd IS NOT NULL 
			BEGIN
				IF @PrintSql = 1 
					PRINT @Cmd		

				IF @ExecuteSql = 1 
					BEGIN 
						EXEC @Result = sys.sp_executesql @statement = @Cmd
						
						SET @CountRows = @@ROWCOUNT
						SET @CountRecords = ISNULL(@CountRecords,0) + @CountRows
					END
			END
	END

	--14) Export Data Sets...
	BEGIN
		IF OBJECT_ID(QUOTENAME(@DatabaseName) + '.CGF.[DataSets]') IS NOT NULL 
			BEGIN
				SET @Cmd = 'DROP TABLE ' + QUOTENAME(@DatabaseName)
					+ '.CGF.[DataSets]'
				EXEC (@Cmd)
			END

		SET @Cmd = 'SELECT	BDS.*,
							BDO.Descr AS DataSource,
							BDO.OwnerGuid AS DataSourceGuid
						
					INTO	' + QUOTENAME(@DatabaseName) + '.CGF.[DataSets]
					FROM	CGF_SYN.DataSets AS BDS WITH (NOLOCK) 
							INNER JOIN CGF_SYN.DataOwners AS BDO WITH (NOLOCK) 
									ON BDS.OwnerID = BDO.OwnerID
					WHERE bds.DataSetGuid IN (SELECT	BDS.DataSetGuid 
											FROM	CGF_SYN.DataRuns AS BDR  WITH (NOLOCK) 
													INNER JOIN CGF_SYN.DataSets AS BDS WITH (NOLOCK) 
															ON BDR.DataSetID = BDS.DataSetID
											)
			
					CREATE CLUSTERED INDEX IX_DataSets ON '
			+ QUOTENAME(@DatabaseName) + '.CGF.[DataSets] (DataSetGuid ASC)'

		IF @Cmd IS NOT NULL 
			BEGIN
				IF @PrintSql = 1 
					PRINT @Cmd		

				IF @ExecuteSql = 1 
					BEGIN 
						EXEC @Result = sys.sp_executesql @statement = @Cmd
						
						SET @CountRows = @@ROWCOUNT
						SET @CountRecords = ISNULL(@CountRecords,0) + @CountRows
					END
			END
	END

	--15) Export Members...
	BEGIN
		IF OBJECT_ID(QUOTENAME(@DatabaseName) + '.CGF.[Members]') IS NOT NULL 
			BEGIN
				SET @Cmd = 'DROP TABLE ' + QUOTENAME(@DatabaseName)
					+ '.CGF.[Members]'
				EXEC (@Cmd)
			END

		SET @Cmd = 'SELECT t.*
						INTO	' + QUOTENAME(@DatabaseName) + '.CGF.Members
						FROM	CGF_SYN.Members AS t WITH (NOLOCK) '
		
			--			CREATE CLUSTERED INDEX IX_Members ON '
			--+ QUOTENAME(@DatabaseName)
			--+ '.CGF.Members (CustomerMemberID ASC, DataRunGuid ASC, IhdsMemberID ASC)
			--			CREATE INDEX IX_Members_IMIXref ON '
			--+ QUOTENAME(@DatabaseName) + '.CGF.Members (IMIXref ASC)'

		IF @Cmd IS NOT NULL 
			BEGIN
				IF @PrintSql = 1 
					PRINT @Cmd		

				IF @ExecuteSql = 1 
					BEGIN 
						EXEC @Result = sys.sp_executesql @statement = @Cmd
						
						SET @CountRows = @@ROWCOUNT
						SET @CountRecords = ISNULL(@CountRecords,0) + @CountRows
					END
			END
	END

	--16) Export Providers...
	BEGIN
		IF OBJECT_ID(QUOTENAME(@DatabaseName) + '.CGF.[Providers]') IS NOT NULL 
			BEGIN
				SET @Cmd = 'DROP TABLE ' + QUOTENAME(@DatabaseName)
					+ '.CGF.[Providers]'
				EXEC (@Cmd)
			END

		SET @Cmd = 'SELECT 
								t.*,
								BDR.DataRunGuid,
								BDS.DataSetGuid
						INTO	' + QUOTENAME(@DatabaseName) + '.CGF.[Providers]
						FROM	CGF_SYN.DataSetProviderKey AS t WITH (NOLOCK) 
								INNER JOIN CGF_SYN.DataRuns AS BDR WITH (NOLOCK) 
										ON t.DataRunID = BDR.DataRunID
								INNER JOIN CGF_SYN.DataSets AS BDS WITH (NOLOCK) 
										ON BDR.DataSetID = BDS.DataSetID
						WHERE	(t.DataRunID = ' + CONVERT(VARCHAR(10),@DataRunID)
			+ ' )
			
						CREATE CLUSTERED INDEX IX_Providers ON '
			+ QUOTENAME(@DatabaseName)
			+ '.dbo.Providers (CustomerProviderID ASC, DataRunGuid ASC)
						CREATE INDEX IX_Providers_IMIXref ON '
			+ QUOTENAME(@DatabaseName) + '.dbo.Providers (IMIXref ASC)'

		IF @Cmd IS NOT NULL 
			BEGIN
				IF @PrintSql = 1 
					PRINT @Cmd		

				IF @ExecuteSql = 1 
					BEGIN 
						EXEC @Result = sys.sp_executesql @statement = @Cmd
						
						SET @CountRows = @@ROWCOUNT
						SET @CountRecords = ISNULL(@CountRecords,0) + @CountRows
					END
			END
	END
	
	--17) Export Medical Groups...
	BEGIN
		IF OBJECT_ID(QUOTENAME(@DatabaseName) + '.CGF.[MedicalGroups]') IS NOT NULL 
			BEGIN
				SET @Cmd = 'DROP TABLE ' + QUOTENAME(@DatabaseName)
					+ '.CGF.[MedicalGroups]'
				EXEC (@Cmd)
			END

		SET @Cmd = 'SELECT	 
								t.*,
								BDR.DataRunGuid,
								BDS.DataSetGuid,
								t.RegionName AS OrgName,
								t.SubRegionName AS SubOrgName
						INTO	' + QUOTENAME(@DatabaseName)+ '.CGF.[MedicalGroups]
						FROM	CGF_SYN.DataSetMedicalGroupKey AS t WITH (NOLOCK) 
								INNER JOIN CGF_SYN.DataRuns AS BDR WITH (NOLOCK) 
										ON t.DataRunID = BDR.DataRunID
								INNER JOIN CGF_SYN.DataSets AS BDS WITH (NOLOCK) 
										ON BDR.DataSetID = BDS.DataSetID
						WHERE	(t.DataRunID = ' + CONVERT(VARCHAR(10),@DataRunID)
			+ ' )
			
						CREATE CLUSTERED INDEX IX_MedicalGroups ON '
			+ QUOTENAME(@DatabaseName)
			+ '.dbo.MedicalGroups (CustomerMedicalGroupID ASC, DataRunGuid ASC)'

		IF @Cmd IS NOT NULL 
			BEGIN
				IF @PrintSql = 1 
					PRINT @Cmd		

				IF @ExecuteSql = 1 
					BEGIN 
						EXEC @Result = sys.sp_executesql @statement = @Cmd
						
						SET @CountRows = @@ROWCOUNT
						SET @CountRecords = ISNULL(@CountRecords,0) + @CountRows
					END
			END
	END

END	

IF @bBuildResults = 1 
BEGIN
	--DECLARE @vcFilterInit VARCHAR(1) 

	IF OBJECT_ID('CGF.MeasureSets') IS NOT NULL 
		DROP TABLE CGF.MeasureSets 

	SELECT *
		INTO CGF.MeasureSets 
		FROM CGF_SYN.MeasureSets  WITH (NOLOCK) 

	--IF OBJECT_ID('CGF.Members') IS NOT NULL 
	--	DROP TABLE CGF.Members

	--SELECT * 
	--	INTO CGF.Members
	--	FROM CGF_SYN.Members

	IF object_id('CGF.DataSetProviderKey') IS NOT NULL
		DROP TABLE CGF.DataSetProviderKey

	SELECT *
		INTO CGF.DataSetProviderKey
		FROM CGF_SYN.DataSetProviderKey WITH (NOLOCK) 

	IF object_id('CGF.DataOwners') IS NOT NULL
		DROP TABLE CGF.DataOwners

	SELECT *
		INTO CGF.DataOwners
		FROM CGF_SYN.DataOwners WITH (NOLOCK) 


	IF object_id('CGF.MeasureXrefs') IS NOT NULL
		DROP TABLE CGF.MeasureXrefs

	SELECT *
		INTO CGF.MeasureXrefs
		FROM CGF_SYN.MeasureXrefs WITH (NOLOCK) 

	IF object_id('CGF.MetricXrefs') IS NOT NULL
		DROP TABLE CGF.MetricXrefs

	SELECT *
		INTO CGF.MetricXrefs
		FROM CGF_SYN.MetricXrefs WITH (NOLOCK) 

	IF object_id('CGF.EnrollmentPopulations') IS NOT NULL
		DROP TABLE CGF.EnrollmentPopulations

	SELECT *
		INTO CGF.EnrollmentPopulations
		FROM CGF_SYN.EnrollmentPopulations WITH (NOLOCK) 

	IF object_id('CGF.Genders') IS NOT NULL
		DROP TABLE CGF.Genders

	SELECT *
		INTO CGF.Genders
		FROM CGF_SYN.Genders WITH (NOLOCK) 
	

	IF object_id('CGF.EnrollmentGroups') IS NOT NULL
		DROP TABLE CGF.EnrollmentGroups

	SELECT *
		INTO CGF.EnrollmentGroups
		FROM CGF_SYN.EnrollmentGroups WITH (NOLOCK) 

	IF OBJECT_ID('tempdb..#step1') IS NOT NULL 
		DROP TABLE #step1

	SELECT bdr.EndInitSeedDate,
            MeasureSet = mms.Descr,
            RDSMK.IHDSMemberID,
            BDR.DataRunGuid,
            t.MeasureXrefID,
            t.MetricXrefID,
            ProductLineDesc = MAX(PPL.Descr),
            AgeMonths = MAX(t.AgeMonths)
		INTO #Step1
        FROM CGF.MeasureDetail AS t WITH (NOLOCK) 
            INNER JOIN #DataRuns AS BDR WITH (NOLOCK) 
                ON t.DataRunID = BDR.DataRunID
            INNER JOIN CGF.MeasureSets mms WITH (NOLOCK) 
                ON BDR.MeasureSetID = MMS.MeasureSetID
            INNER JOIN CGF.ProductLines AS PPL WITH (NOLOCK) 
                ON t.ProductLineID = PPL.ProductLineID 
            INNER JOIN CGF.Members AS RDSMK WITH (NOLOCK) 
                ON t.DataSetID = RDSMK.DataSetID
                AND t.DSMemberID = RDSMK.DSMemberID
			INNER JOIN CGF.MeasureXrefs AS MMXR
				ON t.MeasureXrefID = MMXR.MeasureXrefID
			INNER JOIN cgf.ClientMeasureFilter cmf -- Filter to Client Specific Measures
				ON LEFT(mmxr.Abbrev,3) = cmf.MeasureInit 
			--LEFT OUTER JOIN CGF_SYN.DataSetMemberKey AS RDSMK
			--		ON t.DataRunID = RDSMK.DataRunID AND
			--			t.DataSetID = RDSMK.DataSetID AND
			--			t.DSMemberID = RDSMK.DSMemberID
        GROUP BY bdr.EndInitSeedDate,
            mms.Descr,
            RDSMK.IHDSMemberID,
            BDR.DataRunGuid,
            t.MeasureXrefID,
            t.MetricXrefID

        IF OBJECT_ID('tempdb..#filter') IS NOT NULL 
            DROP TABLE #filter

        SELECT t.ResultRowGuid
            INTO #filter
            FROM CGF.MeasureDetail AS t WITH (NOLOCK) 
                INNER JOIN #DataRuns AS BDR
                    ON t.DataRunID = BDR.DataRunID
                INNER JOIN CGF.MeasureSets mms WITH (NOLOCK) 
                    ON BDR.MeasureSetID = MMS.MeasureSetID
                INNER JOIN CGF.ProductLines AS PPL WITH (NOLOCK) 
                    ON t.ProductLineID = PPL.ProductLineID
                INNER JOIN CGF.Members AS RDSMK WITH (NOLOCK) 
                    ON t.DataSetID = RDSMK.DataSetID
                       AND t.DSMemberID = RDSMK.DSMemberID 
				INNER JOIN member m WITH (NOLOCK) 
					ON rdsmk.IhdsMemberID = m.ihds_member_id
--					AND LEFT(m.NameLast,1) = ISNULL(@vcFilterInit,LEFT(m.NameLast,1))
			   --LEFT OUTER JOIN cgf_syn.DataSetMemberKey AS RDSMK
				--		ON t.DataRunID = RDSMK.DataRunID AND
				--			t.DataSetID = RDSMK.DataSetID AND
				--			t.DSMemberID = RDSMK.DSMemberID
                INNER JOIN #Step1 filter
                    ON filter.EndInitSeedDate = bdr.EndInitSeedDate
                       AND filter.MeasureSet = mms.Descr
                       AND filter.IHDSMemberID = RDSMK.IHDSMemberID
                       AND filter.DataRunGuid = BDR.DataRunGuid
                       AND filter.MeasureXrefID = t.MeasureXrefID
                       AND filter.MetricXrefID = t.MetricXrefID
                       AND filter.ProductLineDesc = PPL.Descr
                       AND filter.AgeMonths = t.AgeMonths

        CREATE INDEX fk ON #filter (ResultRowGuid)
        CREATE STATISTICS sp ON #filter (ResultRowGuid)

		IF OBJECT_ID('CGF.ResultsByMember') IS NOT NULL 
		BEGIN
			SELECT @vcCmd = 'SELECT * INTO CGF.ResultsByMember_'
					+ CONVERT(VARCHAR(8),GETDATE(),112) + '_'
					+ CONVERT(VARCHAR(2),DATEPART(HOUR,GETDATE())) + '_'
					+ CONVERT(VARCHAR(2),DATEPART(Minute,GETDATE()))
					+ ' FROM CGF.ResultsByMember '
			PRINT @vcCmd
			EXEC (@vcCmd)

			DROP TABLE CGF.ResultsByMember
		END

		IF OBJECT_ID('tempdb..#res') is not null 
			DROP TABLE #res

		SELECT --TOP 10000
				BeginSeedDate = bdr.BeginInitSeedDate,
				EndSeedDate = bdr.EndInitSeedDate,
				MeasureSet = mms.Descr,
				RDSMK.IHDSMemberID,
				t.Age,
				t.AgeMonths,
				MG.Abbrev AS Gender,
				BDR.DataRunGuid,
				BDS.DataSetGuid,
				BDO.OwnerGuid AS DataSourceGuid,
				MXT.Abbrev AS ExclusionType,
				MXT.ExclusionTypeGuid,
				IsDenominator = CONVERT(INT,t.IsDenominator),
				IsExclusion = CONVERT(INT,t.IsExclusion),
				IsNumerator = CONVERT(INT,t.IsNumerator),
				--IsNumeratorAdmin = CONVERT(INT,t.IsNumeratorAdmin),
				--IsNumeratorMedRcd = CONVERT(INT,t.IsNumeratorMedRcd),
				Measure = MMXR.Abbrev,
				MeasureDesc = mmxr.Descr,
				MMXR.MeasureXrefGuid,
				Metric = MXXR.Abbrev,
				MetricDesc = mxxr.Descr,
				MXXR.MetricXrefGuid,
				t.ResultRowGuid,
				RRT.Abbrev AS ResultType,
				RRT.ResultTypeGuid,
				PopulationDesc = mep.descr,
				EnrollmentGroupDesc = eg.Descr,
				ENrollmentGroupNum = eg.GroupNum
			INTO #res
			FROM CGF.MeasureDetail AS t WITH (NOLOCK) 
				INNER JOIN CGF.DataRuns AS BDR WITH (NOLOCK) 
					ON t.DataRunID = BDR.DataRunID
--AND bdr.CreatedDate in (SELECT MAX(CreatedDate) FROM CGF.dataruns GROUP BY EndSeedDate)
				INNER JOIN CGF.MeasureSets mms WITH (NOLOCK) 
					ON BDR.MeasureSetID = MMS.MeasureSetID
				INNER JOIN CGF.ProductLines AS PPL WITH (NOLOCK) 
					ON t.ProductLineID = PPL.ProductLineID
				INNER JOIN CGF.Members AS RDSMK WITH (NOLOCK) 
					ON t.DataSetID = RDSMK.DataSetID
					AND t.DSMemberID = RDSMK.DSMemberID
					--LEFT OUTER JOIN CGF_SYN.DataSetMemberKey AS RDSMK
					--		ON t.DataRunID = RDSMK.DataRunID AND
					--			t.DataSetID = RDSMK.DataSetID AND
					--			t.DSMemberID = RDSMK.DSMemberID
				INNER JOIN CGF.DataSets AS BDS WITH (NOLOCK) 
					ON BDR.DataSetID = BDS.DataSetID
				INNER JOIN CGF.DataOwners AS BDO WITH (NOLOCK) 
					ON BDS.OwnerID = BDO.OwnerID
				INNER JOIN CGF.MeasureXrefs AS MMXR
					ON t.MeasureXrefID = MMXR.MeasureXrefID
				INNER JOIN CGF.MetricXrefs AS MXXR
					ON t.MetricXrefID = MXXR.MetricXrefID
				INNER JOIN CGF.Payers AS PP
					ON t.PayerID = PP.PayerID
				LEFT OUTER JOIN CGF.EnrollmentPopulations AS MEP
					ON t.PopulationID = MEP.PopulationID
				INNER JOIN CGF.ResultTypes AS RRT
					ON t.ResultTypeID = RRT.ResultTypeID
				LEFT OUTER JOIN CGF.Genders AS MG
					ON t.Gender = MG.Gender
				LEFT OUTER JOIN CGF.ExclusionTypes AS MXT
					ON t.ExclusionTypeID = MXT.ExclusionTypeID
				LEFT OUTER JOIN CGF.AgeBands AS MAB
					ON t.AgeBandID = MAB.AgeBandID
				LEFT OUTER JOIN CGF.AgeBandSegments AS MABS
					ON t.AgeBandSegID = MABS.AgeBandSegID
				LEFT OUTER JOIN CGF.DataSetProviderKey AS RDSPK
					ON t.DataRunID = RDSPK.DataRunID
						AND t.DataSetID = RDSPK.DataSetID
						AND t.DSProviderID = RDSPK.DSProviderID
				LEFT JOIN CGF.EnrollmentGroups eg
					ON t.EnrollGroupID= eg.EnrollGroupID

        SELECT m.Client,
                t1.BeginSeedDate ,
                t1.EndSeedDate ,
                t1.MeasureSet ,
                CustomerMemberID = m.CustomerMemberID,
                t1.IHDSMemberID,
                t1.Age,
                t1.AgeMonths,
                t1.Gender,
                t1.DataRunGuid,
                t1.DataSetGuid,
                t1.DataSourceGuid,
                t1.ExclusionType,
                t1.ExclusionTypeGuid,
                t1.IsDenominator,-- = CONVERT(INT,t1.IsDenominator),
                t1.IsExclusion,-- = CONVERT(INT,t1.IsExclusion),
                t1.IsNumerator,-- = CONVERT(INT,t1.IsNumerator),
                --IsNumeratorAdmin = CONVERT(INT,t.IsNumeratorAdmin),
                --IsNumeratorMedRcd = CONVERT(INT,t.IsNumeratorMedRcd),
                t1.Measure ,
                t1.MeasureDesc ,
                t1.MeasureXrefGuid,
                t1.Metric ,
                t1.MetricDesc ,
                t1.MetricXrefGuid,
                MeasureMetricDesc = ISNULL(cm.MeasureMetricDesc,(t1.Measure + '-' + t1.Metric)),
                t1.ResultRowGuid,
                t1.ResultType,
                t1.ResultTypeGuid,
                m.MemberID,
                fe.EligibilityID,
                mp.MemberProviderID,
                p.ProviderID,
                pmg.ProviderMedicalGroupID,
				PopulationDesc = t1.PopulationDesc,
				EnrollmentGroupNum = EnrollmentGroupNum,
				EnrollmentGroupDesc = EnrollmentGroupDesc
            INTO CGF.ResultsByMember
			FROM #res t1
				INNER JOIN #filter filter
					ON filter.ResultRowGuid = t1.ResultRowGuid
                LEFT JOIN CGF.MeasureMetrics cm
                    ON t1.MetricXrefGuid = cm.MetricXrefGuid
                INNER JOIN member m
                    ON t1.IHDSMemberID = m.ihds_member_id
                LEFT JOIN Eligibility fe
                    ON m.MemberID = fe.MemberID
                       AND CONVERT(VARCHAR(8),t1.EndSeedDate,112) BETWEEN CONVERT(VARCHAR(8),fe.DateEffective,112)
                                                              AND
                                                              ISNULL(CONVERT(VARCHAR(8),fe.DateTerminated,112),
                                                              '29981231')
					   AND t1.EnrollmentGroupNum = fe.ProductType
                LEFT JOIN MemberProvider mp
                    ON m.memberid = mp.MemberID
                       AND CONVERT(VARCHAR(8),t1.EndSeedDate,112) BETWEEN CONVERT(VARCHAR(8),mp.DateEffective,112)
                                                              AND
                                                              ISNULL(CONVERT(VARCHAR(8),mp.DateTerminated,112),
                                                              '29981231')
                LEFT JOIN Provider p
                    ON mp.ProviderID = p.ProviderID 
                LEFT JOIN ProviderMedicalGroup pmg
                    ON mp.ProviderMedicalGroupID = pmg.ProviderMedicalGroupID	

	IF OBJECT_ID('CGF.ResultsByMember_sum') IS NOT NULL 
		DROP TABLE CGF.ResultsByMember_sum

	SELECT client,
			EndSeedDate ,
			MeasureSet ,
			rbm.Measure,
			rbm.MeasureDesc,
			cm.MeasureMetricDesc,
			IsNumerator = SUM(IsNumerator) ,
			IsDenominator = SUM(IsDenominator) ,
			ComplianceRate = CONVERT(NUMERIC(8,4),SUM(IsNumerator)/(SUM(IsDenominator)*1.0))
		INTO CGF.ResultsByMember_sum
		FROM CGF.ResultsByMember rbm
			INNER JOIN CGF.MeasureMetrics cm
				ON rbm.MetricXrefGuid = cm.MetricXrefGuid
		GROUP BY client,
			EndSeedDate ,
			rbm.MeasureSet ,
			rbm.Measure,
			rbm.MeasureDesc,
			cm.MeasureMetricDesc
		HAVING SUM(IsDenominator) > 0


        SELECT client,
                EndSeedDate,
                IsDenominator = SUM(CONVERT(INT,IsDenominator)),
                IsNumerator = SUM(CONVERT(INT,IsNumerator)),
                DistinctMember = COUNT(DISTINCT IHDSMemberID)
            FROM CGF.ResultsByMember a
            GROUP BY client,
                EndSeedDate



    END	

	--CGF Lookup tables
	IF OBJECT_ID('CGF.ClientList') IS NOT NULL
		DROP TABLE CGF.ClientList

	SELECT Distinct Client
		INTO CGF.ClientList
		FROM CGF.ResultsByMember_sum

	IF OBJECT_ID('CGF.EndSeedDateList') IS NOT NULL
		DROP TABLE CGF.EndSeedDateList

	SELECT DISTINCT EndSeedDate
		INTO CGF.EndSeedDateList
		FROM CGF.ResultsByMember rbm
		WHERE rbm.IsDenominator >= 1

	IF OBJECT_ID('CGF.MetricDescList') IS NOT NULL 
		DROP TABLE CGF.MetricDescList

	SELECT DISTINCT
		cm.MeasureDesc
		INTO CGF.MetricDescList
		FROM cgf.resultsByMember rbm
			INNER JOIN CGF.MeasureMetrics cm
				ON rbm.MetricXrefGuid = cm.MetricXrefGuid
		WHERE rbm.IsDenominator = 1 
		ORDER BY cm.MeasureDesc

        

	-- INdexes
	CREATE INDEX idxResultByMember
		ON [CGF].[ResultsByMember] ([IsDenominator], Client, EndSeedDate,PopulationDesc )
		INCLUDE ([IHDSMemberID],[DataRunGuid],[IsNumerator],[MeasureXrefGuid],[MetricXrefGuid])

	create statistics sp_idxResultByMember ON [CGF].[ResultsByMember] ([IsDenominator], Client, EndSeedDate,[PopulationDesc] )

	SELECT CNT = COUNT(*), DistinctRowGuid = COUNT(DISTINCT ResultRowGuid) FROM cgf.ResultsByMember


-----------------------------------------------------------------------------------------------
-- Old Code
/*
SELECT 
		fm.client,
		dr.BeginSeedDate,
		dr.EndSeedDate,
		dr.MeasureSet,

		rbm.CustomerMemberID ,
		rbm.IHDSMemberId,
        rbm.DataRunGuid ,
        rbm.DataSetGuid ,
        rbm.DataSourceGuid ,
        IsDenominator = CONVERT(INT, rbm.IsDenominator) ,
        IsNumerator = CONVERT(INT, rbm.IsNumerator) ,
        rbm.KeyDate ,
        rbm.Measure ,
		MeasureDesc = me.Descr,
        rbm.MeasureXrefGuid ,
        rbm.Metric ,
		MetricDesc = mt.Descr,
        rbm.MetricXrefGuid ,
		cm.MeasureMetricDesc,
        fm.MemberID ,
        fe.EligibilityID ,
        mp.MemberProviderID ,
        p.ProviderID ,
        pmg.ProviderMedicalGroupID
INTO CGF_ResultsByMember
    FROM ResultsByMember AS rbm
		INNER JOIN dbo.CGF_Measures cm
			ON rbm.MetricXrefGuid = cm.MetricXrefGuid
        INNER JOIN (SELECT DataRunGuid ,
                            IHDSMemberID ,
                            Measure ,
                            Metric ,
                            MAX(ProductLine) AS ProductLine ,
                            MAX(AgeMonths) AS AgeMonths
                        FROM ResultsByMember
                        GROUP BY DataRunGuid ,
                            IHDSMemberID ,
                            Measure ,
                            Metric
                   ) AS flt
            ON rbm.DataRunGuid=flt.DataRunGuid
               AND rbm.IHDSMemberID=flt.IHDSMemberID
               AND rbm.Measure=flt.Measure
               AND rbm.Metric=flt.Metric
               AND rbm.ProductLine=flt.ProductLine
               AND rbm.AgeMonths=flt.AgeMonths
        INNER JOIN dbo.DataRuns dr
            ON rbm.DataRunGuid=dr.DataRunGuid
		INNER JOIN dbo.Measures me
			ON rbm.MeasureXrefGuid = me.MeasureXrefGuid
		INNER JOIN dbo.Metrics mt
			ON rbm.MetricXrefGuid = mt.MetricXrefGuid
        INNER JOIN Member fm
            ON rbm.ihdsmemberid=fm.ihds_member_id
        INNER JOIN Eligibility fe
            ON fm.MemberID=fe.MemberID
               AND CONVERT(VARCHAR(8), dr.EndSeedDate, 112) BETWEEN CONVERT(VARCHAR(8), fe.DateEffective, 112)
                                                            AND     ISNULL(CONVERT(VARCHAR(8), fe.DateTerminated, 112),
                                                                           '29981231')
        LEFT JOIN MemberProvider mp
            ON fm.memberid=mp.MemberID
               AND CONVERT(VARCHAR(8), dr.EndSeedDate, 112) BETWEEN CONVERT(VARCHAR(8), mp.DateEffective, 112)
                                                            AND     ISNULL(CONVERT(VARCHAR(8), mp.DateTerminated, 112),
                                                                           '29981231')
        LEFT JOIN Provider p
            ON mp.ProviderID=p.ProviderID 
        LEFT JOIN ProviderMedicalGroup pmg
            ON mp.ProviderMedicalGroupID=pmg.ProviderMedicalGroupID	

IF OBJECT_ID('CGF_ResultsByMember_sum') IS NOT NULL 
	DROP TABLE CGF_ResultsByMember_sum

SELECT client,
        EndSeedDate ,
        MeasureSet ,
		rbm.Measure,
		rbm.MeasureDesc,
		cm.MeasureMetricDesc,
		cm.ClientFocusFlag,
        IsNumerator = SUM(IsNumerator) ,
        IsDenominator = SUM(IsDenominator) ,
        ComplianceRate = CONVERT(NUMERIC(8,4),SUM(IsNumerator)/(SUM(IsDenominator)*1.0))
	INTO CGF_ResultsByMember_sum
	FROM dbo.CGF_ResultsByMember rbm
		INNER JOIN dbo.CGF_Measures cm
			ON rbm.MetricXrefGuid = cm.MetricXrefGuid
    GROUP BY client,
        EndSeedDate ,
        rbm.MeasureSet ,
		rbm.Measure,
		rbm.MeasureDesc,
		cm.MeasureMetricDesc,
		cm.ClientFocusFlag
	HAVING SUM(IsDenominator) > 0


*/

GO
