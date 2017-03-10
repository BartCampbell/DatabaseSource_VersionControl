SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 1/30/2011
-- Description:	Populates the Temp.EventBase table with lab event-based matching data (allows for lagged lab claims). (v1)
-- =============================================
CREATE PROCEDURE [Batch].[ApplyEventBaseLabs]
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
		SET @LogObjectName = 'ApplyEventBaseLabs'; 
		SET @LogObjectSchema = 'Batch'; 
		
		--Added to determine @LogEntryXrefGuid value---------------------------
		SELECT @LogEntryXrefGuid = [Log].GetEntryXrefGuid (@LogObjectSchema, @LogObjectName);
		-----------------------------------------------------------------------
				
		BEGIN TRY;
				
			IF @BatchID IS NULL
				RAISERROR(' - Applying additional lab event-based details failed!  No batch was specified.', 16, 1);
				
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
			--DECLARE @ClaimTypeP tinyint;

			SELECT @ClaimTypeE = ClaimTypeID FROM Claim.ClaimTypes WHERE Abbrev = 'E';
			SELECT @ClaimTypeL = ClaimTypeID FROM Claim.ClaimTypes WHERE Abbrev = 'L';
			--SELECT @ClaimTypeP = ClaimTypeID FROM Claim.ClaimTypes WHERE Abbrev = 'P';

			----------------------------------------------------------------------------

			--Retrieve the number of lag days permitted for labs by this data owner...			
			DECLARE @LabLagDays smallint;
			DECLARE @LabLagMonths smallint;

			SELECT	@LabLagDays = O.LabLagDays,
					@LabLagMonths = O.LabLagMonths 
			FROM	Batch.DataOwners AS O
					INNER JOIN Batch.DataSets AS DS
							ON O.OwnerID = DS.OwnerID AND
								DS.DataSetID = @DataSetID 

			--INSERT labs into Temp.EventBase, if possible...
			IF @LabLagDays > 0 OR @LabLagMonths > 0
				BEGIN
					WITH LabEventOptions AS 
					(
						SELECT	MVO.EventID, MVO.OptionNbr 
						FROM	Measure.EventCriteria AS MVC
								INNER JOIN Measure.EventOptions AS MVO
										ON MVC.EventCritID = MVO.EventCritID 
						WHERE	((MVC.ClaimTypeID = @ClaimTypeL) AND 
								(MVO.RankOrder > 1))
					),
					LabEventRank1st AS
					(
						SELECT DISTINCT
								MVO.EventCritID 
						FROM	LabEventOptions AS LVO
								INNER JOIN Measure.EventOptions AS MVO
										ON LVO.EventID = MVO.EventID AND
											LVO.OptionNbr = MVO.OptionNbr AND
											MVO.RankOrder = 1
					),
					EventBase AS 
					(
						SELECT	/*Unique per event type*/			
								BeginDate,
								DSMemberID,
								DATEADD(month, @LabLagMonths, DATEADD(day, @LabLagDays, COALESCE(EndDate, BeginDate))) AS EndDate,

								/*Same for all event types*/
								EventBaseID,
								EventID, 
								EventTypeID, 
								OptionNbr
						FROM	Proxy.EventBase
						WHERE	(EventCritID IN (SELECT EventCritID FROM LabEventRank1st)) AND
								(CountCriteria > 1)
					)
					INSERT INTO Proxy.EventBase
							(Allow, BatchID, BeginDate, ClaimTypeID, CodeID, CountAllowed,
							CountCriteria, CountDenied, DataRunID, DataSetID, DSClaimID, 
							DSClaimLineID, DSMemberID, DSProviderID, 
							EndDate, EventBaseID, EventCritID, EventID,
							EventTypeID, HasDateReqs, HasEnrollReqs, HasMemberReqs,
							HasProviderReqs, IsPaid, IsSupplemental, OptionNbr, RankOrder)
					SELECT DISTINCT
							TEK.Allow,
							@BatchID AS BatchID, 
							CCL.BeginDate,
							CCL.ClaimTypeID,
							CCC.CodeID,
							TEK.CountAllowed,
							TEK.CountCriteria,
							TEK.CountDenied,
							@DataRunID AS DataRunID,
							@DataSetID AS DataSetID,
							CCC.DSClaimID,
							CCC.DSClaimLineID,
							CCL.DSMemberID,
							CCL.DSProviderID,
							CCL.EndDate,
							VB.EventBaseID,
							TEK.EventCritID,
							TEK.EventID,
							TEK.EventTypeID,
							TEK.HasDateReqs,
							TEK.HasEnrollReqs,
							TEK.HasMemberReqs,
							TEK.HasProviderReqs,
							CCL.IsPaid,
							CCL.IsSupplemental,
							TEK.OptionNbr,
							TEK.RankOrder
					FROM	Proxy.ClaimCodes AS CCC
							INNER JOIN Proxy.ClaimLines AS CCL
									ON CCC.DSClaimLineID = CCL.DSClaimLineID AND
										CCL.ClaimTypeID IN (@ClaimTypeL, @ClaimTypeE)
							INNER JOIN Proxy.EventKey AS TEK
									ON CCC.CodeID = TEK.CodeID AND
										--Only Ranks besides RankOrder 1
										TEK.RankOrder > 1 AND
										--Filter Encounter-based Lab *Requests*, if applicable
										((TEK.AllowLab = 1 OR (TEK.AllowLab = 0 AND ((CCL.CPT IS NULL) OR 
																					(CCL.POS IS NULL) OR 
																					(NOT (CCL.CPT LIKE '8____' AND CCL.POS = '81' AND CCL.ClaimTypeID = @ClaimTypeE)))))) AND
										--Filter Paid Claims, if applicable
										(TEK.RequirePaid = 0 OR (TEK.RequirePaid = 1 AND CCL.IsPaid = 1)) AND
										--Filter Primary diagnoses/procedures, if applicable
										(TEK.RequirePrimary = 0 OR (TEK.RequirePrimary = 1 AND CCC.IsPrimary = 1))
							INNER JOIN EventBase AS VB
									ON TEK.EventID = VB.EventID AND
										TEK.EventTypeID = VB.EventTypeID AND
										TEK.OptionNbr = VB.OptionNbr AND
										TEK.ClaimTypeID = @ClaimTypeL AND
										CCL.DSMemberID = VB.DSMemberID AND
										((CCL.BeginDate BETWEEN VB.BeginDate AND VB.EndDate) OR
										(CCL.ServDate BETWEEN VB.BeginDate AND VB.EndDate))

					SET @CountRecords = ISNULL(@CountRecords, 0) + @@ROWCOUNT;
				END
			ELSE
				SET @CountRecords = 0;
						
			SET @LogDescr = ' - Applying additional lab event-based details for BATCH ' + ISNULL(CAST(@BatchID AS varchar), '?') + ' succeeded.'; 
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
			SET @LogDescr = 'Applying additional lab event-based details for BATCH ' + ISNULL(CAST(@BatchID AS varchar), '?') + ' refresh failed!'; --{FAILURE LOG DESCRIPTION HERE}
			
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
GRANT VIEW DEFINITION ON  [Batch].[ApplyEventBaseLabs] TO [db_executer]
GO
GRANT EXECUTE ON  [Batch].[ApplyEventBaseLabs] TO [db_executer]
GO
GRANT EXECUTE ON  [Batch].[ApplyEventBaseLabs] TO [Processor]
GO
