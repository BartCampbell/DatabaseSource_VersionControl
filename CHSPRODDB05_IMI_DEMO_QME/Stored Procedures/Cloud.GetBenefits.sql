SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 6/14/2013
-- Description:	Returns the list benefits.
-- =============================================
CREATE PROCEDURE [Cloud].[GetBenefits]
(
	@BenefitGuid uniqueidentifier = NULL,
	@BenefitID smallint = NULL
)
AS
BEGIN
	SET NOCOUNT ON;
	
	BEGIN TRY;
		
		SELECT	Abbrev,
		        BenefitGuid,
		        BenefitID,
		        BitSeed,
		        BitValue,
		        Descr,
		        IsParent
		FROM	Product.Benefits AS PB WITH(NOLOCK)
		WHERE	((@BenefitGuid IS NULL) OR (PB.BenefitGuid = @BenefitGuid)) AND
				((@BenefitID IS NULL) OR (PB.BenefitID = @BenefitID));
								
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
GRANT EXECUTE ON  [Cloud].[GetBenefits] TO [Controller]
GO
GRANT VIEW DEFINITION ON  [Cloud].[GetBenefits] TO [db_executer]
GO
GRANT EXECUTE ON  [Cloud].[GetBenefits] TO [db_executer]
GO
GRANT EXECUTE ON  [Cloud].[GetBenefits] TO [NController]
GO
GRANT EXECUTE ON  [Cloud].[GetBenefits] TO [NProcessor]
GO
GRANT EXECUTE ON  [Cloud].[GetBenefits] TO [NService]
GO
GRANT EXECUTE ON  [Cloud].[GetBenefits] TO [Processor]
GO
GRANT EXECUTE ON  [Cloud].[GetBenefits] TO [Submitter]
GO
