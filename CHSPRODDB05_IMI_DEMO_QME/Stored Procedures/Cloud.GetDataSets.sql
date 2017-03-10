SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 9/13/2012
-- Description:	Returns the list of data sets.
-- =============================================
CREATE PROCEDURE [Cloud].[GetDataSets]
(
	@DataSetGuid uniqueidentifier = NULL,
	@DataSetID int = NULL,
	@DataSetSourceGuid uniqueidentifier = NULL,
	@OwnerGuid uniqueidentifier = NULL,
	@OwnerID int = NULL
)
AS
BEGIN
	SET NOCOUNT ON;
	
	BEGIN TRY;
		
		SELECT	BDS.CountClaimCodes,
		        BDS.CountClaimLines,
		        BDS.CountClaims,
		        BDS.CountEnrollment,
		        BDS.CountMemberAttribs,
		        BDS.CountMembers,
		        BDS.CountProviders,
		        BDS.CreatedBy,
		        BDS.CreatedDate,
		        BDS.CreatedSpId,
		        BDS.DataSetGuid,
		        BDS.DataSetID,
		        BDS.DefaultIhdsProviderID,
		        BDS.EngineGuid,
		        BDO.OwnerGuid,
		        BDS.OwnerID,
		        BDS.SourceGuid
		FROM	Batch.DataSets AS BDS WITH(NOLOCK)
				INNER JOIN Batch.DataOwners AS BDO WITH(NOLOCK)
						ON BDS.OwnerID = BDO.OwnerID
				CROSS APPLY (SELECT TOP 1 t.DataSetID FROM Member.Members AS t WITH(NOLOCK) WHERE t.DataSetID = BDS.DataSetID) AS MM
		WHERE	((@DataSetGuid IS NULL) OR (BDS.DataSetGuid = @DataSetGuid)) AND
				((@DataSetID IS NULL) OR (BDS.DataSetID = @DataSetID)) AND
				((@DataSetSourceGuid IS NULL) OR (BDS.SourceGuid = @DataSetSourceGuid)) AND
				((@OwnerGuid IS NULL) OR (BDO.OwnerGuid = @OwnerGuid)) AND
				((@OwnerID IS NULL) OR (BDO.OwnerID = @OwnerID));
								
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
GRANT EXECUTE ON  [Cloud].[GetDataSets] TO [Controller]
GO
GRANT VIEW DEFINITION ON  [Cloud].[GetDataSets] TO [db_executer]
GO
GRANT EXECUTE ON  [Cloud].[GetDataSets] TO [db_executer]
GO
GRANT EXECUTE ON  [Cloud].[GetDataSets] TO [Processor]
GO
GRANT EXECUTE ON  [Cloud].[GetDataSets] TO [Submitter]
GO
