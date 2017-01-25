SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 3/4/2014
-- Description: Copies the systematic samples for the specified data run.
-- =============================================
CREATE PROCEDURE [Measure].[CopySystematicSamples]
(
	@FromDataRunID int,
	@ToDataRunID int
 )  
AS
BEGIN
	SET NOCOUNT ON;
		
	DECLARE @LogBeginTime datetime;
	DECLARE @LogDescr varchar(256);
	DECLARE @LogEndTime datetime;
	DECLARE @LogEntryXrefGuid uniqueidentifier;
	DECLARE @LogObjectName nvarchar(128);
	DECLARE @LogObjectSchema nvarchar(128);
	
	DECLARE @BeginInitSeedDate datetime;
	DECLARE @DataSetID int;
	DECLARE @EndInitSeedDate datetime;
	DECLARE @IsLogged bit;
	DECLARE @MeasureSetID int;
	DECLARE @OwnerID int;
	DECLARE @SeedDate datetime;
	
	DECLARE @Result int;
	
	BEGIN TRY;
		SET @LogBeginTime = GETDATE();
		SET @LogObjectName = 'CopySystematicSamples'; 
		SET @LogObjectSchema = 'Measure'; 

		--Added to determine @LogEntryXrefGuid value---------------------------
		SELECT @LogEntryXrefGuid = [Log].GetEntryXrefGuid (@LogObjectSchema, @LogObjectName);
		-----------------------------------------------------------------------
	
		DECLARE @DataRunID int;
		SET @DataRunID = @ToDataRunID;

		SELECT	@BeginInitSeedDate = DR.BeginInitSeedDate,
				@DataSetID = DS.DataSetID,
				@EndInitSeedDate = DR.EndInitSeedDate,
				@IsLogged = DR.IsLogged,
				@MeasureSetID = DR.MeasureSetID,
				@OwnerID = DS.OwnerID,
				@SeedDate = DR.SeedDate
		FROM	Batch.DataRuns AS DR
				INNER JOIN Batch.DataSets AS DS 
						ON DR.DataSetID = DS.DataSetID 
		WHERE	(DR.DataRunID = @DataRunID);
		
		DECLARE @CountRecords bigint;

		BEGIN TRY;
			DECLARE @AllowDeleteExistingToSamples bit = 1;

			IF EXISTS	(
							SELECT TOP 1 1 
							FROM	Batch.DataRuns AS BDR1 
									INNER JOIN Batch.DataRuns AS BDR2 
											ON BDR1.BeginInitSeedDate = BDR2.BeginInitSeedDate AND
												BDR1.EndInitSeedDate = BDR2.EndInitSeedDate AND
												BDR1.MeasureSetID = BDR2.MeasureSetID AND  									                                  
												BDR1.SeedDate = BDR2.SeedDate                                  
							WHERE	BDR1.DataRunID = @FromDataRunID AND
									BDR2.DataRunID = @ToDataRunID              
						)
				BEGIN;

					BEGIN TRAN TCopySystematicSamples;

					IF EXISTS(SELECT TOP 1 1 FROM Batch.SystematicSamples WHERE DataRunID = @ToDataRunID) AND
						NOT EXISTS (SELECT TOP 1 1 FROM Result.MeasureDetail WHERE ResultTypeID IN (2, 3) AND DataRunID = @ToDataRunID) AND
						NOT EXISTS (SELECT TOP 1 1 FROM Result.SystematicSamples WHERE DataRunID = @ToDataRunID)
						BEGIN;
							DELETE FROM Batch.SystematicSamples WHERE DataRunID = @ToDataRunID;
						END;
	
					IF NOT EXISTS(SELECT TOP 1 1 FROM Batch.SystematicSamples WHERE DataRunID = @ToDataRunID)  
						BEGIN;

							CREATE TABLE #ReferenceKey
							(
								FromGuid uniqueidentifier NOT NULL,
								FromID int NOT NULL,
								KeyName nvarchar(256) NOT NULL,
								ToGuid uniqueidentifier NOT NULL DEFAULT (NEWID()),
								ToID int NULL
							);

							CREATE UNIQUE CLUSTERED INDEX IX_#ReferenceKey ON #ReferenceKey (KeyName, FromID);
							CREATE UNIQUE NONCLUSTERED INDEX IX_#ReferenceKey2 ON #ReferenceKey (KeyName, FromGuid);

							INSERT INTO #ReferenceKey
									(FromGuid,
									FromID,
									KeyName)
							SELECT	SysSampleGuid AS FromGuid,
									SysSampleID AS FromID,
									'Batch.SystematicSamples' AS KeyName
							FROM	Batch.SystematicSamples
							WHERE	(DataRunID = @FromDataRunID);

							INSERT INTO Batch.SystematicSamples
									(BitProductLines,
									DataRunID,
									IsSysSampleAscending,
									MeasureID,
									PayerID,
									PopulationID,
									ProductClassID,
									ProductLineID,
									SysSampleGuid,
									SysSampleRand,
									SysSampleRate,
									SysSampleSize)
							SELECT	BSS.BitProductLines,
									@ToDataRunID AS DataRunID,
									BSS.IsSysSampleAscending,
									BSS.MeasureID,
									BSS.PayerID,
									BSS.PopulationID,
									BSS.ProductClassID,
									BSS.ProductLineID,
									RK.ToGuid AS SysSampleGuid,
									BSS.SysSampleRand,
									BSS.SysSampleRate,
									BSS.SysSampleSize
							FROM	Batch.SystematicSamples AS BSS
									INNER JOIN #ReferenceKey AS RK
											ON BSS.SysSampleID = RK.FromID AND
												RK.KeyName = 'Batch.SystematicSamples'     
							WHERE	DataRunID = @FromDataRunID
							ORDER BY BSS.SysSampleID;

							UPDATE	RK
							SET		ToID = BSS.SysSampleID
							FROM    #ReferenceKey AS RK
									INNER JOIN Batch.SystematicSamples AS BSS
											ON RK.ToGuid = BSS.SysSampleGuid AND
												RK.KeyName = 'Batch.SystematicSamples';                              						

							INSERT INTO #ReferenceKey
									(FromGuid,
									FromID,
									KeyName)
							SELECT	RSS.SysSampleRefGuid AS FromGuid,
									RSS.SysSampleRefID AS FromID,
									'Result.SystematicSamples' AS KeyName
							FROM	Result.SystematicSamples AS RSS
							WHERE	(RSS.DataRunID = @FromDataRunID);    
				
							WITH SystematicSampleMembers AS
							(
								SELECT DISTINCT
										DSMemberID
								FROM	Result.SystematicSamples
								WHERE	DataRunID = @FromDataRunID
							)              
							INSERT INTO #ReferenceKey
									(FromGuid,
									FromID,
									KeyName,
									ToGuid,
									ToID)
							SELECT	NEWID() AS FromGuid,
									FRDSMK.DSMemberID AS FromID,
									'Result.DataSetMemberKey' AS KeyName,
									NEWID() AS ToGuid,
									TRDSMK.DSMemberID AS ToID
							FROM	Result.DataSetMemberKey AS FRDSMK
									INNER JOIN SystematicSampleMembers AS SSM
											ON FRDSMK.DSMemberID = SSM.DSMemberID                              
									LEFT OUTER JOIN Result.DataSetMemberKey AS TRDSMK
											ON FRDSMK.CustomerMemberID = TRDSMK.CustomerMemberID AND                              
												TRDSMK.DataRunID = @ToDataRunID --AND
												--FRDSMK.IhdsMemberID = TRDSMK.IhdsMemberID     
							WHERE	FRDSMK.DataRunID = @FromDataRunID;
						
							ALTER INDEX ALL ON #ReferenceKey REBUILD;            

							IF EXISTS (SELECT TOP 1 1 FROM #ReferenceKey WHERE ToID IS NULL AND KeyName = 'Result.DataSetMemberKey')
								BEGIN;
									SELECT * FROM #ReferenceKey WHERE ToID IS NULL AND KeyName = 'Result.DataSetMemberKey'
									RAISERROR ('Unable to copy systematic samples.  Not all members can be transferred.', 16, 1);
								END;

							INSERT INTO Result.SystematicSamples
									(DataRunID,
									DataSetID,
									DSMemberID,
									IsAuxiliary,
									KeyDate,
									ResultRowGuid,
									SysSampleID,
									SysSampleOrder)
							SELECT	BDR.DataRunID,
									BDR.DataSetID,
									MRK.ToID AS DSMemberID,
									RSS.IsAuxiliary,
									RSS.KeyDate,
									RSSRK.ToGuid AS ResultRowGuid,
									BSSRK.ToID AS SysSampleID,
									RSS.SysSampleOrder
							FROM    Result.SystematicSamples AS RSS
									INNER JOIN #ReferenceKey AS BSSRK
											ON RSS.SysSampleID = BSSRK.FromID AND
												BSSRK.KeyName = 'Batch.SystematicSamples'                              
									INNER JOIN #ReferenceKey AS	MRK
											ON RSS.DSMemberID = MRK.FromID AND
												MRK.KeyName = 'Result.DataSetMemberKey'                              
									INNER JOIN #ReferenceKey AS RSSRK
											ON RSS.SysSampleRefID = RSSRK.FromID AND
												RSSRK.KeyName = 'Result.SystematicSamples'
									INNER JOIN Batch.DataRuns AS BDR
											ON BDR.DataRunID = @ToDataRunID                       
							WHERE	(RSS.DataRunID = @FromDataRunID)
							ORDER BY RSS.ResultRowID;

							UPDATE	RK
							SET		ToID = RSS.SysSampleRefID
							FROM    #ReferenceKey AS RK
									INNER JOIN Result.SystematicSamples AS RSS
											ON RK.ToGuid = RSS.SysSampleRefGuid AND
												RK.KeyName = 'Result.SystematicSamples'; 

							IF EXISTS (SELECT TOP 1 1 FROM #ReferenceKey WHERE ToID IS NULL AND KeyName = 'Result.SystematicSamples')
								BEGIN;
									SELECT * FROM #ReferenceKey WHERE ToID IS NULL AND KeyName = 'Result.SystematicSamples'
									RAISERROR ('Unable to copy systematic samples.  Not all systematic samples can be transferred.', 16, 1);
								END;
				
							INSERT INTO Result.MeasureDetail
									(Age,
									AgeMonths,
									AgeBandID,
									AgeBandSegID,
									BatchID,
									BeginDate,
									BitProductLines,
									ClinCondID,
									DataRunID,
									DataSetID,
									DataSourceID,
									[Days],
									DSEntityID,
									DSMemberID,
									DSProviderID,
									EndDate,
									EnrollGroupID,
									EntityID,
									ExclusionTypeID,
									Gender,
									IsDenominator,
									IsExclusion,
									IsIndicator,
									IsNumerator,
									IsNumeratorAdmin,
									IsNumeratorMedRcd,
									IsSupplementalDenominator,
									IsSupplementalExclusion,
									IsSupplementalIndicator,
									IsSupplementalNumerator,
									KeyDate,
									MeasureID,
									MeasureXrefID,
									MetricID,
									MetricXrefID,
									PayerID,
									PopulationID,
									ProductLineID,
									Qty,
									ResultTypeID,
									SourceDenominator,
									SourceDenominatorSrc,
									SourceExclusion,
									SourceExclusionSrc,
									SourceIndicator,
									SourceIndicatorSrc,
									SourceNumerator,
									SourceNumeratorSrc,
									SysSampleRefID,
									[Weight])
							SELECT	COALESCE(t1.Age, t2.Age, RMD.Age) AS Age,
									COALESCE(t1.AgeMonths, t2.AgeMonths, RMD.AgeMonths) AS AgeMonths,
									COALESCE(t1.AgeBandID, t2.AgeBandID, RMD.AgeBandID) AS AgeBandID,
									COALESCE(t1.AgeBandSegID, t2.AgeBandSegID, RMD.AgeBandSegID) AS AgeBandSegID,
									-1 AS BatchID,
									COALESCE(t1.BeginDate, t2.BeginDate, RMD.BeginDate) AS BeginDate,
									RMD.BitProductLines AS BitProductLines,
									COALESCE(t1.ClinCondID, t2.ClinCondID, RMD.ClinCondID) AS ClinCondID,
									BDR.DataRunID,
									BDR.DataSetID,
									COALESCE(t1.DataSourceID, t2.DataSourceID, RMD.DataSourceID) AS DataSourceID,
									COALESCE(t1.[Days], t2.[Days], RMD.[Days]) AS [Days],
									COALESCE(t1.DSEntityID, t2.DSEntityID, RMD.DSEntityID) AS DSEntityID,
									MRK.ToID AS DSMemberID,
									COALESCE(t1.DSProviderID, t2.DSProviderID) AS DSProviderID,
									COALESCE(t1.EndDate, t2.EndDate, RMD.EndDate) AS EndDate,
									RMD.EnrollGroupID,
									COALESCE(t1.EntityID, t2.EntityID, RMD.EntityID) AS EntityID,
									CASE WHEN COALESCE(t1.ExclusionTypeID, t2.ExclusionTypeID, RMD.ExclusionTypeID) IS NOT NULL THEN 5 END AS ExclusionTypeID,
									RMD.Gender,
									CASE WHEN COALESCE(t1.IsExclusion, t2.IsExclusion, RMD.IsExclusion) = 0 THEN RMD.IsDenominator ELSE 0 END AS IsDenominator,
									COALESCE(t1.IsExclusion, t2.IsExclusion, RMD.IsExclusion) AS IsExclusion,
									COALESCE(t1.IsIndicator, t2.IsIndicator, RMD.IsIndicator) AS IsIndicator,
									COALESCE(t1.IsNumerator, t2.IsNumerator, RMD.IsNumerator) AS IsNumerator,
									COALESCE(t1.IsNumeratorAdmin, t2.IsNumeratorAdmin, RMD.IsNumeratorAdmin) AS IsNumeratorAdmin,
									COALESCE(t1.IsNumeratorMedRcd, t2.IsNumeratorMedRcd, RMD.IsNumeratorMedRcd) AS IsNumeratorMedRcd,
									COALESCE(t1.IsSupplementalDenominator, t2.IsSupplementalDenominator, RMD.IsSupplementalDenominator) AS IsSupplementalDenominator,
									COALESCE(t1.IsSupplementalExclusion, t2.IsSupplementalExclusion, RMD.IsSupplementalExclusion) AS IsSupplementalExclusion,
									COALESCE(t1.IsSupplementalIndicator, t2.IsSupplementalIndicator, RMD.IsSupplementalIndicator) AS IsSupplementalIndicator,
									COALESCE(t1.IsSupplementalNumerator, t2.IsSupplementalNumerator, RMD.IsSupplementalNumerator) AS IsSupplementalNumerator,
									COALESCE(t1.KeyDate, t2.KeyDate, RMD.KeyDate) AS KeyDate,
									RMD.MeasureID,
									RMD.MeasureXrefID,
									RMD.MetricID,
									RMD.MetricXrefID,
									RMD.PayerID AS PayerID,
									RMD.PopulationID AS PopulationID,
									RMD.ProductLineID AS ProductLineID,
									COALESCE(t1.Qty, t2.Qty, RMD.Qty) AS Qty,
									RMD.ResultTypeID,
									COALESCE(t1.SourceDenominator, t2.SourceDenominator, RMD.SourceDenominator) AS SourceDenominator,
									COALESCE(t1.SourceDenominatorSrc, t2.SourceDenominatorSrc, RMD.SourceDenominatorSrc) AS SourceDenominatorSrc,
									COALESCE(t1.SourceExclusion, t2.SourceExclusion, RMD.SourceExclusion) AS SourceExclusion,
									COALESCE(t1.SourceExclusionSrc, t2.SourceExclusionSrc, RMD.SourceExclusionSrc) AS SourceExclusionSrc,
									COALESCE(t1.SourceIndicator, t2.SourceIndicator, RMD.SourceIndicator) AS SourceIndicator,
									COALESCE(t1.SourceIndicatorSrc, t2.SourceIndicatorSrc, RMD.SourceIndicatorSrc) AS SourceIndicatorSrc,
									COALESCE(t1.SourceNumerator, t2.SourceNumerator, RMD.SourceNumerator) AS SourceNumerator,
									COALESCE(t1.SourceNumeratorSrc, t2.SourceNumeratorSrc, RMD.SourceNumeratorSrc) AS SourceNumeratorSrc,
									RSSRK.ToID AS SysSampleRefID,
									COALESCE(t1.[Weight], t2.[Weight], RMD.[Weight]) AS [Weight]
							FROM	Result.MeasureDetail AS RMD
									INNER JOIN Measure.Measures AS MM
											ON MM.MeasureID = RMD.MeasureID
									INNER JOIN Result.SystematicSamples AS RSS
											ON RMD.DataRunID = RSS.DataRunID AND
												RMD.SysSampleRefID = RSS.SysSampleRefID
									INNER JOIN #ReferenceKey AS RSSRK
											ON RSS.SysSampleRefID = RSSRK.FromID AND
												RSSRK.KeyName = 'Result.SystematicSamples'                              
									INNER JOIN #ReferenceKey AS MRK
											ON RMD.DSMemberID = MRK.FromID AND
												MRK.KeyName = 'Result.DataSetMemberKey'                              
									OUTER APPLY	(	--Primary: Exact KeyDate Match
													SELECT TOP 1 
															RMD2.* 
													FROM	Result.MeasureDetail AS RMD2 
													WHERE	(RMD2.DSMemberID = MRK.ToID) AND
															(RMD2.KeyDate = RMD.KeyDate) AND
															(RMD2.DataRunID = @ToDataRunID) AND 
															(RMD2.MetricID = RMD.MetricID) AND
															(RMD2.ResultTypeID IN (1))   
													ORDER BY KeyDate, ResultRowID                                           
												) AS t1
									OUTER APPLY	(	--Secondary: KeyDate Match + or - 10 Days
													SELECT TOP 1 
															RMD2.* 
													FROM	Result.MeasureDetail AS RMD2 
													WHERE	(RMD2.DSMemberID = MRK.ToID) AND
															(
																(MM.Abbrev NOT IN ('FPC','MRP','PPC')) OR
																(MM.Abbrev IN ('FPC','PPC') AND RMD2.KeyDate BETWEEN DATEADD(dd, -30, RMD.KeyDate) AND DATEADD(dd, 30, RMD.KeyDate)) OR
																(MM.Abbrev IN ('MRP') AND RMD2.KeyDate BETWEEN DATEADD(dd, -14, RMD.KeyDate) AND DATEADD(dd, 14, RMD.KeyDate)) 
															) AND
															(RMD2.DataRunID = @ToDataRunID) AND 
															(RMD2.MetricID = RMD.MetricID) AND
															(RMD2.ResultTypeID IN (1))   
													ORDER BY KeyDate, ResultRowID                                           
												) AS t2
									INNER JOIN Batch.DataRuns AS BDR
											ON BDR.DataRunID = @ToDataRunID
							WHERE	(RMD.DataRunID = @FromDataRunID) AND
									(RMD.ResultTypeID IN (2, 3));            

							SET @CountRecords = ISNULL(@CountRecords, 0) + @@ROWCOUNT;
						END;
					ELSE
						RAISERROR('Unable to copy systematic samples.  The destination data run has existing samples.', 16, 1);

					COMMIT TRAN TCopySystematicSamples;
				END;
			ELSE
				RAISERROR('Unable to copy systematic samples.  One of the two specified data runs is invalid.', 16, 1);



			SET @LogDescr = 'Copying systematic samples completed succcessfully.'; 
			SET @LogEndTime = GETDATE();
			
			EXEC @Result = Log.RecordEntry	@BeginTime = @LogBeginTime,
												@CountRecords = @CountRecords,
												@DataRunID = @DataRunID,
												@DataSetID = @DataSetID,
												@Descr = @LogDescr,
												@EndTime = @LogEndTime, 
												@EntryXrefGuid = @LogEntryXrefGuid, 
												@IsSuccess = 1,
												@SrcObjectName = @LogObjectName,
												@SrcObjectSchema = @LogObjectSchema;

			RETURN 0;
		END TRY
		BEGIN CATCH;
			IF @@TRANCOUNT > 0
				ROLLBACK;
				
			DECLARE @ErrorLine int;
			DECLARE @ErrorLogID int;
			DECLARE @ErrorMessage nvarchar(max);
			DECLARE @ErrorNumber int;
			DECLARE @ErrorSeverity int;
			DECLARE @ErrorSource nvarchar(512);
			DECLARE @ErrorState int;
			
			DECLARE @ErrorResult int;
			
			SELECT	@ErrorLine = ERROR_LINE(),
					@ErrorMessage = ERROR_MESSAGE(),
					@ErrorNumber = ERROR_NUMBER(),
					@ErrorSeverity = ERROR_SEVERITY(),
					@ErrorSource = ERROR_PROCEDURE(),
					@ErrorState = ERROR_STATE();
					
			EXEC @ErrorResult = [Log].RecordError	@LineNumber = @ErrorLine,
													@Message = @ErrorMessage,
													@ErrorNumber = @ErrorNumber,
													@ErrorType = 'Q',
													@ErrLogID = @ErrorLogID OUTPUT,
													@Severity = @ErrorSeverity,
													@Source = @ErrorSource,
													@State = @ErrorState,
													@PerformRollback = 0;
			
			
			SET @LogEndTime = GETDATE();
			SET @LogDescr = 'Copying systematic samples failed!'; 
			
			EXEC @Result = Log.RecordEntry	@BeginTime = @LogBeginTime,
												@CountRecords = -1, 
												@DataRunID = @DataRunID,
												@DataSetID = @DataSetID,
												@Descr = @LogDescr,
												@EndTime = @LogBeginTime,
												@EntryXrefGuid = @LogEntryXrefGuid, 
												@ErrLogID = @ErrorLogID,
												@IsSuccess = 0,
												@SrcObjectName = @LogObjectName,
												@SrcObjectSchema = @LogObjectSchema;
														
			SET @ErrorMessage = REPLACE(@LogDescr, '!', ': ') + @ErrorMessage + ' (Error: ' + CAST(@ErrorNumber AS nvarchar) + ')';
			RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
		END CATCH;
	END TRY
	BEGIN CATCH;
		DECLARE @ErrApp nvarchar(128);
		DECLARE @ErrLine int;
		DECLARE @ErrLogID int;
		DECLARE @ErrMessage nvarchar(max);
		DECLARE @ErrNumber int;
		DECLARE @ErrSeverity int;
		DECLARE @ErrSource nvarchar(512);
		DECLARE @ErrState int;
		
		DECLARE @ErrResult int;
		
		SELECT	@ErrApp = DB_NAME(),
				@ErrLine = ERROR_LINE(),
				@ErrMessage = ERROR_MESSAGE(),
				@ErrNumber = ERROR_NUMBER(),
				@ErrSeverity = ERROR_SEVERITY(),
				@ErrSource = ERROR_PROCEDURE(),
				@ErrState = ERROR_STATE();
				
		EXEC @ErrResult = [Log].RecordError	@Application = @ErrApp,
											@LineNumber = @ErrLine,
											@Message = @ErrMessage,
											@ErrorNumber = @ErrNumber,
											@ErrorType = 'Q',
											@ErrLogID = @ErrLogID OUTPUT,
											@Severity = @ErrSeverity,
											@Source = @ErrSource,
											@State = @ErrState;
		
		IF @ErrResult <> 0
			BEGIN
				PRINT '*** Error Log Failure:  Unable to record the specified entry. ***'
				SET @ErrNumber = @ErrLine * -1;
			END
			
		RETURN @ErrNumber;
	END CATCH;
END



GO
GRANT EXECUTE ON  [Measure].[CopySystematicSamples] TO [Processor]
GO
