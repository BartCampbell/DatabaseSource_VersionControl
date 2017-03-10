SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 9/5/2012
-- Description:	Saves the contents of the process entries and error logs for the specified batch, based on the supplied XML data.
-- =============================================
CREATE PROCEDURE [Cloud].[SubmitLog]
(
	@BatchGuid uniqueidentifier = NULL,
	@BatchID int = NULL,
	@BatchSourceGuid uniqueidentifier = NULL,
	@Data xml,
	@EngineGuid uniqueidentifier,
	@EngineTypeGuid uniqueidentifier,
	@PurgeExistingLog bit = 0
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

		IF @BatchGuid IS NULL
			RAISERROR('The specified batch is invalid.', 16, 1);
				
		IF @Data IS NULL OR @Data.exist('batch/*') = 0
			RAISERROR ('The supplied xml data is invalid.', 16, 1);

		BEGIN TRANSACTION TLogSubmittal;

		IF @PurgeExistingLog = 1
			BEGIN;
				DELETE FROM Log.ProcessEntries WHERE (BatchID = @BatchID) AND (EngineGuid = @EngineGuid);
				DELETE FROM Log.ProcessErrors WHERE (BatchID = @BatchID) AND (EngineGuid = @EngineGuid);
			END;

		IF @Data.exist('batch/logentries/*') = 1
			WITH BatchEntries AS
			(
				SELECT	batch.value('@id', 'uniqueidentifier') AS batch,
						Batch.query('./logentries/logentry') AS logentries
				FROM	@Data.nodes('/batch') AS b(batch)
			),
			LogEntries AS
			(
				SELECT	batch.batch,
						entries.value('@id', 'bigint') AS id,
						entries.value('@begintime', 'datetime') AS begintime,
						entries.value('@records', 'int') AS records,
						entries.value('@description', 'varchar(256)') AS [description],
						entries.value('@endtime', 'datetime') AS endtime,
						entries.value('@engine', 'uniqueidentifier') AS engine,
						entries.value('@entryxref', 'uniqueidentifier') AS entryxref,
						entries.value('@execsourceobject', 'uniqueidentifier') AS execsourceobject,
						entries.value('@success', 'bit') AS success,
						entries.value('@iteration', 'tinyint') AS iteration,
						entries.value('@logdate', 'datetime') AS logdate,
						entries.value('@loguser', 'nvarchar(128)') AS loguser,
						entries.value('@sourceobject', 'uniqueidentifier') AS sourceobject,
						entries.value('@stepnumber', 'smallint') AS stepnumber,
						entries.value('@steptotal', 'smallint') AS steptotal
				FROM	BatchEntries AS batch
						CROSS APPLY batch.logentries.nodes('/logentries/logentry') AS e(entries)
			)
			INSERT INTO Log.ProcessEntries
					(BatchID,
					BeginTime,
					CountRecords,
					DataRunID,
					DataSetID,
					Descr,
					EndTime,
					EngineGuid,
					EntryXrefGuid,
					EntryXrefID,
					ExecObjectGuid,
					ExecObjectID,
					IsSuccess,
					Iteration,
					LogDate,
					LogUser,
					MeasureSetID,
					OwnerID,
					SrcObjectGuid,
					SrcObjectID,
					StepNbr,
					StepTot)
			SELECT	BB.BatchID,
					LE.begintime AS BeginTime, 
					LE.records AS CountRecords,
					BB.DataRunID,
					BB.DataSetID,
					LE.[description] AS Descr,
					LE.endtime AS EndTime,
					LE.engine AS EngineGuid,
					LPEX.EntryXrefGuid,
					LPEX.EntryXrefID,
					LSOX.SrcObjectGuid AS ExecObjectGuid,
					LSOX.SrcObjectID AS ExecObjectID,
					LE.success AS IsSuccess,
					LE.iteration AS Iteration,
					LE.logdate AS LogDate,
					LE.loguser AS LogUser,
					BDR.MeasureSetID,
					BDS.OwnerID,
					LSO.SrcObjectGuid,
					LSO.SrcObjectID,
					LE.stepnumber AS StepNbr,
					LE.steptotal AS StepTot
			FROM	LogEntries AS LE
					INNER JOIN Batch.[Batches] AS BB
							ON LE.batch = ISNULL(BB.SourceGuid, BB.BatchGuid) AND
								BB.BatchID = @BatchID
					INNER JOIN Batch.DataRuns AS BDR
							ON BB.DataRunID = BDR.DataRunID
					INNER JOIN Batch.DataSets AS BDS
							ON BDR.DataSetID = BDS.DataSetID
					INNER JOIN [Log].ProcessEntryXrefs AS LPEX
							ON LE.entryxref = LPEX.EntryXrefGuid
					INNER JOIN [Log].SourceObjects AS LSO 
							ON LE.sourceobject = LSO.SrcObjectGuid
					LEFT OUTER JOIN [Log].SourceObjects AS LSOX
							ON LE.execsourceobject = LSOX.SrcObjectGuid
			WHERE	(LE.engine = @EngineGuid);
						
		IF @Data.exist('batch/logerrors/*') = 1
			WITH BatchEntries AS
			(
				SELECT	batch.value('@id', 'uniqueidentifier') AS batch,
						Batch.query('./logerrors/logerror') AS logerrors
				FROM	@Data.nodes('/batch') AS b(batch)
			),
			LogErrors AS
			(
				SELECT	batch.batch,
						errors.value('@id', 'bigint') AS id,
						errors.value('@application', 'nvarchar(128)') AS [application],
						errors.value('@engine', 'uniqueidentifier') AS engine,
						errors.value('@number', 'int') AS number,
						errors.value('@type', 'char(1)') AS [type],
						errors.value('@host', 'nvarchar(128)') AS host,
						CASE WHEN errors.exist('./info/*') = 1 THEN errors.query('./info/*') END AS info,
						errors.value('@ipaddress', 'nvarchar(128)') AS ipaddress,
						errors.value('@line', 'int') AS line,
						errors.value('@logdate', 'datetime') AS logdate,
						errors.value('@loguser', 'nvarchar(128)') AS loguser,
						errors.value('@message', 'nvarchar(max)') AS [message],
						errors.value('@severity', 'int') AS severity,
						errors.value('@source', 'nvarchar(512)') AS [source],
						errors.value('@spid', 'int') AS [spid],
						errors.value('@state', 'int') AS [state],
						errors.value('@stack', 'nvarchar(max)') AS [stack],
						errors.value('@target', 'nvarchar(512)') AS [target]
				FROM	BatchEntries AS batch
						CROSS APPLY batch.logerrors.nodes('/logerrors/logerror') AS e(errors)
			)
			INSERT INTO Log.ProcessErrors
					([Application],
					BatchID,
					DataRunID,
					DataSetID,
					EngineGuid,
					ErrorNumber,
					ErrorType,
					Host,
					Info,
					IPAddress,
					LineNumber,
					LogDate,
					LogUser,
					MeasureSetID,
					[Message],
					OwnerID,
					Severity,
					[Source],
					SpId,
					[State],
					Stack,
					[Target])
			SELECT	LE.[application] AS [Application],
					BB.BatchID,
					BDR.DataRunID,
					BDS.DataSetID,
					LE.engine AS EngineGuid,
					LE.number AS ErrorNumber,
					LE.[type] AS ErrorType,
					LE.host AS [Host],
					LE.info AS Info,
					LE.ipaddress AS IPAddress,
					LE.line AS LineNumber,
					LE.logdate AS LogDate,
					LE.loguser AS LogUser,
					BDR.MeasureSetID,
					LE.[message] AS [Message],
					BDS.OwnerID,
					LE.severity AS Severity,
					LE.[source] AS [Source],
					LE.[spid] AS [SpId],
					LE.[state] AS [State],
					LE.[stack] AS [Stack],
					LE.[target] AS [Target]
			FROM	LogErrors AS LE
					INNER JOIN Batch.[Batches] AS BB
							ON LE.batch = ISNULL(BB.SourceGuid, BB.BatchGuid) AND
								BB.BatchID = @BatchID
					INNER JOIN Batch.DataRuns AS BDR
							ON BB.DataRunID = BDR.DataRunID
					INNER JOIN Batch.DataSets AS BDS
							ON BDR.DataSetID = BDS.DataSetID
			WHERE	(LE.engine = @EngineGuid);
		
		COMMIT TRANSACTION TLogSubmittal;
		
		EXEC Cloud.UpdateEngineActivity @EngineGuid = @EngineGuid;
								
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
											@EngineGuid = @EngineGuid,
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
GO
GRANT EXECUTE ON  [Cloud].[SubmitLog] TO [Controller]
GO
GRANT VIEW DEFINITION ON  [Cloud].[SubmitLog] TO [db_executer]
GO
GRANT EXECUTE ON  [Cloud].[SubmitLog] TO [db_executer]
GO
GRANT EXECUTE ON  [Cloud].[SubmitLog] TO [Processor]
GO
GRANT EXECUTE ON  [Cloud].[SubmitLog] TO [Submitter]
GO
GO

GO

GO

GO
