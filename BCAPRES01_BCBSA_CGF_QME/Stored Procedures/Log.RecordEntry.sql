SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Kriz, Mike
-- Create date: 1/18/2010
-- Description:	Records the progress of the specified batch.
-- =============================================
CREATE PROCEDURE [Log].[RecordEntry]
(
	@BatchID int = NULL,
	@BeginTime datetime = NULL,
	@CountRecords int = -1,
	@DataRunID int = NULL,
	@DataSetID int = NULL,
	@Descr varchar(256) = NULL,
	@EndTime datetime = NULL,
	@EntryXrefGuid uniqueidentifier = NULL,
	@ErrLogID int = NULL,
	@ExecObjectName nvarchar(128) = NULL,
	@ExecObjectSchema nvarchar(128) = NULL,
	@IsSuccess bit = 0,
	@Iteration tinyint = NULL,
	@ProgLogID int = NULL OUTPUT,
	@SrcObjectName nvarchar(128),
	@SrcObjectSchema nvarchar(128),
	@StepNbr smallint = NULL,
	@StepTot smallint = NULL
)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @EngineGuid uniqueidentifier;
	DECLARE @MeasureSetID int;
	DECLARE @OwnerID int;
	
	SET @EngineGuid = Engine.GetEngineGuid();
	
	IF @DataRunID IS NULL
		SELECT	@OwnerID = DS.OwnerID
		FROM	Batch.DataSets AS DS
		WHERE	(DS.DataSetID = @DataSetID)
	ELSE
		SELECT TOP 1
				@DataSetID = DR.DataSetID, 
				@MeasureSetID = DR.MeasureSetID,
				@OwnerID = DS.OwnerID
		FROM	Batch.DataSets AS DS
				INNER JOIN Batch.DataRuns AS DR
						ON DS.DataSetID = DR.DataSetID 
		WHERE	
				(DR.DataRunID = @DataRunID)
	
	IF @DataSetID IS NOT NULL AND @OwnerID IS NOT NULL AND (@Descr IS NOT NULL OR @EntryXrefGuid IS NOT NULL)
		BEGIN;
			BEGIN TRY;
				DECLARE @EntryXrefDescr varchar(256);
				DECLARE @EntryXrefID smallint;
				DECLARE @ExecObjectGuid uniqueidentifier;
				DECLARE @ExecObjectID smallint;
				DECLARE @SrcObjectGuid uniqueidentifier;
				DECLARE @SrcObjectID smallint;
			
				BEGIN TRANSACTION TLog1;
				
				IF @EntryXrefGuid IS NOT NULL
					BEGIN; 
						SELECT	@EntryXrefDescr = Descr,
								@EntryXrefID = EntryXrefID 
						FROM	[Log].ProcessEntryXrefs WHERE (EntryXrefGuid = @EntryXrefGuid); 
						
						IF @Descr IS NULL	
							SET @Descr = @EntryXrefDescr;
					END;
				
				IF ISNULL(@ExecObjectName, '') <> '' AND ISNULL(@ExecObjectSchema, '') <> ''
					EXEC [Log].RetrieveSourceObject @ObjectName = @ExecObjectName, @ObjectSchema = @ExecObjectSchema, 
													@SrcObjectGuid = @ExecObjectGuid OUTPUT, @SrcObjectID = @ExecObjectID OUTPUT;
				
				EXEC [Log].RetrieveSourceObject @ObjectName = @SrcObjectName, @ObjectSchema = @SrcObjectSchema, 
												@SrcObjectGuid = @SrcObjectGuid OUTPUT, @SrcObjectID = @SrcObjectID OUTPUT;
												
				INSERT INTO [Log].ProcessEntries 
						(BatchID, BeginTime, CountRecords, DataRunID, DataSetID, Descr,
						EndTime, EngineGuid, EntryXrefGuid, EntryXrefID, ErrLogID, ExecObjectGuid, ExecObjectID, 
						IsSuccess, Iteration, MeasureSetID, OwnerID,
						LogDate, LogUser, SrcObjectGuid, SrcObjectID, StepNbr, StepTot)
				VALUES
						(@BatchID, @BeginTime, @CountRecords, @DataRunID, @DataSetID, @Descr,
						@EndTime, @EngineGuid, @EntryXrefGuid, @EntryXrefID, @ErrLogID,  @ExecObjectGuid, @ExecObjectID,
						@IsSuccess, @Iteration, @MeasureSetID, @OwnerID, 
						GETDATE(), SUSER_NAME(), @SrcObjectGuid, @SrcObjectID, @StepNbr, @StepTot);
						
				SET @ProgLogID = SCOPE_IDENTITY();
				
				IF @DataRunID IS NOT NULL AND 
					NOT EXISTS	(
									SELECT	TOP 1 1 
									FROM	Engine.Settings AS ES WITH(NOLOCK)
											INNER JOIN Engine.[Types] AS ET WITH(NOLOCK)
													ON ES.EngineTypeID = ET.EngineTypeID
									WHERE	(ET.EngineTypeGuid IN ('D8EECCCD-1EB1-4D3B-ADC4-956B668EA965' /*Controller*/,
																	'83DC0601-C270-4B51-944B-95E9BCEAEBC4' /*Submitter*/))
								)
					UPDATE	Batch.DataRuns
					SET		LastErrLogID = ISNULL(@ErrLogID, LastErrLogID),
							LastErrLogTime = CASE WHEN @ErrLogID IS NULL THEN LastErrLogTime ELSE GETDATE() END,
							LastProgLogID = @ProgLogID,
							LastProgLogTime = GETDATE()
					WHERE	DataRunID = @DataRunID 
					
				COMMIT TRANSACTION TLog1;
				
				PRINT CONVERT(varchar, @EndTime, 101) + ' ' + CONVERT(varchar, @EndTime, 114) + '  ' + LTRIM(REPLACE(@Descr, ' - ', '   ')) ;
				
				IF @CountRecords >= 0
					PRINT REPLICATE(' ', LEN(REPLACE(CONVERT(varchar, @EndTime, 101) + ' ' + CONVERT(varchar, @EndTime, 114) + '  ', ' ', '*'))) + '(Records: ' + CONVERT(varchar, @CountRecords) + ')';
				
				PRINT '';	
				
				RETURN 0;
			END TRY
			BEGIN CATCH;		
				DECLARE @ErrorApp nvarchar(128);
				DECLARE @ErrorLine int;
				DECLARE @ErrorLogID int;
				DECLARE @ErrorMessage nvarchar(max);
				DECLARE @ErrorNumber int;
				DECLARE @ErrorSeverity int;
				DECLARE @ErrorSource nvarchar(512);
				DECLARE @ErrorState int;
				
				DECLARE @Result int;
				
				SELECT	@ErrorApp = DB_NAME(),
						@ErrorLine = ERROR_LINE(),
						@ErrorMessage = ERROR_MESSAGE(),
						@ErrorNumber = ERROR_NUMBER(),
						@ErrorSeverity = ERROR_SEVERITY(),
						@ErrorSource = ERROR_PROCEDURE(),
						@ErrorState = ERROR_STATE();
						
				EXEC @Result = [Log].RecordError	@Application = @ErrorApp,
													@DataRunID = @DataRunID,
													@DataSetID = @DataSetID,
													@LineNumber = @ErrorLine,
													@Message = @ErrorMessage,
													@ErrorNumber = @ErrorNumber,
													@ErrorType = 'Q',
													@ErrLogID = @ErrorLogID OUTPUT,
													@Severity = @ErrorSeverity,
													@Source = @ErrorSource,
													@State = @ErrorState;
				
				IF @Result <> 0
					BEGIN
						PRINT '*** Error Log Failure:  Unable to record the specified entry. ***'
						SET @ErrorNumber = @ErrorLine * -1;
					END
					
				RETURN @ErrorNumber;
			END CATCH;
		END;
END
GO
GRANT EXECUTE ON  [Log].[RecordEntry] TO [Processor]
GO
GRANT EXECUTE ON  [Log].[RecordEntry] TO [Submitter]
GO
