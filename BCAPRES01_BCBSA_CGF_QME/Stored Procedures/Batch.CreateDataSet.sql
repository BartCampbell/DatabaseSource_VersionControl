SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 8/30/2011
-- Description:	Creates a new Data Set.
-- =============================================
CREATE PROCEDURE [Batch].[CreateDataSet]
(
	@DataSetGuid uniqueidentifier = NULL OUTPUT,
	@DataSetID int = NULL OUTPUT,
	@DefaultIhdsProviderId int = NULL,
	@OwnerID int,
	@SourceGuid uniqueidentifier = NULL
)
AS
BEGIN
	SET NOCOUNT ON;
		
	DECLARE @Result int;
	
	BEGIN TRY;
		
		DECLARE @UserDate datetime;
		DECLARE @UserName nvarchar(128);

		SELECT	@UserDate = GETDATE(),
		@UserName = SUSER_SNAME();
		
		IF (@DataSetID IS NULL) AND 
			(@OwnerID IS NOT NULL) AND EXISTS(SELECT TOP (1) 1 FROM Batch.DataOwners WHERE OwnerID = @OwnerID)
			BEGIN;
			
				IF @DataSetGuid IS NULL
					SET @DataSetGuid = NEWID();
				
				BEGIN TRANSACTION TDataSet;
				
				INSERT INTO Batch.DataSets
						(CreatedBy, CreatedDate, DataSetGuid, DefaultIhdsProviderID, OwnerID, SourceGuid)
				VALUES	
						(@UserName, @UserDate, @DataSetGuid, @DefaultIhdsProviderID, @OwnerID, ISNULL(@SourceGuid, @DataSetGuid));
						
				SELECT @DataSetID = SCOPE_IDENTITY();

				INSERT INTO Batch.DataSetProcedures
						(DataSetID, ProcID)
				SELECT	@DataSetID,
						ProcID
				FROM	Batch.[Procedures]
				WHERE	(IsEnabled = 1)

				COMMIT TRANSACTION TDataSet;

				RETURN 0;
			END;
		ELSE
			RAISERROR('Unable to create data set.  The specified parameters are invalid.', 16, 1);
		
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
GRANT EXECUTE ON  [Batch].[CreateDataSet] TO [Processor]
GO
