SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 9/4/2012
-- Description:	Returns contents of the process entries and error logs for the specified batch as an XML file.
--				Optionally, returns the log as only non-syced or all (both synced and non-synced)
-- =============================================
CREATE PROCEDURE [Cloud].[GetLog]
(
	@BatchGuid uniqueidentifier = NULL,
	@BatchID int = NULL,
	@BatchSourceGuid uniqueidentifier = NULL,
	@Data xml = NULL OUTPUT,
	@ReturnFullLog bit = 0,
	@ShowResults bit = 0
)
AS
BEGIN
	SET NOCOUNT ON;
	
	BEGIN TRY;
		
		IF @BatchGuid IS NULL AND @BatchID IS NULL AND @BatchSourceGuid IS NULL
			RAISERROR('The batch was not specified.', 16, 1);
		
		SELECT TOP 1 
				@BatchGuid = BatchGuid, 
				@BatchID = BatchID,
				@BatchSourceGuid = SourceGuid
		FROM	Batch.[Batches] 
		WHERE	((@BatchGuid IS NULL) OR (BatchGuid = @BatchGuid)) AND
				((@BatchID IS NULL) OR (BatchID = @BatchID)) AND
				((@BatchSourceGuid IS NULL) OR (SourceGuid = @BatchSourceGuid));

		IF @BatchGuid IS NOT NULL
			BEGIN;

				BEGIN TRANSACTION TLogRetrieval;

				DECLARE @ProcessEntries TABLE
				(
					LogID bigint NOT NULL
				);

				UPDATE	LPE
				SET		IsSynced = 1
				OUTPUT	INSERTED.LogID INTO @ProcessEntries 
				FROM	[Log].ProcessEntries AS LPE
				WHERE	(LPE.BatchID = @BatchID) AND
						(LPE.IsSynced = 0);
						
				DECLARE @ProcessErrors TABLE
				(
					LogID bigint NOT NULL
				);

				UPDATE	LPR
				SET		IsSynced = 1
				OUTPUT	INSERTED.LogID INTO @ProcessErrors 
				FROM	[Log].ProcessErrors AS LPR
						INNER JOIN [Log].ProcessEntries AS LPE
								ON LPR.LogID = LPE.ErrLogID
				WHERE	(LPE.BatchID = @BatchID) AND
						(LPR.IsSynced = 0);

				IF (EXISTS (SELECT TOP 1 1 FROM @ProcessEntries)) OR 
					(EXISTS (SELECT TOP 1 1 FROM @ProcessErrors)) OR 
					(@ReturnFullLog = 1)
					SET @Data = 
					(SELECT	ISNULL(batch.SourceGuid, batch.BatchGuid) AS id,
							(
								SELECT	LPE.LogID AS id,
										LPE.BeginTime AS begintime,
										LPE.CountRecords AS records,
										LPE.Descr AS [description],
										LPE.EndTime AS [endtime],
										LPE.EngineGuid AS engine,
										LPE.EntryXrefGuid AS entryxref,
										LPE.ExecObjectGuid AS execsourceobject,
										LPE.IsSuccess AS success,
										LPE.Iteration AS iteration,
										LPE.LogDate AS logdate,
										LPE.LogUser AS loguser,
										LPE.SrcObjectGuid AS sourceobject,
										LPE.StepNbr AS stepnumber,
										LPE.StepTot AS steptotal
								FROM	Log.ProcessEntries AS LPE
								WHERE	(LPE.BatchID = batch.BatchID) AND
										(
											(LPE.LogID IN (SELECT DISTINCT LogID FROM @ProcessEntries)) OR 
											(@ReturnFullLog = 1)
										)
								FOR XML RAW ('logentry'), TYPE
							) AS logentries,
							(
								SELECT	LPR.LogID AS id,
										LPR.[Application] AS [application],
										LPR.EngineGuid AS [engine],
										LPR.ErrorNumber AS [number],
										LPR.ErrorType AS [type],
										LPR.Host AS [host],
										LPR.Info AS [info],
										LPR.IPAddress AS [ipaddress],
										LPR.LineNumber AS [line],
										LPR.LogDate AS [logdate],
										LPR.LogUser AS [loguser],
										LPR.[Message] AS [message],
										LPR.Severity AS severity,
										LPR.[Source] AS [source],
										LPR.SpId AS [spid],
										LPR.[State] AS [state],
										LPR.Stack AS [stack],
										LPR.[Target] AS [target]
								FROM	Log.ProcessErrors AS LPR
										INNER JOIN Log.ProcessEntries AS LPE
												ON LPR.LogID = LPE.ErrLogID
								WHERE	(LPE.BatchID = batch.BatchID) AND
										(
											(LPR.LogID IN (SELECT DISTINCT LogID FROM @ProcessErrors))  OR 
											(@ReturnFullLog = 1)
										)
								FOR XML RAW ('logerror'), TYPE
							) AS logerrors
					FROM	Batch.[Batches] AS batch
					WHERE	(BatchID = @BatchID)
					FOR XML AUTO, TYPE);

				IF @Data IS NOT NULL AND @ShowResults = 1
					SELECT @Data AS result;

				COMMIT TRANSACTION TLogRetrieval;
			END;
								
		RETURN 0;
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
											@PerformRollback = 1,
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
GRANT EXECUTE ON  [Cloud].[GetLog] TO [Controller]
GO
GRANT EXECUTE ON  [Cloud].[GetLog] TO [Processor]
GO
GRANT EXECUTE ON  [Cloud].[GetLog] TO [Submitter]
GO
