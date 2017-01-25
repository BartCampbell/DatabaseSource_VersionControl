SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 6/11/2012
-- Description:	Sets (loads) the specified batch in the Temp schema tables. (v2)
-- =============================================
CREATE PROCEDURE [Batch].[SetActiveBatch]
(
	@BatchID int
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
		
		--Added to determine @LogEntryXrefGuid value---------------------------
		SELECT @LogEntryXrefGuid = [Log].GetEntryXrefGuid (@LogObjectSchema, @LogObjectName);
		-----------------------------------------------------------------------
		
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
			EXEC Batch.PurgeInternalTables @BatchID = @BatchID, @ForcePurge = 1, @IgnoreMembers = 0;
			
			--Copy Temporary Members
			INSERT INTO Proxy.Members
					(BatchID,
					CustomerMemberID,
					DataRunID,
					DataSetID,
					DataSourceID,
					DOB,
					DSMemberID,
					Gender,
					IhdsMemberID,
					MemberID)
			SELECT	@BatchID,
					MM.CustomerMemberID,
					@DataRunID,
					MM.DataSetID,
					MM.DataSourceID,
					MM.DOB,
					MM.DSMemberID,
					MM.Gender,
					MM.IhdsMemberID,
					MM.MemberID	
			FROM	Member.Members AS MM
					INNER JOIN Batch.BatchMembers AS BBM
							ON MM.DSMemberID = BBM.DSMemberID
			WHERE	(BBM.BatchID = @BatchID) AND
					(MM.DataSetID = @DataSetID);
			
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
					MMA.DataSetID,
					MMA.DSMbrAttribID,
					MMA.DSMemberID,
					MMA.MbrAttribID
			FROM	Member.MemberAttributes AS MMA
					INNER JOIN Batch.BatchMembers AS BBM
							ON MMA.DSMemberID = BBM.DSMemberID
			WHERE	(BBM.BatchID = @BatchID) AND
					(MMA.DataSetID = @DataSetID);
			
			SET @CountRecords = ISNULL(@CountRecords, 0) + @@ROWCOUNT;
			
			
			--Copy Temporary Enrollment
			INSERT INTO Proxy.Enrollment
					(BatchID,
					BeginDate,
					BitBenefits,
					BitProductLines,
					DataRunID,
					DataSetID,
					DataSourceID,
					DSMemberID,
					EligibilityID,
					EndDate,
					EnrollGroupID,
					EnrollItemID,
					IsEmployee)
			SELECT	@BatchID,
					MNN.BeginDate,
					MNN.BitBenefits,
					MNN.BitProductLines,
					@DataRunID,
					MNN.DataSetID,
					MNN.DataSourceID,
					MNN.DSMemberID,
					MNN.EligibilityID,
					MNN.EndDate,
					MNN.EnrollGroupID,
					MNN.EnrollItemID,
					MNN.IsEmployee
			FROM	Member.Enrollment AS MNN 
					INNER JOIN Batch.BatchMembers AS BBM
							ON MNN.DSMemberID = BBM.DSMemberID
			WHERE	(BBM.BatchID = @BatchID) AND
					(MNN.DataSetID = @DataSetID);
			
			SET @CountRecords = ISNULL(@CountRecords, 0) + @@ROWCOUNT;
			
			
			--Copy Temporary Enrollment Benefits
			INSERT INTO Proxy.EnrollmentBenefits
			        (BatchID,
			        BenefitID,
			        DataRunID,
			        DataSetID,
			        EnrollItemID)
			SELECT	@BatchID,
					MNB.BenefitID,
					@DataRunID,
			        MNB.DataSetID,
			        MNB.EnrollItemID 
			FROM	Member.EnrollmentBenefits AS MNB
					INNER JOIN Proxy.Enrollment AS PN
							ON MNB.EnrollItemID = PN.EnrollItemID
			WHERE	(MNB.DataSetID = @DataSetID);
			
			SET @CountRecords = ISNULL(@CountRecords, 0) + @@ROWCOUNT;
			
			
			--Copy Temporary Claim Lines
			INSERT INTO Proxy.ClaimLines
					(BatchID,
					BeginDate,
					ClaimID,
					ClaimLineItemID,
					ClaimNum,
					ClaimSrcTypeID,
					ClaimTypeID,
					CPT,
					CPT2,
					CPTMod1,
					CPTMod2,
					CPTMod3,
					DataRunID,
					DataSetID,
					DataSourceID, 
					[Days],
					DaysPaid,
					DischargeStatus,
					DSClaimID,
					DSClaimLineID,
					DSMemberID,
					DSProviderID,
					EndDate,
					HCPCS,
					IsPaid,
					IsPositive,
					IsSupplemental,
					LabValue,
					LOINC,
					NDC,
					POS,
					Qty,
					QtyDispensed,
					Rev,
					ServDate,
					TOB)
			SELECT	@BatchID,
					CCL.BeginDate,
					CCL.ClaimID,
					CCL.ClaimLineItemID,
					CCL.ClaimNum,
					CCL.ClaimSrcTypeID,
					CCL.ClaimTypeID,
					CCL.CPT,
					CCL.CPT2,
					CCL.CPTMod1,
					CCL.CPTMod2,
					CCL.CPTMod3,
					@DataRunID,
					CCL.DataSetID,
					CCL.DataSourceID,
					CCL.[Days],
					CCL.DaysPaid,
					CCL.DischargeStatus,
					CCL.DSClaimID,
					CCL.DSClaimLineID,
					CCL.DSMemberID,
					CCL.DSProviderID,
					CCL.EndDate,
					CCL.HCPCS,
					CCL.IsPaid,
					CCL.IsPositive,
					CCL.IsSupplemental,
					CCL.LabValue,
					CCL.LOINC,
					CCL.NDC,
					CCL.POS,
					CCL.Qty,
					CCL.QtyDispensed,
					CCL.Rev,
					CCL.ServDate,
					CCL.TOB 
			FROM	Claim.ClaimLines AS CCL
					LEFT OUTER JOIN Provider.Providers AS PP
							ON PP.DSProviderID = CCL.DSProviderID AND
								PP.DataSetID = CCL.DataSetID
					INNER JOIN Batch.BatchMembers AS BBM
							ON CCL.DSMemberID = BBM.DSMemberID
			WHERE	(BBM.BatchID = @BatchID) AND
					(CCL.DataSetID = @DataSetID) AND
					(
						(CCL.HasValidCodes = 1) OR
						(PP.BitSpecialties > 0)
					);
			
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
					CC.BeginDate,
					CC.ClaimTypeID,
					@DataRunID,
					CC.DataSetID,
					CC.DSClaimID,
					CC.DSMemberID,
					CC.DSProviderID,
					CC.EndDate,
					CC.LOS,
					CC.POS,
					CC.ServDate
			FROM	Claim.Claims AS CC
					INNER JOIN Batch.BatchMembers AS BBM
							ON CC.DSMemberID = BBM.DSMemberID
			WHERE	(CC.DataSetID = @DataSetID);
			
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
					CCA.ClaimAttribID,
					@DataRunID,
					CCA.DataSetID,
					CCA.DSClaimAttribID,
					CCA.DSClaimLineID,
					CCA.DSMemberID 
			FROM	Claim.ClaimAttributes AS CCA
					INNER JOIN Proxy.ClaimLines AS PCL
							ON CCA.DSClaimLineID = PCL.DSClaimLineID
			WHERE	(CCA.DataSetID = @DataSetID);
			
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
					CCC.ClaimTypeID,
					CCC.Code,
					CCC.CodeID,
					CCC.CodeTypeID,
					@DataRunID,
					CCC.DataSetID,
					CCC.DSClaimCodeID,
					CCC.DSClaimID,
					CCC.DSClaimLineID,
					CCC.DSMemberID,
					CCC.IsPrimary
			FROM	Claim.ClaimCodes AS CCC
					INNER JOIN Proxy.ClaimLines AS PLC
							ON CCC.DSClaimLineID = PLC.DSClaimLineID
			WHERE	(CCC.DataSetID = @DataSetID) AND
					(CodeID IS NOT NULL);
			
			SET @CountRecords = ISNULL(@CountRecords, 0) + @@ROWCOUNT;
			
			
			--Identify Providers
			SELECT DISTINCT
					PCL.DSProviderID
			INTO	#Providers
			FROM	Proxy.ClaimLines AS PCL;
			
			CREATE UNIQUE CLUSTERED INDEX IX_#Providers ON #Providers (DSProviderID);
			
						
			--Copy Temporary Providers
			INSERT INTO Proxy.Providers
					(BatchID,
					BitSpecialties,
					DataRunID,
					DataSetID,
					DataSourceID,
					DSProviderID,
					IhdsProviderID,
					ProviderID)
			SELECT	@BatchID,
					PP.BitSpecialties,
					@DataRunID,
					PP.DataSetID,
					PP.DataSourceID,
					PP.DSProviderID,
					PP.IhdsProviderID,
					PP.ProviderID 
			FROM	Provider.Providers AS PP
					INNER JOIN #Providers AS t
							ON PP.DSProviderID = t.DSProviderID
			WHERE	(PP.DataSetID = @DataSetID);
			
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
					PPS.DataSetID,
			        PPS.DSProviderID,
			        PPS.SpecialtyID 
			FROM	Provider.ProviderSpecialties AS PPS
					INNER JOIN #Providers AS t
							ON PPS.DSProviderID = t.DSProviderID
			WHERE	(PPS.DataSetID = @DataSetID);
			
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
			SET @LogDescr = ' - Setting of active batch to BATCH ' + ISNULL(CAST(@BatchID AS varchar), '?') + ' failed!'; --{FAILURE LOG DESCRIPTION HERE}
			
			EXEC @Result = Log.RecordEntry	@BatchID = @BatchID,
												@BeginTime = @LogBeginTime,
												@CountRecords = -1, 
												@DataRunID = @DataRunID,
												@DataSetID = @DataSetID,
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
GRANT EXECUTE ON  [Batch].[SetActiveBatch] TO [Processor]
GO
