SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 1/24/2011
-- Description: Ranks event options based on the selectivity and quantity used of codes/code types in the underlying event criteria.
--				(UPDATED: 12/10/2015, Added ability to rank event criteria when no codes were present via (CodeTypeID = 0).
-- =============================================
CREATE PROCEDURE [Measure].[RankEventOptions]
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
	
	DECLARE @DataSetID int;
	DECLARE @MeasureSetID int;
	
	DECLARE @Result int;
	
		BEGIN TRY;
		
		SELECT	@DataSetID = DR.DataSetID,
				@MeasureSetID = DR.MeasureSetID 
		FROM	Batch.DataRuns AS DR
		WHERE	(DR.DataRunID = @DataRunID);
		
		SET @LogBeginTime = GETDATE();
		SET @LogObjectName = 'RankEventOptions'; 
		SET @LogObjectSchema = 'Measure'; 
						
		--Added to determine @LogEntryXrefGuid value---------------------------
		SELECT @LogEntryXrefGuid = [Log].GetEntryXrefGuid (@LogObjectSchema, @LogObjectName);
		-----------------------------------------------------------------------
		
		BEGIN TRY;
				
			DECLARE @CountRecords int;

			WITH [Events] AS
			(
				-- Step #1) Get all of the events for the current measure set...
				SELECT	*
				FROM	Measure.[Events] AS E
				WHERE	(E.MeasureSetID = @MeasureSetID)
			),
			SeverityCodeCount AS
			(
				--Step #2) Evaluate the specificity of the code type based on the quantity of codes in the engine by the code type...
				SELECT	CodeTypeID,
						COUNT(*) AS CountCodes
				FROM	Claim.Codes
				GROUP BY CodeTypeID
				UNION 
				SELECT	0 AS CodeTypeID, 
						0 AS CountCodes
			),
			SelectivityRank AS
			(
				--Step #3) Using the counts from step #2, rank the code types...
				SELECT	CodeTypeID,
						ROW_NUMBER() OVER (ORDER BY CountCodes DESC) AS RankOrder
				FROM	SeverityCodeCount
			),
			QuantityCodeCount AS
			(	
				--Step #4) Simliar to step #2, evaluate the specificity of codes based on event/option combinations...
				SELECT	MEO.EventID, MEO.OptionNbr, MEO.EventCritID, MEC.ClaimTypeID,
						ISNULL(MECC.CodeTypeID, 0) AS CodeTypeID, MEO.Allow, MEO.Require1stRank,
						COUNT(DISTINCT MECC.EventCritCodeID) AS CountCodes
				FROM	Measure.EventOptions AS MEO
						INNER JOIN Measure.EventCriteria AS MEC
								ON MEO.EventCritID = MEC.EventCritID
						LEFT OUTER JOIN Measure.EventCriteriaCodes AS MECC
								ON MEO.EventCritID = MECC.EventCritID AND
									MEC.EventCritID = MECC.EventCritID
				WHERE	(MEO.EventID IN (SELECT EventID FROM [Events]))
				GROUP BY MEO.EventID, MEO.OptionNbr, MEO.EventCritID, 
						MEC.ClaimTypeID, MECC.CodeTypeID, 
						MEO.Allow, MEO.Require1stRank
				--ORDER BY MEO.EventID, OptionNbr
			),
			QuantityRank AS
			(
				--Step #5) Based on the counts from step #4, rank event criteria for each event/option combination...
				SELECT	EventID, OptionNbr, EventCritID, ClaimTypeID, CodeTypeID, 
						Allow, Require1stRank,
						ROW_NUMBER() OVER (PARTITION BY	EventID, OptionNbr ORDER BY Allow DESC, CountCodes, EventCritID ASC) AS RankOrder
				FROM	QuantityCodeCount
			),
			CombinedRank AS
			(
				--Step #6) Combine the two rankings from steps #3 and #5 to derive a single ranking...
				SELECT	QR.EventID, QR.OptionNbr, QR.EventCritID, 
						ROW_NUMBER() OVER	(
												PARTITION BY	QR.EventID, QR.OptionNbr 
												ORDER BY		MAX(CAST(Require1stRank AS smallint)) DESC, 
																MAX(CAST(Allow AS smallint)) DESC, 
																MIN(ClaimTypeID) ASC,
																MAX(QR.RankOrder + SR.RankOrder) ASC
											) AS RankOrder
				FROM	QuantityRank AS QR
						INNER JOIN SelectivityRank AS SR
								ON QR.CodeTypeID = SR.CodeTypeID
				GROUP BY QR.EventID, QR.OptionNbr, QR.EventCritID
			)
			--Step #7) Apply the final ranking...
			UPDATE	MEO
			SET		RankOrder = CR.RankOrder
			FROM	Measure.EventOptions AS MEO
					INNER JOIN CombinedRank AS CR
							ON MEO.EventID = CR.EventID AND
								MEO.OptionNbr = CR.OptionNbr AND
								MEO.EventCritID = CR.EventCritID	

			SET @CountRecords = ISNULL(@CountRecords, 0) + @@ROWCOUNT;
			
			DELETE FROM Internal.EventKey WHERE (SpId = @@SPID) OR (DataRunID = @DataRunID);
			
			IF NOT EXISTS(SELECT TOP 1 1 FROM Internal.EventKey)
				TRUNCATE TABLE Internal.EventKey;


			WITH RankingValidation AS
			(
				SELECT	MIN(MV.Descr) AS EventDescr,
						MV.EventID,
						MIN(MV.MeasureSetID) AS MeasureSetID,
						MVO.OptionNbr,
						MVO.RankOrder
				FROM	Measure.Events AS MV
						INNER JOIN Measure.EventOptions AS MVO
								ON MVO.EventID = MV.EventID
						INNER JOIN Measure.EventCriteria AS MVC
								ON MVC.EventCritID = MVO.EventCritID
				GROUP BY MV.EventID,
						MVO.OptionNbr,
						MVO.RankOrder
				HAVING COUNT(*) > 1
			)
			SELECT	t.*, MM.Abbrev
			INTO	#InvalidRankings
			FROM	RankingValidation AS t
					INNER JOIN Measure.MeasureEvents AS MMV
							ON MMV.EventID = t.EventID AND
								MMV.MeasureSetID = t.MeasureSetID
					INNER JOIN Measure.Measures AS MM
							ON MM.MeasureID = MMV.MeasureID;

			IF EXISTS (SELECT TOP 1 1 FROM #InvalidRankings)
				BEGIN;
					SELECT * FROM #InvalidRankings;
					RAISERROR('One or more event/option combinations have more than one event criteria with the same rank.  See resultset for more information.', 16, 1);
				END;

			SET @LogDescr = 'Ranking of event options completed succcessfully.'; 
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
			SET @LogDescr = 'Ranking of event options failed!'; 
			
			EXEC @Result = Log.RecordEntry	@BeginTime = @LogBeginTime,
												@CountRecords = -1, 
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
GRANT EXECUTE ON  [Measure].[RankEventOptions] TO [Processor]
GO
