SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 1/28/2011
-- Description:	Removes records from Temp.EventBase based on date, enrollment, member, and/or provider event requirements.
-- =============================================
CREATE PROCEDURE [Batch].[ApplyEventRequirements]
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
		SET @LogObjectName = 'ApplyEventRequirements'; 
		SET @LogObjectSchema = 'Batch'; 
		
		--Added to determine @LogEntryXrefGuid value---------------------------
		SELECT @LogEntryXrefGuid = [Log].GetEntryXrefGuid (@LogObjectSchema, @LogObjectName);
		-----------------------------------------------------------------------
		
		BEGIN TRY;
				
			IF @BatchID IS NULL
				RAISERROR(' - Applying event requirements failed!  No batch was specified.', 16, 1);
				
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

			DECLARE @EventTypeC tinyint;
			DECLARE @EventTypeL tinyint;
			DECLARE @EventTypeD tinyint;
			DECLARE @EventTypeP tinyint;

			SELECT @EventTypeC = EventTypeID FROM Measure.EventTypes WHERE Abbrev = 'C';
			SELECT @EventTypeL = EventTypeID FROM Measure.EventTypes WHERE Abbrev = 'L';
			SELECT @EventTypeD = EventTypeID FROM Measure.EventTypes WHERE Abbrev = 'D';
			SELECT @EventTypeP = EventTypeID FROM Measure.EventTypes WHERE Abbrev = 'P';
			----------------------------------------------------------------------------
			
			--Removing records that do not meet enrollment requirements-------------
			
			SELECT DISTINCT
					EventCritID,
					RequireEnrolled
			INTO	#EnrollEvents
			FROM	Proxy.EventKey
			WHERE	(HasEnrollReqs = 1);
			
			CREATE UNIQUE CLUSTERED INDEX IX_#EnrollEvents ON #EnrollEvents (EventCritID, RequireEnrolled);
			
			SELECT DISTINCT
					VB.EventBaseID
			INTO	#Enroll_EventBase
			FROM	#EnrollEvents AS EV
					INNER JOIN Proxy.EventBase AS VB
							ON EV.EventCritID = VB.EventCritID
					LEFT OUTER JOIN Proxy.Enrollment AS N
							ON VB.DSMemberID = N.DSMemberID AND
								((EV.RequireEnrolled = 0) OR
								((EV.RequireEnrolled = 1) AND
								((VB.EndDate IS NULL) AND
								(VB.BeginDate BETWEEN N.BeginDate AND COALESCE(N.EndDate, GETDATE()))) OR
								((VB.EndDate IS NOT NULL) AND
								(VB.EndDate BETWEEN N.BeginDate AND COALESCE(N.EndDate, GETDATE())))))
			WHERE	(N.EnrollItemID IS NULL);

			DELETE
			FROM	Proxy.EventBase
			WHERE	(EventBaseID IN (SELECT EventBaseID FROM #Enroll_EventBase)) AND
					(HasEnrollReqs = 1);

			SET @CountRecords = ISNULL(@CountRecords, 0) + @@ROWCOUNT;

			--Removing records that do not meet member requirements-----------------
			SELECT DISTINCT
					AfterDOBDays, 
					AfterDOBMonths, 
					--BeginDOB, 
					--EndDOB, 
					EventCritID, 
					EventID,
					Gender
			INTO	#MemberEvents
			FROM	Proxy.EventKey
			WHERE	(HasMemberReqs = 1);
			
			CREATE UNIQUE CLUSTERED INDEX IX_#MemberEvents ON #MemberEvents (EventID, EventCritID, AfterDOBDays, AfterDOBMonths, Gender);
			
			SELECT DISTINCT
					VB.EventBaseID
			INTO	#Members_EventBase
			FROM	#MemberEvents AS MV 
					INNER JOIN Proxy.EventBase AS VB
							ON MV.EventCritID = VB.EventCritID AND
								MV.EventID = VB.EventID
					LEFT OUTER JOIN Proxy.Members AS M
							ON VB.DSMemberID = M.DSMemberID AND	
								--((MV.BeginDOB IS NULL) OR
								--(MV.BeginDOB IS NOT NULL AND MV.BeginDOB <= M.DOB)) AND
								
								--((MV.EndDOB IS NULL) OR
								--(MV.EndDOB IS NOT NULL AND MV.EndDOB >= M.DOB)) AND
								
								((MV.Gender IS NULL) OR
								(MV.Gender = M.Gender)) AND
								
								((MV.AfterDOBDays IS NULL) OR 
								(MV.AfterDOBMonths IS NULL) OR
								((DATEADD(day, MV.AfterDOBDays, DATEADD(month, MV.AfterDOBMonths, M.DOB)) <= VB.BeginDate) AND
								(VB.EndDate IS NULL OR DATEADD(day, MV.AfterDOBDays, DATEADD(month, MV.AfterDOBMonths, M.DOB)) <= VB.EndDate)))
			WHERE M.DSMemberID IS NULL;
			
			DELETE 
			FROM	Proxy.EventBase 
			WHERE	(EventBaseID IN (SELECT EventBaseID FROM #Members_EventBase)) AND
					(HasMemberReqs = 1);

			SET @CountRecords = ISNULL(@CountRecords, 0) + @@ROWCOUNT;


			--Removing records that do not meet only-code requirements-----------------
			DECLARE @ICD9DiagCodeType tinyint;
			DECLARE @ICD9ProcCodeType tinyint;

			SELECT @ICD9DiagCodeType = CodeTypeID FROM Claim.CodeTypes WHERE CodeType = 'D';
			SELECT @ICD9ProcCodeType = CodeTypeID FROM Claim.CodeTypes WHERE CodeType = 'P';

			SELECT	TCC.DSClaimLineID, 
					TCC.CodeTypeID,
					MIN(CodeID) AS CodeID
			INTO	#OnlyCodeClaims
			FROM	Proxy.ClaimCodes AS TCC
					INNER JOIN Proxy.ClaimLines AS TCL
							ON TCC.DSClaimLineID = TCL.DSClaimLineID AND
								TCC.CodeTypeID IN (@ICD9DiagCodeType, @ICD9ProcCodeType) AND
								TCL.ClaimTypeID = 1
			GROUP BY TCC.DSClaimLineID, TCC.CodeTypeID
			HAVING (COUNT(CodeID) = 1);
			
			CREATE UNIQUE CLUSTERED INDEX IX_#OnlyCodeClaims ON #OnlyCodeClaims (DSClaimLineID, CodeTypeID, CodeID);
			
			SELECT	VB.EventBaseID
			INTO	#NotOnly_EventBase
			FROM	Proxy.EventBase AS VB
					INNER JOIN Proxy.EventKey AS TEK
							ON VB.EventID = TEK.EventID AND
								VB.EventCritID = TEK.EventCritID AND
								VB.OptionNbr = TEK.OptionNbr AND
								VB.CodeID = TEK.CodeID AND
								TEK.RequireOnly = 1
					LEFT OUTER JOIN #OnlyCodeClaims AS OCC
							ON VB.DSClaimLineID = OCC.DSClaimLineID AND
								VB.CodeID = OCC.CodeID AND
								TEK.CodeTypeID = OCC.CodeTypeID AND
								TEK.CodeID = OCC.CodeID
			WHERE OCC.DSClaimLineID IS NULL;

			DELETE FROM Proxy.EventBase WHERE EventBaseID IN (SELECT EventBaseID FROM #NotOnly_EventBase);
						
			SET @CountRecords = ISNULL(@CountRecords, 0) + @@ROWCOUNT;
			
			--Removing records that do not meet provider specialty requirements---------
			SELECT DISTINCT
					VB.EventBaseID 
			INTO	#ValidEventBase
			FROM	Proxy.EventBase AS VB
					INNER JOIN Measure.EventCriteriaSpecialties AS MVCS
							ON VB.EventCritID = MVCS.EventCritID 				
					INNER JOIN Proxy.ProviderSpecialties AS PS
							ON VB.DSProviderID = PS.DSProviderID AND
								MVCS.SpecialtyID = PS.SpecialtyID
			WHERE	(VB.HasCodeReqs IS NULL) OR
					(VB.HasCodeReqs = 1);
					
			CREATE UNIQUE CLUSTERED INDEX IX_#ValidEventBase ON #ValidEventBase (EventBaseID);
			
			WITH EventCriteriaSpecialties AS
			(
				SELECT DISTINCT
						EventCritID
				FROM	Measure.EventCriteriaSpecialties
			)
			SELECT DISTINCT
					VB.EventBaseID 
			INTO	#ActualEventBase
			FROM	Proxy.EventBase AS VB
					INNER JOIN EventCriteriaSpecialties AS VCS
							ON VB.EventCritID = VCS.EventCritID 
			WHERE	(VB.HasCodeReqs IS NULL) OR
					(VB.HasCodeReqs = 1);
					
			CREATE UNIQUE CLUSTERED INDEX IX_#ActualEventBase ON #ActualEventBase (EventBaseID);
			
			SELECT	AVB.*
			INTO	#NotSpecialty_EventBase
			FROM	#ActualEventBase AS AVB
					LEFT OUTER JOIN #ValidEventBase AS VVB
							ON AVB.EventBaseID = VVB.EventBaseID 
			WHERE	VVB.EventBaseID IS NULL
			
			DELETE FROM Proxy.EventBase WHERE EventBaseID IN (SELECT EventBaseID FROM #NotSpecialty_EventBase);
			
			SET @CountRecords = ISNULL(@CountRecords, 0) + @@ROWCOUNT;
						
			SET @LogDescr = ' - Applying event requirements for BATCH ' + ISNULL(CAST(@BatchID AS varchar), '?') + ' succeeded.'; 
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
			SET @LogDescr = 'Applying event requirements for BATCH ' + ISNULL(CAST(@BatchID AS varchar), '?') + ' refresh failed!'; --{FAILURE LOG DESCRIPTION HERE}
			
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
GRANT VIEW DEFINITION ON  [Batch].[ApplyEventRequirements] TO [db_executer]
GO
GRANT EXECUTE ON  [Batch].[ApplyEventRequirements] TO [db_executer]
GO
GRANT EXECUTE ON  [Batch].[ApplyEventRequirements] TO [Processor]
GO
