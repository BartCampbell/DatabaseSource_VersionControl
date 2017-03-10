SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Kriz, Mike
-- Create date: 8/20/2012
-- Description:	Exports a standard set of tables to the specified database for use by clients and partners.
-- =============================================
CREATE PROCEDURE [Export].[CopyResultsToDB]
( 
	@DatabaseName nvarchar(128),
	@ExecuteSql bit = 1,
	@PrintSql bit = 0
)
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @Cmd nvarchar(max);
	DECLARE @CountRecords int;
	DECLARE @CountRows int;
	DECLARE @Result int;

	IF db_id(@DatabaseName) IS NULL
		BEGIN;
			RAISERROR('The specified database is invalid.', 16, 1);
				
			SET @Result = 1;
		END;
	ELSE
		SET @Result = 0;


	--1) Export "Member-Level Detail"...
	IF @Result = 0
		BEGIN;
			IF OBJECT_ID(QUOTENAME(@DatabaseName) + '.[dbo].[ResultsByMember]') IS NOT NULL
				BEGIN;
					SET @Cmd = 'DROP TABLE ' + QUOTENAME(@DatabaseName) + '.[dbo].[ResultsByMember]';
					EXEC (@Cmd);
				END;

			SET @Cmd = 
			'SELECT	t.Age,
					t.AgeMonths,
					MAB.AgeBandGuid,
					MABS.AgeBandSegGuid,
					RDSMK.CustomerMemberID,
					BDR.DataRunGuid,
					BDS.DataSetGuid,
					BDO.OwnerGuid AS DataSourceGuid,
					t.[Days],
					MXT.Abbrev AS ExclusionType,
					MXT.ExclusionTypeGuid,
					MG.Abbrev AS Gender,
					t.IsDenominator,
					t.IsExclusion,
					t.IsIndicator,
					t.IsNumerator,
					t.IsNumeratorAdmin,
					t.IsNumeratorMedRcd,
					t.KeyDate,
					MMXR.Abbrev AS Measure,
					MMXR.MeasureXrefGuid,
					MXXR.Abbrev AS Metric,
					MXXR.MetricXrefGuid,
					PP.Abbrev AS Payer,
					PP.PayerGuid AS PayerGuid,
					MEP.Abbrev AS PopulationName,
					MEP.PopulationNum,
					MEP.PopulationGuid,
					PPL.Abbrev AS ProductLine,
					PPL.ProductLineGuid,
					t.Qty,
					t.ResultRowGuid,
					RRT.Abbrev AS ResultType,
					RRT.ResultTypeGuid
			INTO	' + QUOTENAME(@DatabaseName) + '.[dbo].[ResultsByMember]
			FROM	Result.MeasureDetail AS t
					INNER JOIN Batch.DataRuns AS BDR
							ON t.DataRunID = BDR.DataRunID
					INNER JOIN Batch.DataSets AS BDS 
							ON BDR.DataSetID = BDS.DataSetID
					INNER JOIN Batch.DataOwners AS BDO
							ON BDS.OwnerID = BDO.OwnerID
					INNER JOIN Measure.MeasureXrefs AS MMXR
							ON t.MeasureXrefID = MMXR.MeasureXrefID
					INNER JOIN Measure.MetricXrefs AS MXXR
							ON t.MetricXrefID = MXXR.MetricXrefID
					INNER JOIN Product.Payers AS PP
							ON t.PayerID = PP.PayerID
					LEFT OUTER JOIN Member.EnrollmentPopulations AS MEP
							ON t.PopulationID = MEP.PopulationID
					INNER JOIN Product.ProductLines AS PPL
							ON t.ProductLineID = PPL.ProductLineID
					INNER JOIN Result.ResultTypes AS RRT
							ON t.ResultTypeID = RRT.ResultTypeID
					LEFT OUTER JOIN Member.Genders AS MG
							ON t.Gender = MG.Gender
					LEFT OUTER JOIN Measure.ExclusionTypes AS MXT
							ON t.ExclusionTypeID = MXT.ExclusionTypeID
					LEFT OUTER JOIN Measure.AgeBands AS MAB
							ON t.AgeBandID = MAB.AgeBandID
					LEFT OUTER JOIN Measure.AgeBandSegments AS MABS
							ON t.AgeBandSegID = MABS.AgeBandSegID
					LEFT OUTER JOIN Result.DataSetMemberKey AS RDSMK
							ON t.DataRunID = RDSMK.DataRunID AND
								t.DataSetID = RDSMK.DataSetID AND
								t.DSMemberID = RDSMK.DSMemberID
					LEFT OUTER JOIN Result.DataSetProviderKey AS RDSPK
							ON t.DataRunID = RDSPK.DataRunID AND
								t.DataSetID = RDSPK.DataSetID AND
								t.DSProviderID = RDSPK.DSProviderID
			WHERE	(t.DataRunID IN (SELECT DISTINCT DataRunID FROM Result.DataSetRunKey WHERE IsShown = 1));
			
			CREATE UNIQUE CLUSTERED INDEX IX_ResultsByMember ON ' + QUOTENAME(@DatabaseName) + '.[dbo].[ResultsByMember] (ResultRowGuid ASC);';

			IF @Cmd IS NOT NULL 
				BEGIN;
					IF @PrintSql = 1
						PRINT @Cmd;		

					IF @ExecuteSql = 1
						BEGIN; 
							EXEC @Result = sys.sp_executesql @statement = @Cmd;
						
							SET @CountRows = @@ROWCOUNT;
							SET @CountRecords = ISNULL(@CountRecords, 0) + @CountRows;
						END;
				END;
		END;
		

	--2) Export "Provider-Level Detail"...
	IF @Result = 0
		BEGIN;
			IF OBJECT_ID(QUOTENAME(@DatabaseName) + '.[dbo].[ResultsByProvider]') IS NOT NULL
				BEGIN;
					SET @Cmd = 'DROP TABLE ' + QUOTENAME(@DatabaseName) + '.[dbo].[ResultsByProvider]';
					EXEC (@Cmd);
				END;

			SET @Cmd = 
			'SELECT	MAB.AgeBandGuid,
					MABS.AgeBandSegGuid,
					RDSMGK.CustomerMedicalGroupID,
					RDSPK.CustomerProviderID,
					BDR.DataRunGuid,
					BDS.DataSetGuid,
					BDO.OwnerGuid AS DataSourceGuid,
					t.[Days],
					MG.Abbrev AS Gender,
					t.IsDenominator,
					t.IsExclusion,
					t.IsIndicator,
					t.IsNumerator,
					t.IsNumeratorAdmin,
					t.IsNumeratorMedRcd,
					MMXR.Abbrev AS Measure,
					MMXR.MeasureXrefGuid,
					MXXR.Abbrev AS Metric,
					MXXR.MetricXrefGuid,
					PP.Abbrev AS Payer,
					PP.PayerGuid AS PayerGuid,
					MEP.Abbrev AS PopulationName,
					MEP.PopulationNum,
					MEP.PopulationGuid,
					PPL.Abbrev AS ProductLine,
					PPL.ProductLineGuid,
					t.Qty,
					t.ResultRowGuid,
					RRT.Abbrev AS ResultType,
					RRT.ResultTypeGuid
			INTO	' + QUOTENAME(@DatabaseName) + '.[dbo].[ResultsByProvider]
			FROM	Result.MeasureProviderSummary AS t
					INNER JOIN Batch.DataRuns AS BDR
							ON t.DataRunID = BDR.DataRunID
					INNER JOIN Batch.DataSets AS BDS 
							ON BDR.DataSetID = BDS.DataSetID
					INNER JOIN Batch.DataOwners AS BDO
							ON BDS.OwnerID = BDO.OwnerID
					INNER JOIN Measure.MeasureXrefs AS MMXR
							ON t.MeasureXrefID = MMXR.MeasureXrefID
					INNER JOIN Measure.MetricXrefs AS MXXR
							ON t.MetricXrefID = MXXR.MetricXrefID
					INNER JOIN Product.Payers AS PP
							ON t.PayerID = PP.PayerID
					LEFT OUTER JOIN Member.EnrollmentPopulations AS MEP
							ON t.PopulationID = MEP.PopulationID
					INNER JOIN Product.ProductLines AS PPL
							ON t.ProductLineID = PPL.ProductLineID
					INNER JOIN Result.ResultTypes AS RRT
							ON t.ResultTypeID = RRT.ResultTypeID
					LEFT OUTER JOIN Member.Genders AS MG
							ON t.Gender = MG.Gender
					LEFT OUTER JOIN Measure.AgeBands AS MAB
							ON t.AgeBandID = MAB.AgeBandID
					LEFT OUTER JOIN Measure.AgeBandSegments AS MABS
							ON t.AgeBandSegID = MABS.AgeBandSegID
					LEFT OUTER JOIN Result.DataSetMedicalGroupKey AS RDSMGK
							ON t.DataRunID = RDSMGK.DataRunID AND
								t.DataSetID = RDSMGK.DataSetID AND
								t.MedGrpID = RDSMGK.MedGrpID
					LEFT OUTER JOIN Result.DataSetProviderKey AS RDSPK
							ON t.DataRunID = RDSPK.DataRunID AND
								t.DataSetID = RDSPK.DataSetID AND
								t.DSProviderID = RDSPK.DSProviderID
			WHERE	(t.DataRunID IN (SELECT DISTINCT DataRunID FROM Result.DataSetRunKey WHERE IsShown = 1));
			
			CREATE UNIQUE CLUSTERED INDEX IX_ResultsByProvider ON ' + QUOTENAME(@DatabaseName) + '.[dbo].[ResultsByProvider] (ResultRowGuid ASC);';

			IF @Cmd IS NOT NULL 
				BEGIN;
					IF @PrintSql = 1
						PRINT @Cmd;		

					IF @ExecuteSql = 1
						BEGIN; 
							EXEC @Result = sys.sp_executesql @statement = @Cmd;
						
							SET @CountRows = @@ROWCOUNT;
							SET @CountRecords = ISNULL(@CountRecords, 0) + @CountRows;
						END;
				END;
		END;
		
	--3) Export "Measure-Level Detail"...
	IF @Result = 0
		BEGIN;
			IF OBJECT_ID(QUOTENAME(@DatabaseName) + '.[dbo].[ResultsSummary]') IS NOT NULL
				BEGIN;
					SET @Cmd = 'DROP TABLE ' + QUOTENAME(@DatabaseName) + '.[dbo].[ResultsSummary]';
					EXEC (@Cmd);
				END;

			SET @Cmd = 
			'SELECT	MAB.AgeBandGuid,
					MABS.AgeBandSegGuid,
					BDR.DataRunGuid,
					BDS.DataSetGuid,
					BDO.OwnerGuid AS DataSourceGuid,
					t.[Days],
					MG.Abbrev AS Gender,
					t.IsDenominator,
					t.IsExclusion,
					t.IsIndicator,
					t.IsNumerator,
					t.IsNumeratorAdmin,
					t.IsNumeratorMedRcd,
					MMXR.Abbrev AS Measure,
					MMXR.MeasureXrefGuid,
					MXXR.Abbrev AS Metric,
					MXXR.MetricXrefGuid,
					PP.Abbrev AS Payer,
					PP.PayerGuid AS PayerGuid,
					MEP.Abbrev AS PopulationName,
					MEP.PopulationNum,
					MEP.PopulationGuid,
					PPL.Abbrev AS ProductLine,
					PPL.ProductLineGuid,
					t.Qty,
					t.ResultRowGuid,
					RRT.Abbrev AS ResultType,
					RRT.ResultTypeGuid
			INTO	' + QUOTENAME(@DatabaseName) + '.[dbo].[ResultsSummary]
			FROM	Result.MeasureSummary AS t
					INNER JOIN Batch.DataRuns AS BDR
							ON t.DataRunID = BDR.DataRunID
					INNER JOIN Batch.DataSets AS BDS 
							ON BDR.DataSetID = BDS.DataSetID
					INNER JOIN Batch.DataOwners AS BDO
							ON BDS.OwnerID = BDO.OwnerID
					INNER JOIN Measure.MeasureXrefs AS MMXR
							ON t.MeasureXrefID = MMXR.MeasureXrefID
					INNER JOIN Measure.MetricXrefs AS MXXR
							ON t.MetricXrefID = MXXR.MetricXrefID
					INNER JOIN Product.Payers AS PP
							ON t.PayerID = PP.PayerID
					LEFT OUTER JOIN Member.EnrollmentPopulations AS MEP
							ON t.PopulationID = MEP.PopulationID
					INNER JOIN Product.ProductLines AS PPL
							ON t.ProductLineID = PPL.ProductLineID
					INNER JOIN Result.ResultTypes AS RRT
							ON t.ResultTypeID = RRT.ResultTypeID
					LEFT OUTER JOIN Member.Genders AS MG
							ON t.Gender = MG.Gender
					LEFT OUTER JOIN Measure.AgeBands AS MAB
							ON t.AgeBandID = MAB.AgeBandID
					LEFT OUTER JOIN Measure.AgeBandSegments AS MABS
							ON t.AgeBandSegID = MABS.AgeBandSegID
			WHERE	(t.DataRunID IN (SELECT DISTINCT DataRunID FROM Result.DataSetRunKey WHERE IsShown = 1));
			
			CREATE UNIQUE CLUSTERED INDEX IX_ResultsSummary ON ' + QUOTENAME(@DatabaseName) + '.[dbo].[ResultsSummary] (ResultRowGuid ASC);';

			IF @Cmd IS NOT NULL 
				BEGIN;
					IF @PrintSql = 1
						PRINT @Cmd;		

					IF @ExecuteSql = 1
						BEGIN; 
							EXEC @Result = sys.sp_executesql @statement = @Cmd;
						
							SET @CountRows = @@ROWCOUNT;
							SET @CountRecords = ISNULL(@CountRecords, 0) + @CountRows;
						END;
				END;
		END;

	--4) Export "Event-Level Detail"...
		
	--5) Export Measures...
	IF @Result = 0
		BEGIN;
			IF OBJECT_ID(QUOTENAME(@DatabaseName) + '.[dbo].[Measures]') IS NOT NULL
				BEGIN;
					SET @Cmd = 'DROP TABLE ' + QUOTENAME(@DatabaseName) + '.[dbo].[Measures]';
					EXEC (@Cmd);
				END;

			SET @Cmd = 
			'SELECT	MMXR.Descr,
					MMXR.Abbrev AS Measure,
					MMXR.MeasureXrefGuid
			INTO	' + QUOTENAME(@DatabaseName) + '.[dbo].[Measures]
			FROM	Measure.MeasureXrefs AS MMXR;
			
			CREATE UNIQUE CLUSTERED INDEX IX_Measures ON ' + QUOTENAME(@DatabaseName) + '.[dbo].[Measures] (MeasureXrefGuid ASC);
			CREATE UNIQUE INDEX IX_Measures_Measure ON ' + QUOTENAME(@DatabaseName) + '.[dbo].[Measures] (Measure ASC);';

			IF @Cmd IS NOT NULL 
				BEGIN;
					IF @PrintSql = 1
						PRINT @Cmd;		

					IF @ExecuteSql = 1
						BEGIN; 
							EXEC @Result = sys.sp_executesql @statement = @Cmd;
						
							SET @CountRows = @@ROWCOUNT;
							SET @CountRecords = ISNULL(@CountRecords, 0) + @CountRows;
						END;
				END;
		END;
		
	--6) Export Metrics...
	IF @Result = 0
		BEGIN;
			IF OBJECT_ID(QUOTENAME(@DatabaseName) + '.[dbo].[Metrics]') IS NOT NULL
				BEGIN;
					SET @Cmd = 'DROP TABLE ' + QUOTENAME(@DatabaseName) + '.[dbo].[Metrics]';
					EXEC (@Cmd);
				END;

			SET @Cmd = 
			'SELECT	MXXR.Descr,
					MMXR.MeasureXrefGuid,
					MXXR.Abbrev AS Metric,
					MXXR.MetricXrefGuid
			INTO	' + QUOTENAME(@DatabaseName) + '.[dbo].[Metrics]
			FROM	Measure.MetricXrefs AS MXXR
					INNER JOIN Measure.MeasureXrefs AS MMXR
							ON MXXR.MeasureXrefID = MMXR.MeasureXrefID;
			
			CREATE UNIQUE CLUSTERED INDEX IX_Metrics ON ' + QUOTENAME(@DatabaseName) + '.[dbo].[Metrics] (MetricXrefGuid ASC);
			CREATE UNIQUE INDEX IX_Metrics_Metric ON ' + QUOTENAME(@DatabaseName) + '.[dbo].[Metrics] (Metric ASC);';

			IF @Cmd IS NOT NULL 
				BEGIN;
					IF @PrintSql = 1
						PRINT @Cmd;		

					IF @ExecuteSql = 1
						BEGIN; 
							EXEC @Result = sys.sp_executesql @statement = @Cmd;
						
							SET @CountRows = @@ROWCOUNT;
							SET @CountRecords = ISNULL(@CountRecords, 0) + @CountRows;
						END;
				END;
		END;
		
	--7) Export Exclusion Types...
	IF @Result = 0
		BEGIN;
			IF OBJECT_ID(QUOTENAME(@DatabaseName) + '.[dbo].[ExclusionTypes]') IS NOT NULL
				BEGIN;
					SET @Cmd = 'DROP TABLE ' + QUOTENAME(@DatabaseName) + '.[dbo].[ExclusionTypes]';
					EXEC (@Cmd);
				END;

			SET @Cmd = 
			'SELECT	MXT.Descr,
					MXT.Abbrev AS ExclusionType,
					MXT.ExclusionTypeGuid
			INTO	' + QUOTENAME(@DatabaseName) + '.[dbo].[ExclusionTypes]
			FROM	Measure.ExclusionTypes AS MXT;
			
			CREATE UNIQUE CLUSTERED INDEX IX_ExclusionTypes ON ' + QUOTENAME(@DatabaseName) + '.[dbo].[ExclusionTypes] (ExclusionTypeGuid ASC);
			CREATE UNIQUE INDEX IX_ExclusionTypes_ExclusionType ON ' + QUOTENAME(@DatabaseName) + '.[dbo].[ExclusionTypes] (ExclusionType ASC);';

			IF @Cmd IS NOT NULL 
				BEGIN;
					IF @PrintSql = 1
						PRINT @Cmd;		

					IF @ExecuteSql = 1
						BEGIN; 
							EXEC @Result = sys.sp_executesql @statement = @Cmd;
						
							SET @CountRows = @@ROWCOUNT;
							SET @CountRecords = ISNULL(@CountRecords, 0) + @CountRows;
						END;
				END;
		END;
		
	--8) Export Age Bands...
	IF @Result = 0
		BEGIN;
			IF OBJECT_ID(QUOTENAME(@DatabaseName) + '.[dbo].[AgeBands]') IS NOT NULL
				BEGIN;
					SET @Cmd = 'DROP TABLE ' + QUOTENAME(@DatabaseName) + '.[dbo].[AgeBands]';
					EXEC (@Cmd);
				END;

			SET @Cmd = 
			'SELECT	MAB.AgeBandGuid,
					MAB.Descr
			INTO	' + QUOTENAME(@DatabaseName) + '.[dbo].[AgeBands]
			FROM	Measure.AgeBands AS MAB;
			
			CREATE UNIQUE CLUSTERED INDEX IX_AgeBands ON ' + QUOTENAME(@DatabaseName) + '.[dbo].[AgeBands] (AgeBandGuid ASC);';

			IF @Cmd IS NOT NULL 
				BEGIN;
					IF @PrintSql = 1
						PRINT @Cmd;		

					IF @ExecuteSql = 1
						BEGIN; 
							EXEC @Result = sys.sp_executesql @statement = @Cmd;
						
							SET @CountRows = @@ROWCOUNT;
							SET @CountRecords = ISNULL(@CountRecords, 0) + @CountRows;
						END;
				END;
		END;
		
	--9) Export Age Band Segments...
	IF @Result = 0
		BEGIN;
			IF OBJECT_ID(QUOTENAME(@DatabaseName) + '.[dbo].[AgeBandSegments]') IS NOT NULL
				BEGIN;
					SET @Cmd = 'DROP TABLE ' + QUOTENAME(@DatabaseName) + '.[dbo].[AgeBandSegments]';
					EXEC (@Cmd);
				END;

			SET @Cmd = 
			'SELECT	MAB.AgeBandGuid,
					MABS.AgeBandSegGuid,
					MABS.Descr,
					MABS.FromAgeMonths,
					MABS.FromAgeTotMonths,
					MABS.FromAgeYears,
					MG.Abbrev AS Gender,
					MABS.ToAgeMonths,
					MABS.ToAgeTotMonths,
					MABS.ToAgeYears
			INTO	' + QUOTENAME(@DatabaseName) + '.[dbo].[AgeBandSegments]
			FROM	Measure.AgeBands AS MAB
					INNER JOIN Measure.AgeBandSegments AS MABS
							ON MAB.AgeBandID = MABS.AgeBandID
					INNER JOIN Member.Genders AS MG
							ON MABS.Gender = MG.Gender;
							
			CREATE UNIQUE CLUSTERED INDEX IX_AgeBandSegments ON ' + QUOTENAME(@DatabaseName) + '.[dbo].[AgeBandSegments] (AgeBandSegGuid ASC);';

			IF @Cmd IS NOT NULL 
				BEGIN;
					IF @PrintSql = 1
						PRINT @Cmd;		

					IF @ExecuteSql = 1
						BEGIN; 
							EXEC @Result = sys.sp_executesql @statement = @Cmd;
						
							SET @CountRows = @@ROWCOUNT;
							SET @CountRecords = ISNULL(@CountRecords, 0) + @CountRows;
						END;
				END;
		END;
		
	--10) Export Payers...
	IF @Result = 0
		BEGIN;
			IF OBJECT_ID(QUOTENAME(@DatabaseName) + '.[dbo].[Payers]') IS NOT NULL
				BEGIN;
					SET @Cmd = 'DROP TABLE ' + QUOTENAME(@DatabaseName) + '.[dbo].[Payers]';
					EXEC (@Cmd);
				END;

			SET @Cmd = 
			'SELECT	PP.Descr,
					PP.Abbrev AS Payer,
					PP.PayerGuid
			INTO	' + QUOTENAME(@DatabaseName) + '.[dbo].[Payers]
			FROM	Product.Payers AS PP;
			
			CREATE UNIQUE CLUSTERED INDEX IX_Payers ON ' + QUOTENAME(@DatabaseName) + '.[dbo].[Payers] (PayerGuid ASC);
			CREATE UNIQUE INDEX IX_Payers_Payer ON ' + QUOTENAME(@DatabaseName) + '.[dbo].[Payers] (Payer ASC);';

			IF @Cmd IS NOT NULL 
				BEGIN;
					IF @PrintSql = 1
						PRINT @Cmd;		

					IF @ExecuteSql = 1
						BEGIN; 
							EXEC @Result = sys.sp_executesql @statement = @Cmd;
						
							SET @CountRows = @@ROWCOUNT;
							SET @CountRecords = ISNULL(@CountRecords, 0) + @CountRows;
						END;
				END;
		END;
		
	--11) Export Product Lines...
	IF @Result = 0
		BEGIN;
			IF OBJECT_ID(QUOTENAME(@DatabaseName) + '.[dbo].[ProductLines]') IS NOT NULL
				BEGIN;
					SET @Cmd = 'DROP TABLE ' + QUOTENAME(@DatabaseName) + '.[dbo].[ProductLines]';
					EXEC (@Cmd);
				END;

			SET @Cmd = 
			'SELECT	PPL.Descr,
					PPL.Abbrev AS ProductLine,
					PPL.ProductLineGuid
			INTO	' + QUOTENAME(@DatabaseName) + '.[dbo].[ProductLines]
			FROM	Product.ProductLines AS PPL;
			
			CREATE UNIQUE CLUSTERED INDEX IX_ProductLines ON ' + QUOTENAME(@DatabaseName) + '.[dbo].[ProductLines] (ProductLineGuid ASC);
			CREATE UNIQUE INDEX IX_ProductLines_ProductLine ON ' + QUOTENAME(@DatabaseName) + '.[dbo].[ProductLines] (ProductLine ASC);';

			IF @Cmd IS NOT NULL 
				BEGIN;
					IF @PrintSql = 1
						PRINT @Cmd;		

					IF @ExecuteSql = 1
						BEGIN; 
							EXEC @Result = sys.sp_executesql @statement = @Cmd;
						
							SET @CountRows = @@ROWCOUNT;
							SET @CountRecords = ISNULL(@CountRecords, 0) + @CountRows;
						END;
				END;
		END;
		
	--12) Export Result Types...
	IF @Result = 0
		BEGIN;
			IF OBJECT_ID(QUOTENAME(@DatabaseName) + '.[dbo].[ResultTypes]') IS NOT NULL
				BEGIN;
					SET @Cmd = 'DROP TABLE ' + QUOTENAME(@DatabaseName) + '.[dbo].[ResultTypes]';
					EXEC (@Cmd);
				END;

			SET @Cmd = 
			'SELECT	RRT.Descr,
					RRT.Abbrev AS ResultType,
					RRT.ResultTypeGuid
			INTO	' + QUOTENAME(@DatabaseName) + '.[dbo].[ResultTypes]
			FROM	Result.ResultTypes AS RRT;
			
			CREATE UNIQUE CLUSTERED INDEX IX_ResultTypes ON ' + QUOTENAME(@DatabaseName) + '.[dbo].[ResultTypes] (ResultTypeGuid ASC);
			CREATE UNIQUE INDEX IX_ResultTypes_ResultType ON ' + QUOTENAME(@DatabaseName) + '.[dbo].[ResultTypes] (ResultType ASC);';

			IF @Cmd IS NOT NULL 
				BEGIN;
					IF @PrintSql = 1
						PRINT @Cmd;		

					IF @ExecuteSql = 1
						BEGIN; 
							EXEC @Result = sys.sp_executesql @statement = @Cmd;
						
							SET @CountRows = @@ROWCOUNT;
							SET @CountRecords = ISNULL(@CountRecords, 0) + @CountRows;
						END;
				END;
		END;
		

	--13) Export Data Runs...
	IF @Result = 0
		BEGIN;
			IF OBJECT_ID(QUOTENAME(@DatabaseName) + '.[dbo].[DataRuns]') IS NOT NULL
				BEGIN;
					SET @Cmd = 'DROP TABLE ' + QUOTENAME(@DatabaseName) + '.[dbo].[DataRuns]';
					EXEC (@Cmd);
				END;

			SET @Cmd = 
			'SELECT	BDR.BeginInitSeedDate AS BeginSeedDate,
					BDR.CreatedDate,
					BDR.DataRunGuid,
					BDS.DataSetGuid,
					BDR.EndInitSeedDate AS EndSeedDate,
					MMS.Descr AS MeasureSet,
					MMM.Descr AS MemberMonths,
					BDR.SeedDate
			INTO	' + QUOTENAME(@DatabaseName) + '.[dbo].[DataRuns]
			FROM	Batch.DataRuns AS BDR 
					INNER JOIN Batch.DataSets AS BDS
							ON BDR.DataSetID = BDS.DataSetID
					INNER JOIN Measure.MeasureSets AS MMS
							ON BDR.MeasureSetID = MMS.MeasureSetID
					INNER JOIN Measure.MemberMonths AS MMM
							ON BDR.MbrMonthID = MMM.MbrMonthID
			WHERE	(BDR.DataRunID IN (SELECT DISTINCT DataRunID FROM Result.DataSetRunKey WHERE IsShown = 1));
			
			CREATE UNIQUE CLUSTERED INDEX IX_DataRuns ON ' + QUOTENAME(@DatabaseName) + '.[dbo].[DataRuns] (DataRunGuid ASC);';

			IF @Cmd IS NOT NULL 
				BEGIN;
					IF @PrintSql = 1
						PRINT @Cmd;		

					IF @ExecuteSql = 1
						BEGIN; 
							EXEC @Result = sys.sp_executesql @statement = @Cmd;
						
							SET @CountRows = @@ROWCOUNT;
							SET @CountRecords = ISNULL(@CountRecords, 0) + @CountRows;
						END;
				END;
		END;
		

	--14) Export Data Sets...
	IF @Result = 0
		BEGIN;
			IF OBJECT_ID(QUOTENAME(@DatabaseName) + '.[dbo].[DataSets]') IS NOT NULL
				BEGIN;
					SET @Cmd = 'DROP TABLE ' + QUOTENAME(@DatabaseName) + '.[dbo].[DataSets]';
					EXEC (@Cmd);
				END;

			SET @Cmd = 
			'SELECT	--BDS.CountClaimLines,
					--BDS.CountEnrollment,
					--BDS.CountMembers,
					--BDS.CountProviders,
					BDS.CreatedDate,
					BDS.DataSetGuid,
					BDO.Descr AS DataSource,
					BDO.OwnerGuid AS DataSourceGuid
			INTO	' + QUOTENAME(@DatabaseName) + '.[dbo].[DataSets]
			FROM	Batch.DataSets AS BDS
					INNER JOIN Batch.DataOwners AS BDO
							ON BDS.OwnerID = BDO.OwnerID
			WHERE	(BDS.DataSetID IN (SELECT DISTINCT DataSetID FROM Result.DataSetRunKey WHERE IsShown = 1));
			
			CREATE UNIQUE CLUSTERED INDEX IX_DataSets ON ' + QUOTENAME(@DatabaseName) + '.[dbo].[DataSets] (DataSetGuid ASC);';

			IF @Cmd IS NOT NULL 
				BEGIN;
					IF @PrintSql = 1
						PRINT @Cmd;		

					IF @ExecuteSql = 1
						BEGIN; 
							EXEC @Result = sys.sp_executesql @statement = @Cmd;
						
							SET @CountRows = @@ROWCOUNT;
							SET @CountRecords = ISNULL(@CountRecords, 0) + @CountRows;
						END;
				END;
		END;

	--15) Export Members...
	IF @Result = 0
		BEGIN;
			IF OBJECT_ID(QUOTENAME(@DatabaseName) + '.[dbo].[Members]') IS NOT NULL
				BEGIN;
					SET @Cmd = 'DROP TABLE ' + QUOTENAME(@DatabaseName) + '.[dbo].[Members]';
					EXEC (@Cmd);
				END;

			SET @Cmd = 
			'SELECT DISTINCT
					t.CustomerMemberID,
					BDR.DataRunGuid,
					BDS.DataSetGuid,
					t.DOB,
					MG.Abbrev AS Gender,
					t.HicNumber,
					--t.IhdsMemberID,
					t.DisplayID AS IMIXref,
					t.NameFirst,
					t.NameLast,
					REPLACE(t.SsnDisplay, ''-'', '''') AS Ssn
			INTO	' + QUOTENAME(@DatabaseName) + '.[dbo].[Members]
			FROM	Result.DataSetMemberKey AS t
					INNER JOIN Member.Genders AS MG
							ON t.Gender = MG.Gender
					INNER JOIN Batch.DataRuns AS BDR
							ON t.DataRunID = BDR.DataRunID
					INNER JOIN Batch.DataSets AS BDS
							ON BDR.DataSetID = BDS.DataSetID
			WHERE	(t.DataRunID IN (SELECT DISTINCT DataRunID FROM Result.DataSetRunKey WHERE IsShown = 1));
			
			CREATE UNIQUE CLUSTERED INDEX IX_Members ON ' + QUOTENAME(@DatabaseName) + '.dbo.Members (CustomerMemberID ASC, DataRunGuid ASC);
			CREATE UNIQUE INDEX IX_Members_IMIXref ON ' + QUOTENAME(@DatabaseName) + '.dbo.Members (IMIXref ASC, DataRunGuid ASC);'

			IF @Cmd IS NOT NULL 
				BEGIN;
					IF @PrintSql = 1
						PRINT @Cmd;		

					IF @ExecuteSql = 1
						BEGIN; 
							EXEC @Result = sys.sp_executesql @statement = @Cmd;
						
							SET @CountRows = @@ROWCOUNT;
							SET @CountRecords = ISNULL(@CountRecords, 0) + @CountRows;
						END;
				END;
		END;

	--16) Export Providers...
	IF @Result = 0
		BEGIN;
			IF OBJECT_ID(QUOTENAME(@DatabaseName) + '.[dbo].[Providers]') IS NOT NULL
				BEGIN;
					SET @Cmd = 'DROP TABLE ' + QUOTENAME(@DatabaseName) + '.[dbo].[Providers]';
					EXEC (@Cmd);
				END;

			SET @Cmd = 
			'SELECT DISTINCT
					t.CustomerProviderID,
					BDR.DataRunGuid,
					BDS.DataSetGuid,
					--t.IhdsProviderID,
					t.DisplayID AS IMIXref,
					t.ProviderName
			INTO	' + QUOTENAME(@DatabaseName) + '.[dbo].[Providers]
			FROM	Result.DataSetProviderKey AS t
					INNER JOIN Batch.DataRuns AS BDR
							ON t.DataRunID = BDR.DataRunID
					INNER JOIN Batch.DataSets AS BDS
							ON BDR.DataSetID = BDS.DataSetID
			WHERE	(t.DataRunID IN (SELECT DISTINCT DataRunID FROM Result.DataSetRunKey WHERE IsShown = 1));
			
			CREATE UNIQUE CLUSTERED INDEX IX_Providers ON ' + QUOTENAME(@DatabaseName) + '.dbo.Providers (CustomerProviderID ASC, DataRunGuid ASC);
			CREATE UNIQUE INDEX IX_Providers_IMIXref ON ' + QUOTENAME(@DatabaseName) + '.dbo.Providers (IMIXref ASC, DataRunGuid ASC);';

			IF @Cmd IS NOT NULL 
				BEGIN;
					IF @PrintSql = 1
						PRINT @Cmd;		

					IF @ExecuteSql = 1
						BEGIN; 
							EXEC @Result = sys.sp_executesql @statement = @Cmd;
						
							SET @CountRows = @@ROWCOUNT;
							SET @CountRecords = ISNULL(@CountRecords, 0) + @CountRows;
						END;
				END;
		END;
		
	--17) Export Medical Groups...
	IF @Result = 0
		BEGIN;
			IF OBJECT_ID(QUOTENAME(@DatabaseName) + '.[dbo].[MedicalGroups]') IS NOT NULL
				BEGIN;
					SET @Cmd = 'DROP TABLE ' + QUOTENAME(@DatabaseName) + '.[dbo].[MedicalGroups]';
					EXEC (@Cmd);
				END;

			SET @Cmd = 
			'SELECT	DISTINCT
					t.CustomerMedicalGroupID,
					BDR.DataRunGuid,
					BDS.DataSetGuid,
					t.MedGrpName,
					t.RegionName AS OrgName,
					t.SubRegionName AS SubOrgName
			INTO	' + QUOTENAME(@DatabaseName) + '.[dbo].[MedicalGroups]
			FROM	Result.DataSetMedicalGroupKey AS t
					INNER JOIN Batch.DataRuns AS BDR
							ON t.DataRunID = BDR.DataRunID
					INNER JOIN Batch.DataSets AS BDS
							ON BDR.DataSetID = BDS.DataSetID
			WHERE	(t.DataRunID IN (SELECT DISTINCT DataRunID FROM Result.DataSetRunKey WHERE IsShown = 1));
			
			CREATE UNIQUE CLUSTERED INDEX IX_MedicalGroups ON ' + QUOTENAME(@DatabaseName) + '.dbo.MedicalGroups (CustomerMedicalGroupID ASC, DataRunGuid ASC);'

			IF @Cmd IS NOT NULL 
				BEGIN;
					IF @PrintSql = 1
						PRINT @Cmd;		

					IF @ExecuteSql = 1
						BEGIN; 
							EXEC @Result = sys.sp_executesql @statement = @Cmd;
						
							SET @CountRows = @@ROWCOUNT;
							SET @CountRecords = ISNULL(@CountRecords, 0) + @CountRows;
						END;
				END;
		END;

	IF @Result = 0
		PRINT 'Export successful.';
	ELSE
		RAISERROR('Export failed.', 16, 1);

	--Always returns zero now due to added indexes...
	--PRINT 'Total Record Count: ' + CONVERT(varchar(32), @CountRecords);
END

GO
GRANT VIEW DEFINITION ON  [Export].[CopyResultsToDB] TO [db_executer]
GO
GRANT EXECUTE ON  [Export].[CopyResultsToDB] TO [db_executer]
GO
GRANT EXECUTE ON  [Export].[CopyResultsToDB] TO [Processor]
GO
