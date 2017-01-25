SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 3/24/2016
-- Description:	Validates the record counts of the specified data run.
-- =============================================
CREATE PROCEDURE [Result].[ValidateRecordCounts]
(
	@DataRunID int
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

	DECLARE @BatchID int;
	DECLARE @DataSetID int;
	DECLARE @MbrMonthID int;
	DECLARE @MeasureSetID int;
	DECLARE @OwnerID int;
	DECLARE @SeedDate datetime;
	
	BEGIN TRY;
		
		SET @LogBeginTime = GETDATE();
		SET @LogObjectName = 'ValidateRecordCounts'; 
		SET @LogObjectSchema = 'Result'; 
		
		--Added to determine @LogEntryXrefGuid value---------------------------
		SELECT @LogEntryXrefGuid = [Log].GetEntryXrefGuid (@LogObjectSchema, @LogObjectName);
		-----------------------------------------------------------------------
		
		BEGIN TRY;				
			SELECT TOP 1	
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
			
			EXEC @Result = Cloud.VerifyBatchFileObjectRecordCounts @BatchID = @BatchID, @DataRunID = @DataRunID;

			IF OBJECT_ID('tempdb..#ClaimLines') IS NOT NULL
				DROP TABLE #ClaimLines;

			SELECT	BDR.DataRunID, CCL.DSClaimLineID, CCL.DSMemberID
			INTO	#ClaimLines
			FROM	Batch.DataRuns AS BDR WITH(NOLOCK)
					INNER JOIN Claim.ClaimLines AS CCL WITH(NOLOCK)
							ON CCL.DataSetID = BDR.DataSetID
			WHERE	BDR.DataRunID = @DataRunID AND
					(
						(CCL.BeginDate BETWEEN BDR.BeginInitSeedDate AND BDR.EndInitSeedDate) OR
						(CCL.EndDate BETWEEN BDR.BeginInitSeedDate AND BDR.EndInitSeedDate)
					);

			CREATE UNIQUE CLUSTERED INDEX IX_#ClaimLines ON #ClaimLines(DSMemberID, DSClaimLineID);
			--SELECT GETDATE()

			IF OBJECT_ID('tempdb..#BatchMembers') IS NOT NULL
				DROP TABLE #BatchMembers;

			SELECT	BBM.*
			INTO	#BatchMembers
			FROM	Batch.BatchMembers AS BBM WITH(NOLOCK)
					INNER JOIN Batch.Batches AS BB WITH(NOLOCK)
							ON BB.BatchID = BBM.BatchID
			WHERE	(BB.DataRunID = @DataRunID);

			CREATE UNIQUE CLUSTERED INDEX IX_#BatchMembers ON #BatchMembers (DSMemberID, BatchID);
			--SELECT GETDATE()

			IF OBJECT_ID('tempdb..#ClaimCounts') IS NOT NULL
				DROP TABLE #ClaimCounts;

			SELECT	BBM.BatchID,
					COUNT(DISTINCT CCL.DSClaimLineID) AS CountClaimLines,
					COUNT(DISTINCT CCL.DSMemberID) AS CountMembers
			INTO	#ClaimCounts
			FROM	#ClaimLines AS CCL WITH(NOLOCK, INDEX(1))
					INNER JOIN #BatchMembers AS BBM WITH(NOLOCK, INDEX(1))
							ON BBM.DSMemberID = CCL.DSMemberID
			GROUP BY BBM.BatchID;

			CREATE UNIQUE CLUSTERED INDEX IX_#ClaimCounts ON #ClaimCounts (BatchID);
			--SELECT GETDATE()

			IF OBJECT_ID('tempdb..#BatchResults') IS NOT NULL
				DROP TABLE #BatchResults;

			SELECT	CBFO.BatchID AS [Batch ID],
					BB.BatchGuid AS [Batch GUID], 
					MAX(BB.CountClaimLines) AS [Total - Claim Lines],
					MAX(BB.CountClaimCodes) AS [Total - Claim Codes],
					MAX(BB.CountProviders) AS [Total - Providers],
					MAX(BB.CountMembers) AS [Total - Members],
					MAX(BB.CountEnrollment) AS [Total - Enrollment],
					MAX(N1.CountMembers) AS [Total - Enrolled As of End of Period],
					MAX(N2.CountMembers) AS [Total - Enrolled Anytime During Period],
					MAX(N3.CountMembers) AS [Total - Members w/ Claims During Period],
					MAX(N3.CountClaimLines) AS [Total - Claim Lines During Period]
			INTO	#BatchResults
			FROM	Cloud.BatchFileObjects AS CBFO WITH(NOLOCK)
					INNER JOIN Batch.[Batches] AS BB WITH(NOLOCK)
							ON BB.BatchID = CBFO.BatchID
					INNER JOIN Batch.DataRuns AS BDR WITH(NOLOCK)
							ON BDR.DataRunID = BB.DataRunID
					OUTER APPLY (
									SELECT	COUNT(DISTINCT tBBM.DSMemberID) AS CountMembers
									FROM	Member.Enrollment AS tMN WITH(NOLOCK)
											INNER JOIN Batch.BatchMembers AS tBBM WITH(NOLOCK)
													ON tBBM.DSMemberID = tMN.DSMemberID
									WHERE	(tMN.DataSetID = BDR.DataSetID) AND
											(tBBM.BatchID = BB.BatchID) AND
											(BDR.EndInitSeedDate BETWEEN tMN.BeginDate AND tMN.EndDate)
								) AS N1
					OUTER APPLY (
									SELECT	COUNT(DISTINCT tBBM.DSMemberID) AS CountMembers
									FROM	Member.Enrollment AS tMN WITH(NOLOCK)
											INNER JOIN Batch.BatchMembers AS tBBM WITH(NOLOCK)
													ON tBBM.DSMemberID = tMN.DSMemberID
									WHERE	(tMN.DataSetID = BDR.DataSetID) AND
											(tBBM.BatchID = BB.BatchID) AND
											(
												(BDR.EndInitSeedDate BETWEEN tMN.BeginDate AND tMN.EndDate) OR
												(BDR.BeginInitSeedDate BETWEEN tMN.BeginDate AND tMN.EndDate) OR
												(tMN.BeginDate BETWEEN BDR.BeginInitSeedDate AND BDR.EndInitSeedDate) OR
												(tMN.EndDate BETWEEN BDR.BeginInitSeedDate AND BDR.EndInitSeedDate) OR
												(tMN.BeginDate < BDR.BeginInitSeedDate AND tMN.EndDate > BDR.EndInitSeedDate)
											)
								) AS N2
					OUTER APPLY (
									SELECT	SUM(CountClaimLines) AS CountClaimLines, 
											SUM(CountMembers) AS CountMembers
									FROM	#ClaimCounts AS tCC
									WHERE	tCC.BatchID = BB.BatchID
								) AS N3
			WHERE	CBFO.DataRunID = @DataRunID AND 
					CBFO.IsVerified = 1 
			GROUP BY CBFO.BatchID, BB.BatchGuid 
			HAVING	COUNT(DISTINCT CBFO.FileObjectID) = COUNT(DISTINCT CASE WHEN CBFO.CountRecords = 0 THEN CBFO.FileObjectID END) 
			ORDER BY 1;

			IF EXISTS (SELECT TOP 1 1 FROM #BatchResults)
				SELECT 'Batches WITHOUT Results' AS Resultset, * FROM #BatchResults ORDER BY 1;

			SET @LogDescr = 'Validation of record counts completed successfully.'; 
			SET @LogEndTime = GETDATE();
			
			EXEC @Result = Log.RecordEntry	@BatchID = @BatchID,
												@BeginTime = @LogBeginTime,
												@CountRecords = 0,
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
			SET @LogDescr = 'Validation of record counts failed!';
			
			EXEC @Result = Log.RecordEntry	@BatchID = @BatchID,
												@BeginTime = @LogBeginTime,
												@CountRecords = -1, 
												@DataRunID = @DataRunID,
												@DataSetID = @DataSetID,
												@Descr = @LogDescr,
												@EndTime = @LogBeginTime,
												@ErrLogID = @ErrorLogID,
												@EntryXrefGuid = @LogEntryXrefGuid, 
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
GRANT EXECUTE ON  [Result].[ValidateRecordCounts] TO [Processor]
GO
