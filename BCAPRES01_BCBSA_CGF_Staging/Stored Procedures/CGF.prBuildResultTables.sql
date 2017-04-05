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
FROM VERISK_PROD_QME.Batch.DataRuns AS BDR

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
Process:	
Test Script: 

select * FROM VERISK_PROD_QME.Batch.DataRuns
exec [CGF].[prBuildResultTables] 5,5,'X'

ToDo:		

*/


----Note: still need to change databasesource by hand
--/*
CREATE PROC [CGF].[prBuildResultTables] 

@bMinDataRunID INT = NULL,
@bMaxDataRunID INT = NULL,
@vcFilterInit VARCHAR(1) = NULL

AS
	--SET NOCOUNT ON
--*/

/*-------------------------------------------
DECLARE @bMinDataRunID INT = '5'
DECLARE @bMaxDataRunID INT = '5'
DECLARE @vcFilterInit VARCHAR(1) = NULL
--*/-------------------------------------------

DECLARE @vcCmd VARCHAR(2000)
DECLARE @DatabaseName VARCHAR(100) = 'VERISK_IMIStaging'

DECLARE @Cmd NVARCHAR(MAX)
DECLARE @CountRecords INT
DECLARE @CountRows INT
DECLARE @Result INT = 0
DECLARE @DataRunID INT
DECLARE @QINetSource VARCHAR(200) = 'VERISK_PROD_QME'    
DECLARE @PrintSql BIT = 1
DECLARE @ExecuteSql BIT = 1


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
		FROM VERISK_PROD_QME.Batch.DataRuns

IF OBJECT_ID('tempdb..#dataruns') IS NOT NULL 
    DROP TABLE #dataRuns

SELECT *
    INTO #DataRuns
    FROM VERISK_PROD_QME.Batch.DataRuns AS BDR
    WHERE DataRunID BETWEEN @bMinDataRunID AND @bMaxDataRunID

