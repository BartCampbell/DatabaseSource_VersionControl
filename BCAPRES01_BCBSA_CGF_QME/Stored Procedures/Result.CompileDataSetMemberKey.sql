SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- =============================================
-- Author:		Kriz, Mike
-- Create date: 5/3/2011
-- Description:	Compiles the member reference key values for the specified Data Run.
-- =============================================
CREATE PROCEDURE [Result].[CompileDataSetMemberKey]
(
	@DataRunID int
)
AS
BEGIN
	SET NOCOUNT ON;
		
	DECLARE @LogBeginTime datetime;
	DECLARE @LogDescr varchar(256);
	DECLARE @LogEndTime datetime;
	DECLARE @LogObjectName nvarchar(128);
	DECLARE @LogObjectSchema nvarchar(128);
	
	DECLARE @Result int;

	DECLARE @BatchID int;
	DECLARE @DataSetID int;
	DECLARE @MbrMonthID int;
	DECLARE @MeasureSetID int;
	DECLARE @OwnerID int;
	DECLARE @SeedDate datetime;
	
	BEGIN TRY;
		
		SET @LogBeginTime = GETDATE();
		SET @LogObjectName = 'CompileDataSetMemberKey'; 
		SET @LogObjectSchema = 'Result'; 
		
		BEGIN TRY;				
			DECLARE @CountRecords int;
			
			SELECT TOP 1	
					--@DataRunID = B.DataRunID,
					@DataSetID = DS.DataSetID,
					@MbrMonthID = DR.MbrMonthID,
					@MeasureSetID = DR.MeasureSetID,
					@OwnerID = DS.OwnerID,
					@SeedDate = DR.SeedDate
			FROM	Batch.[Batches] AS B 
					INNER JOIN Batch.DataSets AS DS 
							ON B.DataSetID = DS.DataSetID 
					INNER JOIN Batch.DataRuns AS DR
							ON B.DataRunID = DR.DataRunID
			WHERE	(DR.DataRunID = @DataRunID) AND
					((@BatchID IS NULL) OR (B.BatchID = @BatchID));
			
			---------------------------------------------------------------------------
			
			DECLARE @AllowedCharsForNameFirst smallint;		
			DECLARE @AllowedCharsForNameLast smallint;
			DECLARE @ObscureCharacter char(1);
							
			SET @AllowedCharsForNameFirst = 1;
			SET @AllowedCharsForNameLast = 1;
			SET @ObscureCharacter = '#';

			DECLARE @LengthOfDSMemberID int;
			DECLARE @LengthOfIhdsMemberID int;

			SELECT @LengthOfDSMemberID = MAX(LEN(CAST(DSMemberID AS varchar(16)))) FROM Member.Members WHERE DataSetID = @DataSetID;
			SELECT @LengthOfIhdsMemberID = MAX(LEN(CAST(IhdsMemberID AS varchar(16)))) FROM Member.Members WHERE DataSetID = @DataSetID;

			DELETE FROM Result.DataSetMemberKey WHERE ((DataRunID = @DataRunID) AND (DataSetID = @DataSetID));

			IF NOT EXISTS(SELECT TOP 1 1 FROM Result.DataSetMemberKey)
				TRUNCATE TABLE Result.DataSetMemberKey;

			INSERT INTO Result.DataSetMemberKey
					(CustomerMemberID,
					DataRunID,
					DataSetID,
					DisplayID,
					DOB,
					DSMemberID,
					Gender,
					IhdsMemberID,
					NameDisplay,
					NameFirst,
					NameLast,
					NameObscure,
					SsnDisplay,
					SsnObscure)
			SELECT	MM.CustomerMemberID, 
					@DataRunID AS DataRunID,
					@DataSetID AS DataSetID,
					REPLICATE('0', @LengthOfIhdsMemberID-LEN(CAST(MM.IhdsMemberID AS varchar(12)))) + CAST(MM.IhdsMemberID AS varchar(12)) + '-' + 
						CAST(CAST(@DataSetID AS varchar(6)) + '-' +
						REPLICATE('0', @LengthOfDSMemberID-LEN(CAST(MM.DSMemberID AS varchar(12)))) + CAST(MM.DSMemberID AS varchar(12)) AS varchar(32)) AS DisplayID,
					MM.DOB, MM.DSMemberID, MM.Gender, MM.IhdsMemberID,
					RTRIM(MM.NameLast) + ', ' + RTRIM(MM.NameFirst) AS NameDisplay, 
					RTRIM(MM.NameFirst) AS NameFirst, RTRIM(MM.NameLast) AS NameLast,
					CASE 
						WHEN LEN(MM.NameLast) < @AllowedCharsForNameLast 
						THEN RTRIM(MM.NameLast)
						ELSE LEFT(MM.NameLast, @AllowedCharsForNameLast) + REPLICATE(@ObscureCharacter, LEN(MM.NameLast) - @AllowedCharsForNameLast)
						END + ', ' +
					CASE 
						WHEN LEN(MM.NameFirst) < @AllowedCharsForNameFirst 
						THEN RTRIM(MM.NameFirst)
						ELSE LEFT(MM.NameFirst, @AllowedCharsForNameFirst) + REPLICATE(@ObscureCharacter, LEN(MM.NameFirst) - @AllowedCharsForNameFirst)
						END AS NameObscure, 
					REPLICATE(@ObscureCharacter, 3) + '-' + REPLICATE(@ObscureCharacter, 2) + '-' + 
						CASE LEN(M.SSN) WHEN 9 THEN RIGHT(M.SSN, 4) WHEN 4 THEN M.SSN END AS SsnDisplay,
					'###-##-####' AS SsnObscure
			FROM	dbo.Member AS M
					INNER JOIN Member.Members AS MM
							ON --M.MemberID = MM.MemberID AND
								M.ihds_member_id = MM.IhdsMemberID AND
								MM.CustomerMemberID = M.CustomerMemberID
			WHERE	(MM.DataSetID = @DataSetID)
			ORDER BY NameDisplay;

			SET @CountRecords = ISNULL(@CountRecords, 0) + @@ROWCOUNT;
						
			SET @LogDescr = 'Compiling of member key values completed successfully.'; 
			SET @LogEndTime = GETDATE();
			
			EXEC @Result = [Log].RecordEntry	@BatchID = @BatchID,
												@BeginTime = @LogBeginTime,
												@CountRecords = @CountRecords,
												@DataRunID = @DataRunID,
												@DataSetID = @DataSetID,
												@Descr = @LogDescr,
												@EndTime = @LogEndTime, 
												@IsSuccess = 1,
												@SrcObjectName = @LogObjectName,
												@SrcObjectSchema = @LogObjectSchema;

			--COMMIT TRANSACTION T1;

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
			SET @LogDescr = 'Compiling of member key values failed!';
			
			EXEC @Result = [Log].RecordEntry	@BatchID = @BatchID,
												@BeginTime = @LogBeginTime,
												@CountRecords = -1, 
												@DataRunID = @DataRunID,
												@DataSetID = @DataSetID,
												@Descr = @LogDescr,
												@EndTime = @LogBeginTime,
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
		DECLARE @ErrMessage nvarchar(MAX);
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
GRANT EXECUTE ON  [Result].[CompileDataSetMemberKey] TO [Processor]
GO
