SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 1/24/2012
-- Description: Identifies the systematic samples for the specified data run.
--				(Certification Guid: Now uses a special Guid on the set on the measure set record.)
-- =============================================
CREATE PROCEDURE [Measure].[IdentifySystematicSamples]
(
	@BitProductLines bigint = NULL,
	@DataRunID int,
	@ForceResample bit = 0,
	@IsSysSampleAscending bit = NULL,
	@MeasureID int = NULL,
	@PayerID smallint = NULL,
	@PopulationID int = NULL,
	@ProductClassID tinyint = NULL,
	@ShowSelectionCalculations bit = 0,
	@SysSampleID int = NULL,
	@SysSampleRand decimal(18, 6) = NULL,
	@SysSampleRate decimal(18, 6) = NULL,
	@SysSampleSize int = NULL
)
AS
BEGIN
	SET NOCOUNT ON;
		
	DECLARE @IgnoreExplicitPayersOnProductLineAssignment bit;
	SET @IgnoreExplicitPayersOnProductLineAssignment = 1;

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
		SET @LogObjectName = 'IdentifySystematicSamples'; 
		SET @LogObjectSchema = 'Measure'; 

		--Added to determine @LogEntryXrefGuid value---------------------------
		SELECT @LogEntryXrefGuid = [Log].GetEntryXrefGuid (@LogObjectSchema, @LogObjectName);
		-----------------------------------------------------------------------
	
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
		
		BEGIN TRY;
				
			DECLARE @CountRecords int;

			IF OBJECT_ID('tempdb..#SystematicSamples') IS NOT NULL
				DROP TABLE #SystematicSamples;

			--Pull the systematic sample instructions for the specified data run by SysSampleID.
			SELECT	BSS.BitProductLines,
					BSS.DataRunID,
					BSS.IsSysSampleAscending,
					BSS.MeasureID,
					BSS.PayerID,
					BSS.PopulationID,
					BSS.ProductClassID,
					ISNULL(@SysSampleRand, BSS.SysSampleRand) AS SysSampleRand,
					ISNULL(@SysSampleRate, BSS.SysSampleRate) AS SysSampleRate,
					ISNULL(@SysSampleSize, BSS.SysSampleSize) AS SysSampleSize,
					BSS.SysSampleID
			INTO	#SystematicSamples
			FROM	Batch.SystematicSamples AS BSS
					INNER JOIN Measure.Measures AS MM
							ON BSS.MeasureID = MM.MeasureID AND
								MM.MeasureSetID = @MeasureSetID
			WHERE	(BSS.DataRunID = @DataRunID) AND
					((@BitProductLines IS NULL) OR (BSS.BitProductLines & @BitProductLines > 0)) AND
					((@MeasureID IS NULL) OR (BSS.MeasureID = @MeasureID)) AND
					((@PopulationID IS NULL) OR (BSS.PopulationID = @PopulationID)) AND
					((@ProductClassID IS NULL) OR (BSS.ProductClassID = @ProductClassID)) AND
					((@SysSampleID IS NULL) OR (BSS.SysSampleID = @SysSampleID));

			--Verify whether or not the specified data run already has systematic samples chosen, if so, require the @ForceResample flag to continue.
			IF NOT EXISTS (
								SELECT TOP 1 1 
								FROM	Result.SystematicSamples 
								WHERE	(DataRunID = @DataRunID) AND 
										(SysSampleID IN (SELECT SysSampleID FROM #SystematicSamples))
							) OR @ForceResample = 1
				BEGIN
				
					IF OBJECT_ID('tempdb..#SampleSelectionBase') IS NOT NULL
						DROP TABLE #SampleSelectionBase;

					IF OBJECT_ID('tempdb..#SampleSelection') IS NOT NULL
						DROP TABLE #SampleSelection;

					--Identify the potential members for each SysSampleID.
					SELECT	MAX(RMD.BitProductLines & SS.BitProductLines) AS BitProductLines,
							MM.DOB,
							RMD.DSMemberID,
							SS.IsSysSampleAscending,
							DM.NameFirst AS FirstName,
							RMD.KeyDate,
							DM.NameLast AS LastName,
							MIN(RMD.ResultRowID) AS ResultRowID,
							SS.SysSampleID,
							SS.SysSampleRand,
							SS.SysSampleRate,
							SS.SysSampleSize,
							CEILING(SS.SysSampleSize * (SS.SysSampleRate + 1)) AS SysSampleTotSize
					INTO	#SampleSelectionBase
					FROM	Result.MeasureDetail AS RMD
							INNER JOIN Product.Payers AS PP
									ON RMD.PayerID = PP.PayerID
							INNER JOIN Product.ProductTypes AS PPT
									ON PP.ProductTypeID = PPT.ProductTypeID
							INNER JOIN #SystematicSamples AS SS
									ON RMD.BitProductLines & SS.BitProductLines > 0 AND
										RMD.DataRunID = SS.DataRunID AND
										RMD.MeasureID = SS.MeasureID AND
										(@PayerID IS NULL OR RMD.PayerID = @PayerID) AND
										(SS.PayerID IS NULL OR RMD.PayerID = SS.PayerID) AND
										RMD.PopulationID = SS.PopulationID AND
										PPT.ProductClassID = SS.ProductClassID
							INNER JOIN Member.Members AS MM
									ON RMD.DataSetID = MM.DataSetID AND
										RMD.DSMemberID = MM.DSMemberID
							INNER JOIN dbo.Member AS DM
									ON MM.MemberID = DM.MemberID AND
										MM.IhdsMemberID = DM.ihds_member_id
					WHERE	(RMD.IsDenominator = 1) AND
							(RMD.IsExclusion = 0) AND
							(RMD.ResultTypeID = 1) AND
							(
								--Added 12/8/2015 as part of certifying systematic sampling after the remove of gaps from HMO/POS-to-PPO/EPO gaps in enrollment...
								(@IgnoreExplicitPayersOnProductLineAssignment = 0) OR
								(SS.PayerID IS NOT NULL) OR
								(
									(SS.PayerID IS NULL) AND
									(RMD.PayerID NOT IN	(
															SELECT DISTINCT 
																	t.PayerID 
															FROM	#SystematicSamples AS t 
															WHERE	(t.PopulationID = RMD.PopulationID) AND 
																	(t.BitProductLines > 0) AND
																	(t.BitProductLines & SS.BitProductLines = t.BitProductLines) AND
																	(t.ProductClassID = PPT.ProductClassID) AND
																	(t.PayerID IS NOT NULL)
														))
								)
							)
					GROUP BY MM.DOB,
							RMD.DSMemberID,
							SS.IsSysSampleAscending,
							DM.NameFirst,
							DM.NameLast,
							RMD.KeyDate,
							SS.SysSampleID,
							SS.SysSampleRand,
							SS.SysSampleRate,
							SS.SysSampleSize;

					SELECT	SSB.DOB,
							SSB.DSMemberID,
							SSB.IsSysSampleAscending,
							SSB.KeyDate,
							SSB.ResultRowID,
							CONVERT(int, NULL) AS RowID,
							ROW_NUMBER() OVER (PARTITION BY SSB.SysSampleID ORDER BY SSB.LastName ASC, SSB.FirstName ASC, SSB.DOB ASC, SSB.KeyDate ASC) AS RowASC,
							ROW_NUMBER() OVER (PARTITION BY SSB.SysSampleID ORDER BY SSB.LastName DESC, SSB.FirstName DESC, SSB.DOB DESC, SSB.KeyDate DESC) AS RowDESC,
							SSB.SysSampleID,
							SSB.SysSampleRand,
							SSB.SysSampleRate,
							SSB.SysSampleSize,
							SSB.SysSampleTotSize
					INTO	#SampleSelection
					FROM	#SampleSelectionBase AS SSB;

					UPDATE #SampleSelection SET	RowID = CASE IsSysSampleAscending WHEN 0 THEN RowDESC ELSE RowASC END;

					CREATE UNIQUE CLUSTERED INDEX IX_#SampleSelection ON #SampleSelection (SysSampleID ASC, RowID ASC);

					IF OBJECT_ID('tempdb..#SampleSelectionKey') IS NOT NULL
						DROP TABLE #SampleSelectionKey;

					--Identify which rows of each SysSampleID are part of the systematic sample.
					WITH SampleVariablesBase AS
					(
						SELECT	CONVERT(decimal(18,10), COUNT(DISTINCT t.RowID)) AS CountRecords,
								t.SysSampleID,
								CONVERT(decimal(18,10), t.SysSampleRand) AS SysSampleRand,
								t.SysSampleSize,
								CONVERT(decimal(18,10), COUNT(DISTINCT t.RowID)) / CONVERT(decimal(18,10), t.SysSampleTotSize) AS SysSampleRatio, --(EM/FSS)
								t.SysSampleTotSize
						FROM	#SampleSelection AS t
						GROUP BY t.SysSampleID,
								t.SysSampleRand,
								t.SysSampleSize,
								t.SysSampleTotSize
					),
					SampleVariables AS
					(
						SELECT	t.CountRecords,
								t.SysSampleID,
								t.SysSampleRatio,
								t.SysSampleSize,
								ISNULL(NULLIF(ROUND(t.SysSampleRand * FLOOR(t.SysSampleRatio), 0), 0), 1) AS SysSampleStart, --Use "FLOOR" per Step 6 of Guidelines for Calculations and Sampling
								t.SysSampleTotSize
						FROM	SampleVariablesBase AS t
					)
					SELECT	CONVERT(bit, CASE WHEN T.N > SV.SysSampleSize THEN 1 ELSE 0 END) AS IsAuxiliary,
							CONVERT(int, SV.SysSampleStart + ROUND((T.N - 1) * SV.SysSampleRatio, 0)) AS RowID, 
							SV.SysSampleID,
							T.N AS SysSampleOrder,
							SV.SysSampleRatio,
							(T.N - 1) * SV.SysSampleRatio AS SysSampleRatioApplied,
							ROUND((T.N - 1) * SV.SysSampleRatio, 0) AS SysSampleRatioAppliedR,
							SV.SysSampleStart
					INTO	#SampleSelectionKey
					FROM	SampleVariables AS SV
							INNER JOIN dbo.Tally AS T
									ON T.N BETWEEN 1 AND SV.SysSampleTotSize
					WHERE	SV.CountRecords > SV.SysSampleTotSize
					UNION
					SELECT	CONVERT(bit, CASE WHEN T.N > SV.SysSampleSize THEN 1 ELSE 0 END) AS IsAuxiliary,
							T.N AS RowID,
							SV.SysSampleID,							
							T.N AS SysSampleOrder,
							SV.SysSampleRatio,
							NULL AS sysSampleRatioApplied,
							NULL AS SysSampleRatioAppliedR,
							SV.SysSampleStart
					FROM	SampleVariables AS SV
							INNER JOIN dbo.Tally AS T
									ON T.N BETWEEN 1 AND SV.SysSampleTotSize
					WHERE	SV.CountRecords <= SV.SysSampleTotSize

					CREATE UNIQUE CLUSTERED INDEX IX_#SampleSelectionKey ON #SampleSelectionKey (SysSampleID ASC, RowID ASC);

					--Purge existing sample records, if necessary.
					IF OBJECT_ID('tempdb..#DeletedSamples') IS NOT NULL
						DROP TABLE #DeletedSamples;

					CREATE TABLE #DeletedSamples (SysSampleRefID bigint NOT NULL);

					DELETE 
					FROM	Result.SystematicSamples 
					OUTPUT	DELETED.SysSampleRefID INTO #DeletedSamples 
					WHERE	(DataRunID = @DataRunID) AND 
							(SysSampleID IN (SELECT SysSampleID FROM #SystematicSamples));

					IF EXISTS(SELECT TOP 1 1 FROM #DeletedSamples)
						DELETE 
						FROM	Result.MeasureDetail 
						WHERE	(DataRunID = @DataRunID) AND 
								(ResultTypeID IN (SELECT ResultTypeID FROM Result.ResultTypes WHERE Abbrev IN ('H','M'))) AND
								(SysSampleRefID IN (SELECT SysSampleRefID FROM #DeletedSamples));

					--Record samples in final table.
					INSERT INTO Result.SystematicSamples
							(DataRunID,
							DataSetID,
							DSMemberID,
							IsAuxiliary,
							KeyDate,
							SysSampleOrder,
							SysSampleID)
					SELECT	@DataRunID AS DataRunID,
							@DataSetID AS DataSetID,
							SS.DSMemberID,
							SSK.IsAuxiliary,
							SS.KeyDate,
							SSK.SysSampleOrder,
							SS.SysSampleID
					FROM	#SampleSelectionKey SSK
							INNER JOIN #SampleSelection AS SS
									ON SSK.RowID = SS.RowID AND
										SSK.SysSampleID = SS.SysSampleID
					ORDER BY SS.SysSampleID, SSK.SysSampleOrder;

					SET @CountRecords = ISNULL(@CountRecords, 0) + @@ROWCOUNT;

					IF @ShowSelectionCalculations = 1
					SELECT	BSS.SysSampleID AS [Selection ID],
							Product.ConvertBitProductLinesToAbbrevs(BSS.BitProductLines) AS [Product Lines],
							PPC.Descr AS [Product Class],
							ISNULL(CONVERT(varchar(64), PP.Abbrev), '(All for Line/Class)') AS Payer,
							RPP.Abbrev AS [Real Payer],
							M.CustomerMemberID AS [Customer Member ID], 
							RMD.DSMemberID AS [IMI Member Ref ID], 
							M.NameLast AS [Last Name], 
							M.NameFirst AS [First Name], 
							CONVERT(varchar(16), M.DateOfBirth, 101) AS DOB, 
							CONVERT(varchar(16), SS.KeyDate, 101) AS [Event Date],
							SS.RowID AS [Sort Order],
							SSK.SysSampleOrder AS [Sample Selection],
							dbo.ConvertBitToYN(SSK.IsAuxiliary) AS [Oversample],
							SSK.SysSampleStart AS [START],
							SSK.SysSampleRatio AS [EM/FSS],
							SSK.SysSampleRatioApplied AS [(i - 1) * (EM/FSS)],
							SSK.SysSampleRatioAppliedR AS [Round .5, (i - 1) * (EM/FSS)],
							SSK.SysSampleStart + SSK.SysSampleRatioAppliedR AS [START + (i - 1) * (EM/FSS)],
							SS.SysSampleRand AS [RAND],
							SS.SysSampleSize AS [Sample Size],
							SS.SysSampleRate AS [Oversample Rate],
							SS.SysSampleTotSize AS [FSS]
					FROM	#SampleSelection AS SS	
							INNER JOIN Batch.SystematicSamples AS BSS
									ON BSS.SysSampleID = SS.SysSampleID
							LEFT OUTER JOIN Product.ProductClasses  AS PPC
									ON BSS.ProductClassID = PPC.ProductClassID
							LEFT OUTER JOIN Product.Payers AS PP
									ON BSS.PayerID = PP.PayerID
							INNER JOIN Result.MeasureDetail AS RMD WITH(NOLOCK)
									ON RMD.ResultRowID = SS.ResultRowID
							LEFT OUTER JOIN Product.Payers AS RPP
									ON RMD.PayerID = RPP.PayerID
							INNER JOIN Member.Members AS MM WITH(NOLOCK)
									ON RMD.DSMemberID = MM.DSMemberID
							INNER JOIN dbo.Member AS M WITH(NOLOCK)
									ON MM.MemberID = M.MemberID AND
										MM.IhdsMemberID = M.ihds_member_id                                  
							LEFT OUTER JOIN #SampleSelectionKey AS SSK
									ON SS.RowID = SSK.RowID AND
										SS.SysSampleID = SSK.SysSampleID
					ORDER BY BSS.SysSampleID, 
							SS.RowID;
								
					--Create Medical Record and Hybrid records in measure results table.		
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
							Gender,
							IsDenominator,
							IsExclusion,
							IsIndicator,
							IsNumerator,
							IsNumeratorAdmin,
							IsNumeratorMedRcd,
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
					SELECT	RMD.Age,
							RMD.AgeMonths,
							RMD.AgeBandID,
							RMD.AgeBandSegID,
							-1 AS BatchID,
							RMD.BeginDate,
							RMD.BitProductLines & SS.BitProductLines AS BitProductLines,
							RMD.ClinCondID,
							RSS.DataRunID,
							RSS.DataSetID,
							RMD.DataSourceID,
							[Days],
							RMD.DSEntityID AS DSEntityID,
							RSS.DSMemberID,
							RMD.DSProviderID,
							RMD.EndDate,
							RMD.EnrollGroupID,
							RMD.EntityID,
							RMD.Gender,
							CASE WHEN RSS.IsAuxiliary = 1 THEN 0 ELSE RMD.IsDenominator END AS IsDenominator,
							RMD.IsExclusion,
							RMD.IsIndicator,
							RMD.IsNumerator,
							RMD.IsNumeratorAdmin,
							RMD.IsNumeratorMedRcd,
							RSS.KeyDate,
							RMD.MeasureID,
							RMD.MeasureXrefID,
							RMD.MetricID,
							RMD.MetricXrefID,
							RMD.PayerID,
							RMD.PopulationID,
							RMD.ProductLineID,
							RMD.Qty,
							RRT.ResultTypeID,
							RMD.SourceDenominator AS SourceDenominator,
							RMD.SourceDenominatorSrc,
							RMD.SourceExclusion AS SourceExclusion,
							RMD.SourceExclusionSrc,
							RMD.SourceIndicator AS SourceIndicator,
							RMD.SourceIndicatorSrc,
							RMD.SourceNumerator AS SourceNumerator,
							RMD.SourceNumeratorSrc,
							RSS.SysSampleRefID,
							RMD.[Weight]
					FROM	Result.MeasureDetail AS RMD
							INNER JOIN Product.Payers AS PP
									ON RMD.PayerID = PP.PayerID
							INNER JOIN Product.ProductTypes AS PPT
									ON PP.ProductTypeID = PPT.ProductTypeID
							INNER JOIN #SystematicSamples AS SS
									ON RMD.DataRunID = SS.DataRunID AND
										RMD.MeasureID = SS.MeasureID AND
										(@PayerID IS NULL OR RMD.PayerID = @PayerID) AND
										(SS.PayerID IS NULL OR RMD.PayerID = SS.PayerID) AND
										RMD.PopulationID = SS.PopulationID AND
										PPT.ProductClassID = SS.ProductClassID AND
										RMD.BitProductLines & SS.BitProductLines > 0
							INNER JOIN Result.SystematicSamples AS RSS
									ON SS.SysSampleID = RSS.SysSampleID AND
										RMD.DataRunID = RSS.DataRunID AND
										RMD.DataSetID = RSS.DataSetID AND
										RMD.DSMemberID = RSS.DSMemberID AND
										RMD.KeyDate = RSS.KeyDate
							INNER JOIN Result.ResultTypes AS RRT
									ON RRT.Abbrev IN ('M','H') 
					WHERE	(RMD.DataRunID = @DataRunID) AND	
							(RMD.DataSetID = @DataSetID) AND
							(RMD.ResultTypeID = 1) AND
							(RMD.IsDenominator = 1) AND
							(RMD.IsExclusion = 0)                          
					ORDER BY RSS.SysSampleRefID, RRT.ResultTypeID		
							
										
										
				END;

			SET @LogDescr = 'Identifying systematic samples completed succcessfully.'; 
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
			SET @LogDescr = 'Identifying systematic samples failed!'; 
			
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
GRANT EXECUTE ON  [Measure].[IdentifySystematicSamples] TO [Processor]
GO
