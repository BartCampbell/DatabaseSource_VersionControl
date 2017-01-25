SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 1/18/2010
-- Description:	Records the usage of the specified report.
-- =============================================
CREATE PROCEDURE [Log].[RecordReportUsage]
(
	@BeginTime datetime = NULL,
	@CountRecords int = -1,
	@EndTime datetime = NULL,
	@LogID bigint = NULL OUTPUT,
	@Parameters Report.ReportParameters READONLY,
	@SrcObjectName nvarchar(128),
	@SrcObjectSchema nvarchar(128),
	@UserName nvarchar(128)
)
AS
BEGIN
	SET NOCOUNT ON;
	
	IF @SrcObjectName IS NOT NULL AND @SrcObjectSchema IS NOT NULL AND @UserName IS NOT NULL
		BEGIN;
			BEGIN TRY;
				--DEFINE SOURCE OBJECT-----------------------------------------
				DECLARE @SrcObjectGuid uniqueidentifier;
				DECLARE @SrcObjectID smallint;
				
				SELECT	@SrcObjectGuid = SO.SrcObjectGuid,
						@SrcObjectID = SO.SrcObjectID 
				FROM	[Log].SourceObjects AS SO
				WHERE	(ObjectName = @SrcObjectName) AND
						(ObjectSchema = @SrcObjectSchema) 
			
				BEGIN TRANSACTION TLog1;
				
				IF @SrcObjectID IS NULL
					BEGIN
						SET @SrcObjectGuid = NEWID();
						
						INSERT INTO	[Log].SourceObjects
						        (SrcObjectGuid,
								ObjectName,
								ObjectSchema)
						 VALUES	(@SrcObjectGuid,
								@SrcObjectName,
								@SrcObjectSchema);
						 						        
						 SET @SrcObjectID = SCOPE_IDENTITY();
					END
					
				--DEFINE SOURCE REPORT-----------------------------------------	
				DECLARE @SrcReportGuid uniqueidentifier;
				DECLARE @SrcReportID smallint;
				
				SELECT	@SrcReportID = SrcReportID
				FROM	[Log].Reports 
				WHERE	(SrcObjectID = @SrcObjectID)
				
				IF @SrcReportID IS NULL
					BEGIN
						SET @SrcReportGuid = NEWID();
						
						INSERT INTO	[Log].Reports
						        (SrcObjectID, SrcReportGuid)
						 VALUES	(@SrcObjectID, @SrcReportGuid)
						 						        
						 SET @SrcReportID = SCOPE_IDENTITY();
					END
					
				--CONVERT PARAMETERS TO XML------------------------------------
				DECLARE @Params varchar(MAX);
				SELECT	@Params = ISNULL(@Params, '') + 
									'<parameter id="' + t.ParameterName + '">' + CAST(ISNULL(t.[Value], '#NULL#') AS varchar(256)) + '</parameter>'
				FROM	@Parameters	AS t			
				
				SET @Params = '<parameters>'+ @Params + '</parameters>'
				
				--LOG REPORT---------------------------------------------------
				INSERT INTO [Log].ReportUsage
						(BeginTime, CountRecords, EndTime, [Parameters], SrcReportID, UserName)
				VALUES	(@BeginTime, @CountRecords, @EndTime, CAST(@Params AS xml), @SrcReportID, @UserName)	
						
				SET @LogID = SCOPE_IDENTITY();
					
				COMMIT TRANSACTION TLog1;
				
				RETURN 0;
			END TRY
			BEGIN CATCH;		
				WHILE @@TRANCOUNT > 0
					ROLLBACK;
			
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
GRANT EXECUTE ON  [Log].[RecordReportUsage] TO [Processor]
GO
GRANT EXECUTE ON  [Log].[RecordReportUsage] TO [Submitter]
GO