CREATE INDEX dk ON  #DataRuns (DataRunID, MeasureSetID, EndInitSeedDate, DataRunGuid)
CREATE STATISTICS sp ON  #DataRuns (DataRunID, MeasureSetID, EndInitSeedDate, DataRunGuid)

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

        SET @Cmd = 'SELECT	MMXR.Descr,
					MMXR.Abbrev AS Measure,
					MMXR.MeasureXrefGuid
			INTO	' + QUOTENAME(@DatabaseName) + '.CGF.[Measures]
			FROM	' + @QINetSource + '.Measure.MeasureXrefs AS MMXR
			
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

        SET @Cmd = 'SELECT	MXXR.Descr,
					MMXR.MeasureXrefGuid,
					MXXR.Abbrev AS Metric,
					MXXR.MetricXrefGuid,
					IsShown = CASE WHEN mi.Abbrev IS NULL THEN 0 ELSE 1 END,
					m.ScoreTypeID
			INTO	' + QUOTENAME(@DatabaseName) + '.CGF.[Metrics]
			FROM	' + @QINetSource + '.Measure.MetricXrefs AS MXXR
					INNER JOIN ' + @QINetSource + '.Measure.MeasureXrefs AS MMXR
						ON MXXR.MeasureXrefID = MMXR.MeasureXrefID
					LEFT JOIN (SELECT Abbrev FROM ' + @QINetSource + '.Measure.Metrics m WHERE IsShown = 1 GROUP BY Abbrev) mi
						ON MXXR.Abbrev = mi.Abbrev
					INNER JOIN (select Abbrev, ScoreTypeID = MAX(ScoreTypeID) 
									from ' + @QINetSource + '.measure.metrics m
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
						FROM ' + @QINetSource + '.Result.MeasureDetail AS t
							INNER JOIN ' + @QINetSource + '.Measure.MeasureXrefs AS MMXR
								ON t.MeasureXrefID = MMXR.MeasureXrefID
							INNER JOIN ' + @QINetSource + '.Measure.MetricXrefs AS MXXR
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

        SET @Cmd = 'SELECT	MXT.Descr,
					MXT.Abbrev AS ExclusionType,
					MXT.ExclusionTypeGuid
			INTO	' + QUOTENAME(@DatabaseName)
            + '.CGF.[ExclusionTypes]
			FROM	' + @QINetSource + '.Measure.ExclusionTypes AS MXT
			
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

        SET @Cmd = 'SELECT	MAB.AgeBandGuid,
					MAB.Descr
			INTO	' + QUOTENAME(@DatabaseName) + '.CGF.[AgeBands]
			FROM	' + @QINetSource + '.Measure.AgeBands AS MAB
			
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

        SET @Cmd = 'SELECT	MAB.AgeBandGuid,
					MABS.AgeBandSegGuid,
					MABS.Descr,
					MABS.FromAgeMonths,
					MABS.FromAgeTotMonths,
					MABS.FromAgeYears,
					MG.Abbrev AS Gender,
					MABS.ToAgeMonths,
					MABS.ToAgeTotMonths,
					MABS.ToAgeYears
			INTO	' + QUOTENAME(@DatabaseName)
            + '.CGF.[AgeBandSegments]
			FROM	' + @QINetSource + '.Measure.AgeBands AS MAB
					INNER JOIN ' + @QINetSource
            + '.Measure.AgeBandSegments AS MABS
							ON MAB.AgeBandID = MABS.AgeBandID
					INNER JOIN ' + @QINetSource + '.Member.Genders AS MG
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

        SET @Cmd = 'SELECT	PP.Descr,
					PP.Abbrev AS Payer,
					PP.PayerGuid
			INTO	' + QUOTENAME(@DatabaseName) + '.CGF.[Payers]
			FROM	' + @QINetSource + '.Product.Payers AS PP
			
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

        SET @Cmd = 'SELECT	PPL.Descr,
					PPL.Abbrev AS ProductLine,
					PPL.ProductLineGuid
			INTO	' + QUOTENAME(@DatabaseName) + '.CGF.[ProductLines]
			FROM	' + @QINetSource + '.Product.ProductLines AS PPL
			
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

        SET @Cmd = 'SELECT	RRT.Descr,
					RRT.Abbrev AS ResultType,
					RRT.ResultTypeGuid
			INTO	' + QUOTENAME(@DatabaseName) + '.CGF.[ResultTypes]
			FROM	' + @QINetSource + '.Result.ResultTypes AS RRT
			
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
							BDR.CreatedDate,
							BDR.DataRunGuid,
							BDS.DataSetGuid,
							BDR.EndInitSeedDate AS EndSeedDate,
							MMS.Descr AS MeasureSet,
							MMM.Descr AS MemberMonths,
							BDR.SeedDate
					INTO	' + QUOTENAME(@DatabaseName) + '.CGF.[DataRuns]
					FROM	' + @QINetSource + '.Batch.DataRuns AS BDR 
							INNER JOIN ' + @QINetSource + '.Batch.DataSets AS BDS
									ON BDR.DataSetID = BDS.DataSetID
							INNER JOIN ' + @QINetSource
			+ '.Measure.MeasureSets AS MMS
									ON BDR.MeasureSetID = MMS.MeasureSetID
							INNER JOIN ' + @QINetSource
			+ '.Measure.MemberMonths AS MMM
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

		SET @Cmd = 'SELECT	--BDS.CountClaimLines,
							--BDS.CountEnrollment,
							--BDS.CountMembers,
							--BDS.CountProviders,
							BDS.CreatedDate,
							BDS.DataSetGuid,
							BDO.Descr AS DataSource,
							BDO.OwnerGuid AS DataSourceGuid
					INTO	' + QUOTENAME(@DatabaseName) + '.CGF.[DataSets]
					FROM	' + @QINetSource + '.Batch.DataSets AS BDS
							INNER JOIN ' + @QINetSource
			+ '.Batch.DataOwners AS BDO
									ON BDS.OwnerID = BDO.OwnerID
					WHERE bds.DataSetGuid IN (SELECT	BDS.DataSetGuid 
											FROM	VERISK_PROD_QME.Batch.DataRuns AS BDR 
													INNER JOIN VERISK_PROD_QME.Batch.DataSets AS BDS
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

		SET @Cmd = 'SELECT 
								t.CustomerMemberID,
								BDR.DataRunGuid,
								BDS.DataSetGuid,
								t.DOB,
								MG.Abbrev AS Gender,
								t.HicNumber,
								t.IhdsMemberID,
								t.DisplayID AS IMIXref,
								t.NameFirst,
								t.NameLast,
								REPLACE(t.SsnDisplay, ''-'', '''') AS Ssn
						INTO	' + QUOTENAME(@DatabaseName) + '.CGF.[Members]
						FROM	' + @QINetSource + '.Result.DataSetMemberKey AS t
								INNER JOIN ' + @QINetSource
			+ '.Member.Genders AS MG
										ON t.Gender = MG.Gender
								INNER JOIN ' + @QINetSource
			+ '.Batch.DataRuns AS BDR
										ON t.DataRunID = BDR.DataRunID
								INNER JOIN ' + @QINetSource
			+ '.Batch.DataSets AS BDS
										ON BDR.DataSetID = BDS.DataSetID
						--WHERE	(t.DataRunID = ' + CONVERT(VARCHAR(10),@DataRunID)
			+ ')
			
						CREATE CLUSTERED INDEX IX_Members ON '
			+ QUOTENAME(@DatabaseName)
			+ '.dbo.Members (CustomerMemberID ASC, DataRunGuid ASC, IhdsMemberID ASC)
						CREATE INDEX IX_Members_IMIXref ON '
			+ QUOTENAME(@DatabaseName) + '.dbo.Members (IMIXref ASC)'

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
								t.CustomerProviderID,
								BDR.DataRunGuid,
								BDS.DataSetGuid,
								--t.IhdsProviderID,
								t.DisplayID AS IMIXref,
								t.ProviderName
						INTO	' + QUOTENAME(@DatabaseName) + '.CGF.[Providers]
						FROM	' + @QINetSource
			+ '.Result.DataSetProviderKey AS t
								INNER JOIN ' + @QINetSource
			+ '.Batch.DataRuns AS BDR
										ON t.DataRunID = BDR.DataRunID
								INNER JOIN ' + @QINetSource
			+ '.Batch.DataSets AS BDS
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
								t.CustomerMedicalGroupID,
								BDR.DataRunGuid,
								BDS.DataSetGuid,
								t.MedGrpName,
								t.RegionName AS OrgName,
								t.SubRegionName AS SubOrgName
						INTO	' + QUOTENAME(@DatabaseName)
			+ '.CGF.[MedicalGroups]
						FROM	' + @QINetSource
			+ '.Result.DataSetMedicalGroupKey AS t
								INNER JOIN ' + @QINetSource
			+ '.Batch.DataRuns AS BDR
										ON t.DataRunID = BDR.DataRunID
								INNER JOIN ' + @QINetSource
			+ '.Batch.DataSets AS BDS
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
	--SELECT * FROM VERISK_PROD_QME.Batch.DataRuns
	--DECLARE @vcFilterInit VARCHAR(1) 
        IF OBJECT_ID('tempdb..#filter') IS NOT NULL 
            DROP TABLE #filter

        SELECT t.ResultRowGuid
            INTO #filter
            FROM VERISK_PROD_QME.Result.MeasureDetail AS t
                INNER JOIN #DataRuns AS BDR
                    ON t.DataRunID = BDR.DataRunID
                INNER JOIN VERISK_PROD_QME.Measure.MeasureSets mms
                    ON BDR.MeasureSetID = MMS.MeasureSetID
                INNER JOIN VERISK_PROD_QME.Product.ProductLines AS PPL
                    ON t.ProductLineID = PPL.ProductLineID
                INNER JOIN VERISK_PROD_QME.member.Members AS RDSMK
                    ON t.DataSetID = RDSMK.DataSetID
                       AND t.DSMemberID = RDSMK.DSMemberID 
INNER JOIN DHMP_IMIStaging_PROD.dbo.member m
	ON rdsmk.IhdsMemberID = m.ihds_member_id
	AND LEFT(m.NameLast,1) = ISNULL(@vcFilterInit,LEFT(m.NameLast,1))
			   --LEFT OUTER JOIN VERISK_PROD_QME.Result.DataSetMemberKey AS RDSMK
				--		ON t.DataRunID = RDSMK.DataRunID AND
				--			t.DataSetID = RDSMK.DataSetID AND
				--			t.DSMemberID = RDSMK.DSMemberID
                INNER JOIN (SELECT bdr.EndInitSeedDate,
                                    MeasureSet = mms.Descr,
                                    RDSMK.IHDSMemberID,
                                    BDR.DataRunGuid,
                                    t.MeasureXrefID,
                                    t.MetricXrefID,
                                    ProductLineDesc = MAX(PPL.Descr),
                                    AgeMonths = MAX(t.AgeMonths)
                                FROM VERISK_PROD_QME.Result.MeasureDetail
                                    AS t
                                    INNER JOIN #DataRuns AS BDR
                                        ON t.DataRunID = BDR.DataRunID
                                    INNER JOIN VERISK_PROD_QME.Measure.MeasureSets mms
                                        ON BDR.MeasureSetID = MMS.MeasureSetID
                                    INNER JOIN VERISK_PROD_QME.Product.ProductLines
                                    AS PPL
                                        ON t.ProductLineID = PPL.ProductLineID 
                                    INNER JOIN VERISK_PROD_QME.member.Members
                                    AS RDSMK
                                        ON t.DataSetID = RDSMK.DataSetID
                                           AND t.DSMemberID = RDSMK.DSMemberID
									--LEFT OUTER JOIN VERISK_PROD_QME.Result.DataSetMemberKey AS RDSMK
									--		ON t.DataRunID = RDSMK.DataRunID AND
									--			t.DataSetID = RDSMK.DataSetID AND
									--			t.DSMemberID = RDSMK.DSMemberID
                                GROUP BY bdr.EndInitSeedDate,
                                    mms.Descr,
                                    RDSMK.IHDSMemberID,
                                    BDR.DataRunGuid,
                                    t.MeasureXrefID,
                                    t.MetricXrefID
                           ) filter
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
			FROM VERISK_PROD_QME.Result.MeasureDetail AS t
				INNER JOIN VERISK_PROD_QME.Batch.DataRuns AS BDR
					ON t.DataRunID = BDR.DataRunID
--AND bdr.CreatedDate in (SELECT MAX(CreatedDate) FROM CGF.dataruns GROUP BY EndSeedDate)
				INNER JOIN VERISK_PROD_QME.Measure.MeasureSets mms
					ON BDR.MeasureSetID = MMS.MeasureSetID
				INNER JOIN VERISK_PROD_QME.Product.ProductLines AS PPL
					ON t.ProductLineID = PPL.ProductLineID
				INNER JOIN VERISK_PROD_QME.member.Members AS RDSMK
					ON t.DataSetID = RDSMK.DataSetID
						AND t.DSMemberID = RDSMK.DSMemberID
					--LEFT OUTER JOIN VERISK_PROD_QME.Result.DataSetMemberKey AS RDSMK
					--		ON t.DataRunID = RDSMK.DataRunID AND
					--			t.DataSetID = RDSMK.DataSetID AND
					--			t.DSMemberID = RDSMK.DSMemberID
				INNER JOIN VERISK_PROD_QME.Batch.DataSets AS BDS
					ON BDR.DataSetID = BDS.DataSetID
				INNER JOIN VERISK_PROD_QME.Batch.DataOwners AS BDO
					ON BDS.OwnerID = BDO.OwnerID
				INNER JOIN VERISK_PROD_QME.Measure.MeasureXrefs AS MMXR
					ON t.MeasureXrefID = MMXR.MeasureXrefID
				INNER JOIN VERISK_PROD_QME.Measure.MetricXrefs AS MXXR
					ON t.MetricXrefID = MXXR.MetricXrefID
				INNER JOIN VERISK_PROD_QME.Product.Payers AS PP
					ON t.PayerID = PP.PayerID
				LEFT OUTER JOIN VERISK_PROD_QME.Member.EnrollmentPopulations AS MEP
					ON t.PopulationID = MEP.PopulationID
				INNER JOIN VERISK_PROD_QME.Result.ResultTypes AS RRT
					ON t.ResultTypeID = RRT.ResultTypeID
				LEFT OUTER JOIN VERISK_PROD_QME.Member.Genders AS MG
					ON t.Gender = MG.Gender
				LEFT OUTER JOIN VERISK_PROD_QME.Measure.ExclusionTypes AS MXT
					ON t.ExclusionTypeID = MXT.ExclusionTypeID
				LEFT OUTER JOIN VERISK_PROD_QME.Measure.AgeBands AS MAB
					ON t.AgeBandID = MAB.AgeBandID
				LEFT OUTER JOIN VERISK_PROD_QME.Measure.AgeBandSegments AS MABS
					ON t.AgeBandSegID = MABS.AgeBandSegID
				LEFT OUTER JOIN VERISK_PROD_QME.Result.DataSetProviderKey AS RDSPK
					ON t.DataRunID = RDSPK.DataRunID
						AND t.DataSetID = RDSPK.DataSetID
						AND t.DSProviderID = RDSPK.DSProviderID
				LEFT JOIN verisk_prod_qme.Member.EnrollmentGroups eg
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
		FROM CGF.ResultsByMember_sum rbm
		WHERE rbm.IsDenominator = 1

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
