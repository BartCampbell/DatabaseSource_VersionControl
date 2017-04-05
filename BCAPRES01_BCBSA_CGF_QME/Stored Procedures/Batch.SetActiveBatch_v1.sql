SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 1/26/2011
-- Description:	Sets (loads) the specified batch in the Temp schema tables. (v1)
-- =============================================
CREATE PROCEDURE [Batch].[SetActiveBatch_v1]
(
	@BatchID int
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

	DECLARE @BeginInitSeedDate datetime;
	DECLARE @DataRunID int;
	DECLARE @DataSetID int;
	DECLARE @EndInitSeedDate datetime;
	DECLARE @IsLogged bit;
	DECLARE @MeasureSetID int;
	DECLARE @OwnerID int;
	DECLARE @SeedDate datetime;
	DECLARE @SpId int;
	
	BEGIN TRY;
		
		SET @LogBeginTime = GETDATE();
		SET @LogObjectName = 'SetActiveBatch'; 
		SET @LogObjectSchema = 'Batch'; 
		
		BEGIN TRY;
				
			IF @BatchID IS NULL
				RAISERROR(' - Setting of active batch failed!  No batch was specified.', 16, 1);
				
			DECLARE @CountRecords int;
			
			SELECT	@BeginInitSeedDate = DR.BeginInitSeedDate,
					@DataRunID = DR.DataRunID,
					@DataSetID = DS.DataSetID,
					@EndInitSeedDate = DR.EndInitSeedDate,
					@IsLogged = DR.IsLogged,
					@MeasureSetID = DR.MeasureSetID,
					@OwnerID = DS.OwnerID,
					@SeedDate = DR.SeedDate,
					@SpId = DR.CreatedSpId
			FROM	Batch.[Batches] AS B 
					INNER JOIN Batch.DataRuns AS DR
							ON B.DataRunID = DR.DataRunID
					INNER JOIN Batch.DataSets AS DS 
							ON B.DataSetID = DS.DataSetID 
			WHERE	(B.BatchID = @BatchID);		
			
			--Purge Temporary Working Tables
			DELETE FROM Proxy.ClaimAttributes;
			DELETE FROM Proxy.ClaimCodes;
			DELETE FROM Proxy.ClaimLines;
			DELETE FROM Proxy.Claims;
			DELETE FROM Proxy.Enrollment;
			DELETE FROM Proxy.EnrollmentBenefits;
			DELETE FROM Proxy.Entities;
			DELETE FROM Proxy.EntityBase;
			DELETE FROM Proxy.EntityEnrollment;
			DELETE FROM Proxy.EventBase;
			DELETE FROM Proxy.[Events];
			DELETE FROM Proxy.MemberAttributes;
			DELETE FROM Proxy.Members;
			DELETE FROM Proxy.Providers;
			DELETE FROM Proxy.ProviderSpecialties;
			
			IF NOT EXISTS (SELECT TOP 1 1 FROM Internal.ClaimAttributes)
				TRUNCATE TABLE Internal.ClaimAttributes;
			
			IF NOT EXISTS (SELECT TOP 1 1 FROM Internal.ClaimCodes)
				TRUNCATE TABLE Internal.ClaimCodes;
			
			IF NOT EXISTS (SELECT TOP 1 1 FROM Internal.ClaimLines)
				TRUNCATE TABLE Internal.ClaimLines;
			
			IF NOT EXISTS (SELECT TOP 1 1 FROM Internal.Claims)
				TRUNCATE TABLE Internal.Claims;
			
			IF NOT EXISTS (SELECT TOP 1 1 FROM Internal.Enrollment)
				TRUNCATE TABLE Internal.Enrollment;
				
			IF NOT EXISTS (SELECT TOP 1 1 FROM Internal.EnrollmentBenefits)
				TRUNCATE TABLE Internal.EnrollmentBenefits;
				
			IF NOT EXISTS (SELECT TOP 1 1 FROM Internal.Entities)
				TRUNCATE TABLE Internal.Entities;
				
			IF NOT EXISTS (SELECT TOP 1 1 FROM Internal.EntityBase)
				TRUNCATE TABLE Internal.EntityBase;
				
			IF NOT EXISTS (SELECT TOP 1 1 FROM Internal.EntityEnrollment)
				TRUNCATE TABLE Internal.EntityEnrollment;
				
			IF NOT EXISTS (SELECT TOP 1 1 FROM Internal.EventBase)
				TRUNCATE TABLE Internal.EventBase;
				
			IF NOT EXISTS (SELECT TOP 1 1 FROM Internal.[Events])
				TRUNCATE TABLE Internal.[Events];
				
			IF NOT EXISTS (SELECT TOP 1 1 FROM Internal.MemberAttributes)
				TRUNCATE TABLE Internal.MemberAttributes;
				
			IF NOT EXISTS (SELECT TOP 1 1 FROM Internal.Members)
				TRUNCATE TABLE Internal.Members;
			
			IF NOT EXISTS (SELECT TOP 1 1 FROM Internal.Providers)
				TRUNCATE TABLE Internal.Providers;
			
			IF NOT EXISTS (SELECT TOP 1 1 FROM Internal.ProviderSpecialties)
				TRUNCATE TABLE Internal.ProviderSpecialties;

			--Copy Temporary Members
			INSERT INTO Proxy.Members
					(BatchID,
					DataRunID,
					DataSetID,
					DOB,
					DSMemberID,
					Gender,
					IhdsMemberID,
					MemberID)
			SELECT	@BatchID,
					@DataRunID,
					DataSetID,
					DOB,
					DSMemberID,
					Gender,
					IhdsMemberID,
					MemberID	
			FROM	Member.Members 
			WHERE	(DSMemberID IN (SELECT DISTINCT DSMemberID FROM Batch.BatchItems WHERE BatchID = @BatchID));
			
			SET @CountRecords = ISNULL(@CountRecords, 0) + @@ROWCOUNT;
			
			
			--Copy Temporary Member Attributes
			INSERT INTO Proxy.MemberAttributes
					(BatchID,
					DataRunID,
					DataSetID,
					DSMbrAttribID,
					DSMemberID,
					MbrAttribID)
			SELECT	@BatchID,
					@DataRunID,
					DataSetID,
					DSMbrAttribID,
					DSMemberID,
					MbrAttribID
			FROM	Member.MemberAttributes 
			WHERE	(DSMemberID IN (SELECT DISTINCT DSMemberID FROM Proxy.Members));
			
			SET @CountRecords = ISNULL(@CountRecords, 0) + @@ROWCOUNT;
			
			
			--Copy Temporary Enrollment
			INSERT INTO Proxy.Enrollment
					(BatchID,
					BeginDate,
					DataRunID,
					DataSetID,
					DSMemberID,
					EligibilityID,
					EndDate,
					EnrollGroupID,
					EnrollItemID,
					IsEmployee)
			SELECT	@BatchID,
					BeginDate,
					@DataRunID,
					DataSetID,
					DSMemberID,
					EligibilityID,
					EndDate,
					EnrollGroupID,
					EnrollItemID,
					IsEmployee
			FROM	Member.Enrollment 
			WHERE	(DSMemberID IN (SELECT DISTINCT DSMemberID FROM Proxy.Members));
			
			SET @CountRecords = ISNULL(@CountRecords, 0) + @@ROWCOUNT;
			
			
			--Copy Temporary Enrollment Benefits
			INSERT INTO Proxy.EnrollmentBenefits
			        (BatchID,
			        BenefitID,
			        DataRunID,
			        DataSetID,
			        EnrollItemID)
			SELECT	@BatchID,
					BenefitID,
					@DataRunID,
			        DataSetID,
			        EnrollItemID 
			FROM	Member.EnrollmentBenefits 
			WHERE	(EnrollItemID IN (SELECT DISTINCT EnrollItemID FROM Proxy.Enrollment));
			
			SET @CountRecords = ISNULL(@CountRecords, 0) + @@ROWCOUNT;
			
			
			--Copy Temporary Claim Lines
			INSERT INTO Proxy.ClaimLines
					(BatchID,
					BeginDate,
					ClaimID,
					ClaimLineItemID,
					ClaimNum,
					ClaimTypeID,
					CPT,
					CPT2,
					CPTMod1,
					CPTMod2,
					CPTMod3,
					DataRunID,
					DataSetID,
					[Days],
					DischargeStatus,
					DSClaimID,
					DSClaimLineID,
					DSMemberID,
					DSProviderID,
					EndDate,
					HCPCS,
					IsPaid,
					IsPositive,
					LabValue,
					LOINC,
					NDC,
					POS,
					Qty,
					Rev,
					ServDate,
					TOB)
			SELECT	@BatchID,
					BeginDate,
					ClaimID,
					ClaimLineItemID,
					ClaimNum,
					ClaimTypeID,
					CPT,
					CPT2,
					CPTMod1,
					CPTMod2,
					CPTMod3,
					@DataRunID,
					DataSetID,
					[Days],
					DischargeStatus,
					DSClaimID,
					DSClaimLineID,
					DSMemberID,
					DSProviderID,
					EndDate,
					HCPCS,
					IsPaid,
					IsPositive,
					LabValue,
					LOINC,
					NDC,
					POS,
					Qty,
					Rev,
					ServDate,
					TOB 
			FROM	Claim.ClaimLines 
			WHERE	(DSMemberID IN (SELECT DISTINCT DSMemberID FROM Proxy.Members)) AND
					(HasValidCodes = 1);
			
			SET @CountRecords = ISNULL(@CountRecords, 0) + @@ROWCOUNT;
			
			
			--Copy Temporary Claims
			INSERT INTO Proxy.Claims
					(BatchID,
					BeginDate,
					ClaimTypeID,
					DataRunID,
					DataSetID,
					DSClaimID,
					DSMemberID,
					DSProviderID,
					EndDate,
					LOS,
					POS,
					ServDate)
			SELECT	@BatchID,
					BeginDate,
					ClaimTypeID,
					@DataRunID,
					DataSetID,
					DSClaimID,
					DSMemberID,
					DSProviderID,
					EndDate,
					LOS,
					POS,
					ServDate
			FROM	Claim.Claims	
			WHERE	(DSClaimID IN (SELECT DISTINCT DSClaimID FROM Proxy.ClaimLines));
			
			SET @CountRecords = ISNULL(@CountRecords, 0) + @@ROWCOUNT;
			
			
			--Copy Temporary Claim Attributes
			INSERT INTO Proxy.ClaimAttributes
					(BatchID,
					ClaimAttribID,
					DataRunID,
					DataSetID,
					DSClaimAttribID,
					DSClaimLineID,
					DSMemberID)
			SELECT	@BatchID,
					ClaimAttribID,
					@DataRunID,
					DataSetID,
					DSClaimAttribID,
					DSClaimLineID,
					DSMemberID 
			FROM	Claim.ClaimAttributes
			WHERE	(DSClaimLineID IN (SELECT DISTINCT DSClaimLineID FROM Proxy.ClaimLines));
			
			SET @CountRecords = ISNULL(@CountRecords, 0) + @@ROWCOUNT;
			
			
			--Copy Temporary Claim Codes
			INSERT INTO Proxy.ClaimCodes
					(BatchID,
					ClaimTypeID,
					Code,
					CodeID,
					CodeTypeID,
					DataRunID,
					DataSetID,
					DSClaimCodeID,
					DSClaimID,
					DSClaimLineID,
					DSMemberID,
					IsPrimary)
			SELECT	@BatchID,
					ClaimTypeID,
					Code,
					CodeID,
					CodeTypeID,
					@DataRunID,
					DataSetID,
					DSClaimCodeID,
					DSClaimID,
					DSClaimLineID,
					DSMemberID,
					IsPrimary
			FROM	Claim.ClaimCodes 
			WHERE	(DSClaimLineID IN (SELECT DISTINCT DSClaimLineID FROM Proxy.ClaimLines)) AND
					(CodeID IS NOT NULL);
			
			SET @CountRecords = ISNULL(@CountRecords, 0) + @@ROWCOUNT;
			
			
			--Copy Temporary Providers
			INSERT INTO Proxy.Providers
					(BatchID,
					DataRunID,
					DataSetID,
					DSProviderID,
					IhdsProviderID,
					ProviderID)
			SELECT	@BatchID,
					@DataRunID,
					DataSetID,
					DSProviderID,
					IhdsProviderID,
					ProviderID 
			FROM	Provider.Providers 
			WHERE	(DSProviderID IN (SELECT DISTINCT DSProviderID FROM Proxy.ClaimLines));
			
			SET @CountRecords = ISNULL(@CountRecords, 0) + @@ROWCOUNT;
			
			
			--Copy Temporary Provider Specialties
			INSERT INTO Proxy.ProviderSpecialties
			        (BatchID,
					DataRunID,
					DataSetID,
			        DSProviderID,
			        SpecialtyID)
			SELECT	@BatchID,
					@DataRunID,
					DataSetID,
			        DSProviderID,
			        SpecialtyID 
			FROM	Provider.ProviderSpecialties
			WHERE	(DSProviderID IN (SELECT DISTINCT DSProviderID FROM Proxy.Providers));
			
			SET @CountRecords = ISNULL(@CountRecords, 0) + @@ROWCOUNT;


			SET @LogDescr = ' - Setting of active batch to BATCH ' + ISNULL(CAST(@BatchID AS varchar), '?') + ' succeeded.'; 
			SET @LogEndTime = GETDATE();
			
			EXEC @Result = Log.RecordEntry	@BatchID = @BatchID,
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
			SET @LogDescr = ' - Setting of active batch to BATCH ' + ISNULL(CAST(@BatchID AS varchar), '?') + ' failed!'; --{FAILURE LOG DESCRIPTION HERE}
			
			EXEC @Result = Log.RecordEntry	@BatchID = @BatchID,
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
GRANT EXECUTE ON  [Batch].[SetActiveBatch_v1] TO [Processor]
GO
