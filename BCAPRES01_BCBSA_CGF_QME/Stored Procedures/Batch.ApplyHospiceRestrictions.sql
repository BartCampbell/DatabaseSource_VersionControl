SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 10/12/2016
-- Description:	Removes members from the eligible population of measures that do not allow hospice members.  
-- =============================================
CREATE PROCEDURE [Batch].[ApplyHospiceRestrictions]
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
	
	BEGIN TRY;
		
		SET @LogBeginTime = GETDATE();
		SET @LogObjectName = 'ApplyHospiceRestrictions'; 
		SET @LogObjectSchema = 'Batch'; 
		
		BEGIN TRY;
				
			IF @BatchID IS NULL
				RAISERROR(' - Apply hospice restrictions for batch failed!  No batch was specified.', 16, 1);
				
			DECLARE @CountRecords int;
			
			SELECT	@BeginInitSeedDate = DR.BeginInitSeedDate,
					@DataRunID = DR.DataRunID,
					@DataSetID = DS.DataSetID,
					@EndInitSeedDate = DR.EndInitSeedDate,
					@IsLogged = DR.IsLogged,
					@MeasureSetID = DR.MeasureSetID,
					@OwnerID = DS.OwnerID,
					@SeedDate = DR.SeedDate
			FROM	Batch.[Batches] AS B 
					INNER JOIN Batch.DataRuns AS DR
							ON B.DataRunID = DR.DataRunID
					INNER JOIN Batch.DataSets AS DS 
							ON B.DataSetID = DS.DataSetID 
			WHERE	(B.BatchID = @BatchID);
			
			DECLARE @ClaimAttribHospice int;
			SELECT @ClaimAttribHospice = ClaimAttribID FROM Claim.Attributes WHERE Abbrev = 'HSP';

			DECLARE @BitBenefitHospice bigint;
			SELECT @BitBenefitHospice = BitValue FROM Product.Benefits WHERE Abbrev = 'Hosp';

			SELECT DISTINCT
					PCA.DSMemberID
			INTO	#HospiceMembers
			FROM	Proxy.ClaimAttributes AS PCA
					INNER JOIN Proxy.ClaimLines AS PCL
							ON PCL.BatchID = PCA.BatchID AND
								PCL.DataRunID = PCA.DataRunID AND
								PCL.DSClaimLineID = PCA.DSClaimLineID AND
								PCL.DSMemberID = PCA.DSMemberID
			WHERE	(PCA.ClaimAttribID = @ClaimAttribHospice) AND
					(
						(	
							(PCL.EndDate IS NULL) AND
							(PCL.BeginDate BETWEEN @BeginInitSeedDate AND @EndInitSeedDate)
						) OR
						(	
							(PCL.EndDate BETWEEN @BeginInitSeedDate AND @EndInitSeedDate)
						)
					)
			UNION	
			SELECT DISTINCT
					DSMemberID
			FROM	Proxy.Enrollment AS PN
			WHERE	(PN.BitBenefits & @BitBenefitHospice > 0) AND
					(
						(PN.BeginDate BETWEEN @BeginInitSeedDate AND @EndInitSeedDate) OR
						(PN.EndDate BETWEEN @BeginInitSeedDate AND @EndInitSeedDate) OR
						(
							(PN.BeginDate < @BeginInitSeedDate) AND
							(PN.EndDate > @EndInitSeedDate)
						)
					);

			CREATE UNIQUE CLUSTERED INDEX IX_#HospiceMembers ON #HospiceMembers (DSMemberID);

			UPDATE	RMD
			SET		[Days] = CASE WHEN RMD.[Days] IS NOT NULL THEN 0 END,
					IsDenominator = CASE WHEN RMD.IsDenominator IS NOT NULL THEN 0 END,
					IsExclusion = CASE WHEN RMD.IsExclusion IS NOT NULL THEN 0 END,
					IsHospice = 1,
					IsNumerator = CASE WHEN RMD.IsNumerator IS NOT NULL THEN 0 END,
					IsNumeratorAdmin = CASE WHEN RMD.IsNumeratorAdmin IS NOT NULL THEN 0 END,
					IsNumeratorMedRcd = CASE WHEN RMD.IsNumeratorMedRcd IS NOT NULL THEN 0 END,
					Qty = CASE WHEN RMD.Qty IS NOT NULL THEN 0 END,
					Qty2 = CASE WHEN RMD.Qty2 IS NOT NULL THEN 0 END,
					Qty3 = CASE WHEN RMD.Qty3 IS NOT NULL THEN 0 END,
					Qty4 = CASE WHEN RMD.Qty4 IS NOT NULL THEN 0 END
			FROM	Result.MeasureDetail AS RMD
					INNER JOIN Measure.Measures AS MM
							ON MM.MeasureID = RMD.MeasureID AND
								MM.AllowHospice = 0
					INNER JOIN #HospiceMembers AS t
							ON t.DSMemberID = RMD.DSMemberID
			WHERE	RMD.BatchID = @BatchID AND
					RMD.DataRunID = @DataRunID AND
					RMD.DataSetID = @DataSetID;

			UPDATE RMMD
			SET		CountMonths = 0
			FROM	Result.MemberMonthDetail AS RMMD
					INNER JOIN #HospiceMembers AS t
							ON t.DSMemberID = RMMD.DSMemberID
			WHERE	RMMD.BatchID = @BatchID AND
					RMMD.DataRunID = @DataRunID AND
					RMMD.DataSetID = @DataSetID;

			SET @CountRecords = ISNULL(@CountRecords, 0) + @@ROWCOUNT;
			
			SET @LogDescr = ' - Apply hospice restrictions for BATCH ' + ISNULL(CAST(@BatchID AS varchar), '?') + ' succeeded.'; 
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
			SET @LogDescr = ' - Apply hospice restrictions for BATCH ' + ISNULL(CAST(@BatchID AS varchar), '?') + ' failed!'; --{FAILURE LOG DESCRIPTION HERE}
			
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
