SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- =============================================
-- Author:		Kriz, Mike
-- Create date: 2/12/2011
-- Description:	Wraps up steps to run once an initialization of an entity processing iteration is complete.
-- =============================================
CREATE PROCEDURE [Batch].[InitializeEntityBasePost]
(
	@BatchID int,
	@Iteration tinyint
)
AS
BEGIN
	SET NOCOUNT ON;
	
	BEGIN TRY;			
		--IF EXISTS (SELECT TOP 1 1 FROM Temp.EntityBase WHERE EntityBaseID IS NULL)
		--	BEGIN
		--		DECLARE @EntityBaseID bigint;
		--		UPDATE t SET @EntityBaseID = EntityBaseID = ISNULL(@EntityBaseID, 0) + 1 FROM Temp.EntityBase WITH(TABLOCKX) OPTION (MAXDOP 1);

		--		CREATE UNIQUE CLUSTERED INDEX IX_Temp_Entity ON Temp.EntityBase (EntityBaseID, OptionNbr, RankOrder, SourceID, SpId);
		--	END
								
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
											@PerformRollback = 0,
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
GRANT VIEW DEFINITION ON  [Batch].[InitializeEntityBasePost] TO [db_executer]
GO
GRANT EXECUTE ON  [Batch].[InitializeEntityBasePost] TO [db_executer]
GO
GRANT EXECUTE ON  [Batch].[InitializeEntityBasePost] TO [Processor]
GO
