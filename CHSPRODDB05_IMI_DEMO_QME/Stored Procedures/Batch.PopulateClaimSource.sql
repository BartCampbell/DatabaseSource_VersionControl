SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 6/11/2012
-- Description:	Populates the claim source data used by Events processing.
-- =============================================
CREATE PROCEDURE [Batch].[PopulateClaimSource]
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
	
	BEGIN TRY;
		
		SET @LogBeginTime = GETDATE();
		SET @LogObjectName = 'PopulateClaimSource'; 
		SET @LogObjectSchema = 'Batch'; 
		
		--Added to determine @LogEntryXrefGuid value---------------------------
		SELECT @LogEntryXrefGuid = [Log].GetEntryXrefGuid (@LogObjectSchema, @LogObjectName);
		-----------------------------------------------------------------------
				
		BEGIN TRY;
				
			IF @BatchID IS NULL
				RAISERROR(' - Population of claim source for events failed!  No batch was specified.', 16, 1);
				
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
			
			---------------------------------------------------------------------------
			DECLARE @ClaimTypeE tinyint;
			DECLARE @ClaimTypeL tinyint;
			DECLARE @ClaimTypeP tinyint;

			SELECT @ClaimTypeE = ClaimTypeID FROM Claim.ClaimTypes WHERE Abbrev = 'E';
			SELECT @ClaimTypeL = ClaimTypeID FROM Claim.ClaimTypes WHERE Abbrev = 'L';
			SELECT @ClaimTypeP = ClaimTypeID FROM Claim.ClaimTypes WHERE Abbrev = 'P';

			/*DECLARE @EventTypeC tinyint;
			DECLARE @EventTypeL tinyint;
			DECLARE @EventTypeD tinyint;
			DECLARE @EventTypeP tinyint;

			SELECT @EventTypeC = EventTypeID FROM Measure.EventTypes WHERE Abbrev = 'C'
			SELECT @EventTypeL = EventTypeID FROM Measure.EventTypes WHERE Abbrev = 'L'
			SELECT @EventTypeD = EventTypeID FROM Measure.EventTypes WHERE Abbrev = 'D'
			SELECT @EventTypeP = EventTypeID FROM Measure.EventTypes WHERE Abbrev = 'P'*/
			----------------------------------------------------------------------------

			--1) Identify "Enrolled" records...
			SELECT DISTINCT
					PCL.DSClaimLineID
			INTO	#Enrolled
			FROM	Proxy.ClaimLines AS PCL
					INNER JOIN Proxy.Enrollment AS PN
							ON PCL.DSMemberID = PN.DSMemberID AND
								(
									(PCL.EndDate IS NULL AND PCL.BeginDate BETWEEN PN.BeginDate AND PN.EndDate) OR
									(PCL.EndDate IS NOT NULL AND PCL.EndDate BETWEEN PN.BeginDate AND PN.EndDate)
								)
			WHERE	(PCL.BatchID = @BatchID);
								
			CREATE UNIQUE CLUSTERED INDEX IX_#Enrolled ON #Enrolled (DSClaimLineID);

			--2) Identify "Only" records...
			DECLARE @ICD9DiagCodeType tinyint;
			DECLARE @ICD9ProcCodeType tinyint;
			DECLARE @ICD10DiagCodeType tinyint;
			DECLARE @ICD10ProcCodeType tinyint;

			SELECT @ICD9DiagCodeType = CodeTypeID FROM Claim.CodeTypes WHERE CodeType = 'D';
			SELECT @ICD9ProcCodeType = CodeTypeID FROM Claim.CodeTypes WHERE CodeType = 'P';
			SELECT @ICD10DiagCodeType = CodeTypeID FROM Claim.CodeTypes WHERE CodeType = 'I';
			SELECT @ICD10ProcCodeType = CodeTypeID FROM Claim.CodeTypes WHERE CodeType = 'Q';

			SELECT	CodeTypeID,
					DSClaimLineID
			INTO	#Only
			FROM	Proxy.ClaimCodes
			WHERE	CodeTypeID IN (@ICD9DiagCodeType, @ICD9ProcCodeType, @ICD10DiagCodeType, @ICD10ProcCodeType) AND
					(BatchID = @BatchID)
			GROUP BY CodeTypeID,
					DSClaimLineID
			HAVING	(COUNT(DISTINCT DSClaimCodeID) = 1);

			CREATE UNIQUE CLUSTERED INDEX IX_#Only ON #Only (DSClaimLineID, CodeTypeID);

			--3) Populate ClaimSource...
			IF OBJECT_ID('tempdb..#ClaimSource') IS NOT NULL
				DROP TABLE #ClaimSource;

			INSERT INTO Proxy.ClaimSource
					(BatchID,
					BeginDate,
					BitClaimAttribs,
					BitClaimSrcTypes,
					BitSpecialties,
					ClaimBeginDate,
					ClaimCompareDate,
					ClaimEndDate,
					ClaimTypeID,
					Code,
					CodeID,
					CodeTypeID,
					CompareDate,
					DataRunID,
					DataSetID,
					DataSourceID,
					[Days],
					DaysPaid,
					DOB,
					DSClaimCodeID,
					DSClaimID,
					DSClaimLineID,
					DSMemberID,
					DSProviderID,
					EndDate,
					Gender,
					IsEnrolled,
					IsLab,
					IsOnly,
					IsPaid,
					IsPositive,
					IsPrimary,
					IsSupplemental,
					LabValue,
					Qty,
					QtyDispensed,
					ServDate)
			SELECT	PCL.BatchID,
					PCL.BeginDate,
					CONVERT(bigint, 0) AS BitClaimAttribs,
					CONVERT(bigint, ISNULL(CST.BitValue, 0)) AS BitClaimSrcTypes,
					CONVERT(bigint, ISNULL(PP.BitSpecialties, 0)) AS BitSpecialties,
					PC.BeginDate AS ClaimBeginDate,
					ISNULL(PC.EndDate, PC.BeginDate) AS ClaimCompareDate,
					PC.EndDate AS ClaimEndDate,
					PCL.ClaimTypeID,
					ISNULL(PCC.Code, '(n/a)') AS Code,
					ISNULL(PCC.CodeID, -2147483648) AS CodeID,
					ISNULL(PCC.CodeTypeID, 0) AS CodeTypeID,
					ISNULL(PCL.EndDate, PCL.BeginDate) AS CompareDate,
					PCL.DataRunID,
					PCL.DataSetID,
					PCL.DataSourceID,
					PCL.[Days],
					PCL.DaysPaid,
					PM.DOB,
					ISNULL(PCC.DSClaimCodeID, PCL.DSClaimLineID * -1) AS DSClaimCodeID, --Can only happen with provider specialty w/o any codes
					PC.DSClaimID,
					PCL.DSClaimLineID,
					PCL.DSMemberID,
					PCL.DSProviderID,
					PCL.EndDate,
					PM.Gender,
					CONVERT(bit, CASE WHEN N.DSClaimLineID IS NOT NULL THEN 1 ELSE 0 END) AS IsEnrolled,
					CONVERT(bit, CASE WHEN PCL.ClaimTypeID = @ClaimTypeE AND PCC.CodeTypeID IN (@ICD9DiagCodeType, @ICD10DiagCodeType) AND /*PCL.CPT LIKE '8____' AND*/ PCL.POS = '81' THEN 1 ELSE 0 END) AS IsLab, --Per NCQA, changed back to earlier logic 2/19/2014 for RRU.  On 11/13/2015, commented out 80000 CPT req due to URI.
					CONVERT(bit, CASE WHEN O.DSClaimLineID IS NOT NULL THEN 1 ELSE 0 END) AS IsOnly,
					PCL.IsPaid,
					PCL.IsPositive,
					ISNULL(PCC.IsPrimary, 0) AS IsPrimary,
					PCL.IsSupplemental,
					PCL.LabValue,
					PCL.Qty,
					PCL.QtyDispensed,
					PCL.ServDate
			FROM	Proxy.ClaimLines AS PCL
					INNER JOIN Proxy.Members AS PM
							ON PCL.DSMemberID = PM.DSMemberID
					LEFT OUTER JOIN Claim.SourceTypes AS CST
							ON PCL.ClaimSrcTypeID = CST.ClaimSrcTypeID
					LEFT OUTER JOIN Proxy.ClaimCodes AS PCC
							ON PCL.DSClaimLineID = PCC.DSClaimLineID
					LEFT OUTER JOIN Proxy.Claims AS PC
							ON PCL.DSClaimID = PC.DSClaimID
					LEFT OUTER JOIN Proxy.Providers AS PP
							ON PCL.DSProviderID = PP.DSProviderID
					LEFT OUTER JOIN #Enrolled AS N WITH(INDEX(1))
							ON PCL.DSClaimLineID = N.DSClaimLineID
					LEFT OUTER JOIN #Only AS O WITH(INDEX(1))
							ON O.DSClaimLineID = PCC.DSClaimLineID AND
								O.CodeTypeID = PCC.CodeTypeID
			WHERE	(PCL.BatchID = @BatchID) AND
					(PM.BatchID = @BatchID) AND
					(
						(PCC.CodeID IS NOT NULL) OR
						(PP.BitSpecialties > 0)
					)
			ORDER BY PCL.DSClaimLineID
			OPTION(FORCE ORDER);		
			
			SET @CountRecords = ISNULL(@CountRecords, 0) + @@ROWCOUNT;
						
			SET @LogDescr = ' - Population of claim source for events for BATCH ' + ISNULL(CAST(@BatchID AS varchar), '?') + ' succeeded.'; 
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
			SET @LogDescr = ' - Population of claim source for events for BATCH ' + ISNULL(CAST(@BatchID AS varchar), '?') + ' refresh failed!'; --{FAILURE LOG DESCRIPTION HERE}
			
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
GRANT EXECUTE ON  [Batch].[PopulateClaimSource] TO [Processor]
GO
