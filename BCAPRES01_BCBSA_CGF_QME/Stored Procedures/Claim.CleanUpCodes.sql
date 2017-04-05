SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 1/24/2011
-- Description:	Cleans the code key, reordering Codes and Code Yypes with the matching CodeIDs.
-- =============================================
CREATE PROCEDURE [Claim].[CleanUpCodes]
(
	@DataSetID int
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
	
	DECLARE @Result int;
	
		BEGIN TRY;
		
		SET @LogBeginTime = GETDATE();
		SET @LogObjectName = 'CleanUpCodes'; 
		SET @LogObjectSchema = 'Claim'; 
		
		--Added to determine @LogEntryXrefGuid value---------------------------
		SELECT @LogEntryXrefGuid = [Log].GetEntryXrefGuid (@LogObjectSchema, @LogObjectName);
		-----------------------------------------------------------------------
		
		BEGIN TRY;
				
			DECLARE @CountRecords int;
			--BEGIN TRANSACTION T1;
		
			--1) Clean and Reorder Codes
			SELECT	Code, CodeTypeID
			INTO	#Codes
			FROM	Claim.Codes
			
			TRUNCATE TABLE Claim.Codes
			
			INSERT INTO	Claim.Codes
					(Code, CodeTypeID)
			SELECT	Code, CodeTypeID
			FROM	#Codes
			ORDER BY CodeTypeID, Code	
			
			--2) Update ClaimCodes
			UPDATE	CC 
			SET		CodeID = C.CodeID
			FROM	Claim.ClaimCodes AS CC
					LEFT OUTER JOIN Claim.Codes AS C
							ON CC.Code = C.Code AND
								CC.CodeTypeID = C.CodeTypeID
			
			SET @CountRecords = ISNULL(@CountRecords, 0) + @@ROWCOUNT;

			--3) Update EventCriteriaCodes
			UPDATE	ECC --Events
			SET		CodeID = C.CodeID
			FROM	Measure.EventCriteriaCodes AS ECC
					LEFT OUTER JOIN Claim.Codes AS C
							ON ECC.Code = C.Code AND
								ECC.CodeTypeID = C.CodeTypeID

			SET @CountRecords = ISNULL(@CountRecords, 0) + @@ROWCOUNT;

			--4) Update Ncqa Schema Tables
			--4a) Update PCR_ClinicalConditions
			UPDATE	t 
			SET		CodeID = C.CodeID
			FROM	NCQA.PCR_ClinicalConditions AS t
					LEFT OUTER JOIN Claim.Codes AS C
							ON t.Code = C.Code AND
								t.CodeTypeID = C.CodeTypeID
			WHERE	((t.CodeID IS NULL) OR (t.CodeID <> C.CodeID));
			
			SET @CountRecords = ISNULL(@CountRecords, 0) + @@ROWCOUNT;

			--4b) Update PCR_HCC_Codes
			UPDATE	t 
			SET		CodeID = C.CodeID
			FROM	NCQA.PCR_HCC_Codes AS t
					LEFT OUTER JOIN Claim.Codes AS C
							ON t.Code = C.Code AND
								t.CodeTypeID = C.CodeTypeID
			WHERE	((t.CodeID IS NULL) OR (t.CodeID <> C.CodeID));
			
			SET @CountRecords = ISNULL(@CountRecords, 0) + @@ROWCOUNT;
			
			--4c) Update RRU_ADSCCodes
			UPDATE	t 
			SET		CodeID = C.CodeID
			FROM	NCQA.RRU_ADSCCodes AS t
					LEFT OUTER JOIN Claim.Codes AS C
							ON t.Code = C.Code AND
								t.CodeTypeID = C.CodeTypeID
			WHERE	((t.CodeID IS NULL) OR (t.CodeID <> C.CodeID));
			
			SET @CountRecords = ISNULL(@CountRecords, 0) + @@ROWCOUNT;

			--4d) Update RRU_PriceCategoryCodes
			UPDATE	t 
			SET		CodeID = C.CodeID
			FROM	NCQA.RRU_PriceCategoryCodes AS t
					LEFT OUTER JOIN Claim.Codes AS C
							ON t.Code = C.Code AND
								t.CodeTypeID = C.CodeTypeID
			WHERE	((t.CodeID IS NULL) OR (t.CodeID <> C.CodeID));
			
			SET @CountRecords = ISNULL(@CountRecords, 0) + @@ROWCOUNT;

			--4e) Update CodeIDs in RRU_MajorSurgery
			UPDATE	t 
			SET		CodeID = C.CodeID
			FROM	NCQA.RRU_MajorSurgery AS t
					LEFT OUTER JOIN Claim.Codes AS C
							ON t.Code = C.Code AND
								t.CodeTypeID = C.CodeTypeID
			WHERE	((t.CodeID IS NULL) OR (t.CodeID <> C.CodeID));

			--Mark Claim Lines with Valid Codes
			SELECT DISTINCT	DSClaimLineID 
			INTO	#ClaimLinesWithValidCodes
			FROM	Claim.ClaimCodes 
			WHERE	(DataSetID = @DataSetID) AND
					(CodeID IS NOT NULL)
					
			UPDATE	CL
			SET		HasValidCodes = CASE WHEN t.DSClaimLineID IS NOT NULL THEN 1 ELSE 0 END
			FROM	Claim.ClaimLines AS CL
					LEFT OUTER JOIN #ClaimLinesWithValidCodes AS t
							ON CL.DSClaimLineID = t.DSClaimLineID
			WHERE	(DataSetID = @DataSetID)


			SET @LogDescr = 'Codes clean up completed succcessfully.'; 
			SET @LogEndTime = GETDATE();
			
			EXEC @Result = Log.RecordEntry	@BeginTime = @LogBeginTime,
												@CountRecords = @CountRecords,
												@DataSetID = @DataSetID,
												@Descr = @LogDescr,
												@EndTime = @LogEndTime, 
												@EntryXrefGuid = @LogEntryXrefGuid, 
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
			SET @LogDescr = 'Codes clean up failed!'; 
			
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
GRANT EXECUTE ON  [Claim].[CleanUpCodes] TO [Processor]
GO
