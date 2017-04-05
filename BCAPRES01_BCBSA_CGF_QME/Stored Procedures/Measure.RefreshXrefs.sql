SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 8/17/2012
-- Description:	Refreshes the measure-set-agnostic measure and metric cross-reference tables.
-- =============================================
CREATE PROCEDURE [Measure].[RefreshXrefs]
(
	@DataRunID int
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
	
	DECLARE @BatchID int;
	DECLARE @DataSetID int;
	DECLARE @MeasureSetID int;
	
	DECLARE @Result int;
	
		BEGIN TRY;
		
		SET @LogBeginTime = GETDATE();
		SET @LogObjectName = 'RefreshXrefs'; 
		SET @LogObjectSchema = 'Measure'; 
		
		--Added to determine @LogEntryXrefGuid value---------------------------
		SELECT @LogEntryXrefGuid = [Log].GetEntryXrefGuid (@LogObjectSchema, @LogObjectName);
		-----------------------------------------------------------------------
		
		BEGIN TRY;				
			DECLARE @CountRecords int;
			
			SELECT	@DataSetID = DR.DataSetID,
					@MeasureSetID = DR.MeasureSetID 
			FROM	Batch.DataRuns AS DR
			WHERE	(DR.DataRunID = @DataRunID);
			
			-------------------------------------------------------------
			
			BEGIN TRANSACTION TXref;

			--1a) Populate MeasureXrefs...
			WITH MeasureAbbrevBase AS
			(
				SELECT	MM.Abbrev,
						MAX(MM.MeasureSetID) AS MeasureSetID,
						MMST.MeasureSetTypeID
				FROM	Measure.Measures AS MM
						INNER JOIN Measure.MeasureSets AS MMS
								ON MM.MeasureSetID = MMS.MeasureSetID
						INNER JOIN Measure.MeasureSetTypes AS MMST
								ON MMS.MeasureSetTypeID = MMST.MeasureSetTypeID
				GROUP BY MM.Abbrev,
						MMST.MeasureSetTypeID
			),
			MeasureAbbrevs AS
			(
				SELECT	MAB.Abbrev,
						MM.Descr,
						MM.MeasureID,
						MM.MeasClassID,
						MAB.MeasureSetID,
						MAB.MeasureSetTypeID
				FROM	MeasureAbbrevBase AS MAB
						INNER JOIN Measure.Measures AS MM
								ON MAB.Abbrev = MM.Abbrev AND
									MAB.MeasureSetID = MM.MeasureSetID
			),
			MeasureXrefBase AS
			(
				SELECT	Abbrev,
						Descr,
						MeasClassID,
						MeasureSetTypeID
				FROM	MeasureAbbrevs
			)
			MERGE	Measure.MeasureXrefs AS t
			USING	MeasureXrefBase AS s 
			ON		t.Abbrev = s.Abbrev AND
					t.MeasureSetTypeID = s.MeasureSetTypeID
			WHEN MATCHED AND (t.Descr <> s.Descr OR t.MeasClassID <> s.MeasClassID) 
			THEN 
					UPDATE SET Descr = s.Descr, MeasClassID = s.MeasClassID
			WHEN NOT MATCHED 
			THEN
					INSERT	(Abbrev, Descr, MeasClassID, MeasureSetTypeID)
					VALUES	(s.Abbrev, s.Descr, s.MeasClassID, s.MeasureSetTypeID);

			SET @CountRecords = ISNULL(@CountRecords, 0) + @@ROWCOUNT;

			--1b) Populate Measures with XrefID...
			UPDATE	MM
			SET		MeasureXrefID = MMXR.MeasureXrefID
			FROM	Measure.Measures AS MM
					INNER JOIN Measure.MeasureSets AS MMS
							ON MM.MeasureSetID = MMS.MeasureSetID
					INNER JOIN Measure.MeasureXrefs AS MMXR
							ON MM.Abbrev = MMXR.Abbrev AND
								MMS.MeasureSetTypeID = MMXR.MeasureSetTypeID
			WHERE	(MM.MeasureXrefID IS NULL) OR 
					(MM.MeasureXrefID <> MMXR.MeasureXrefID);

			SET @CountRecords = ISNULL(@CountRecords, 0) + @@ROWCOUNT;


			--2a) Populate MetricXrefs...
			WITH MetricAbbrevBase AS
			(
				SELECT	MX.Abbrev,
						MAX(MM.MeasureSetID) AS MeasureSetID,
						MMS.MeasureSetTypeID,
						MM.MeasureXrefID
				FROM	Measure.Metrics AS MX
						INNER JOIN Measure.Measures AS MM
								ON MX.MeasureID = MM.MeasureID
						INNER JOIN Measure.MeasureSets AS MMS
								ON MM.MeasureSetID = MMS.MeasureSetID
				GROUP BY MX.Abbrev,
						MMS.MeasureSetTypeID,
						MM.MeasureXrefID
			),
			MetricAbbrevs AS
			(
				SELECT	MAB.Abbrev,
						MX.Descr,
						MX.MeasureID,
						MAB.MeasureSetID,
						MAB.MeasureSetTypeID,
						MAB.MeasureXrefID,
						MX.MetricID
				FROM	MetricAbbrevBase AS MAB
						INNER JOIN Measure.Metrics AS MX
								ON MAB.Abbrev = MX.Abbrev
						INNER JOIN Measure.Measures AS MM
								ON MX.MeasureID = MM.MeasureID AND
									MAB.MeasureSetID = MM.MeasureSetID AND
									MAB.MeasureXrefID = MM.MeasureXrefID
			),
			MetricXrefBase AS
			(
				SELECT	Abbrev,
						Descr, 
						MeasureSetTypeID,
						MeasureXrefID
				FROM	MetricAbbrevs
			)
			MERGE	Measure.MetricXrefs AS t
			USING	MetricXrefBase AS s 
			ON		t.Abbrev = s.Abbrev AND
					t.MeasureSetTypeID = s.MeasureSetTypeID AND
					t.MeasureXrefID = s.MeasureXrefID
			WHEN MATCHED AND (t.Descr <> s.Descr) 
			THEN 
					UPDATE SET Descr = s.Descr
			WHEN NOT MATCHED 
			THEN
					INSERT	(Abbrev, Descr, MeasureSetTypeID, MeasureXrefID)
					VALUES	(s.Abbrev, s.Descr, s.MeasureSetTypeID, s.MeasureXrefID);
					
			SET @CountRecords = ISNULL(@CountRecords, 0) + @@ROWCOUNT;
					
			--2b) Populate Metrics with XrefID...
			UPDATE	MX
			SET		MetricXrefID = MXXR.MetricXrefID
			FROM	Measure.Metrics AS MX
					INNER JOIN Measure.Measures AS MM
							ON MX.MeasureID = MM.MeasureID
					INNER JOIN Measure.MeasureSets AS MMS
							ON MM.MeasureSetID = MMS.MeasureSetID
					INNER JOIN Measure.MetricXrefs AS MXXR
							ON MX.Abbrev = MXXR.Abbrev AND
								MMS.MeasureSetTypeID = MXXR.MeasureSetTypeID AND
								MM.MeasureXrefID = MXXR.MeasureXrefID
			WHERE	(MX.MetricXrefID IS NULL) OR 
					(MX.MetricXrefID <> MXXR.MetricXrefID);
					
			SET @CountRecords = ISNULL(@CountRecords, 0) + @@ROWCOUNT;
					
			IF EXISTS(SELECT TOP 1 1 FROM Measure.Measures WHERE MeasureXrefID IS NULL) OR
				EXISTS(SELECT TOP 1 1 FROM Measure.Metrics WHERE MetricXrefID IS NULL)
				BEGIN;
					ROLLBACK TRANSACTION TXref;
				
					RAISERROR('Unable to create Xrefs for all measures and/or metrics.', 16, 1);
				END;
			ELSE
				COMMIT TRANSACTION TXref;
			
						
			SET @LogDescr = 'Refreshing of measure cross-references completed successfully.'; 
			SET @LogEndTime = GETDATE();
			
			EXEC @Result = Log.RecordEntry	@BatchID = @BatchID,
												@BeginTime = @LogBeginTime,
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
			SET @LogDescr = 'Refreshing of measure cross-references failed!';
			
			EXEC @Result = Log.RecordEntry	@BatchID = @BatchID,
												@BeginTime = @LogBeginTime,
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
GRANT EXECUTE ON  [Measure].[RefreshXrefs] TO [Processor]
GO
