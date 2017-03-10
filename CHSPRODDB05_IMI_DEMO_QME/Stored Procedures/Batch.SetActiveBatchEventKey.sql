SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 1/26/2011
-- Description:	Sets (loads) the event key corresponding to the specified batch in the Temp schema tables.
-- =============================================
CREATE PROCEDURE [Batch].[SetActiveBatchEventKey]
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
	DECLARE @EventTypeID tinyint;
	DECLARE @IsLogged bit;
	DECLARE @MeasureSetID int;
	DECLARE @OwnerID int;
	DECLARE @SeedDate datetime;
	
	BEGIN TRY;
		
		SET @LogBeginTime = GETDATE();
		SET @LogObjectName = 'SetActiveBatchEventKey'; 
		SET @LogObjectSchema = 'Batch'; 
		
		--Added to determine @LogEntryXrefGuid value---------------------------
		SELECT @LogEntryXrefGuid = [Log].GetEntryXrefGuid (@LogObjectSchema, @LogObjectName);
		-----------------------------------------------------------------------
				
		BEGIN TRY;
				
			IF @BatchID IS NULL
				RAISERROR(' - Setting of active batch event key failed!  No batch was specified.', 16, 1);
				
			DECLARE @CountRecords int;
			
			SELECT	@BeginInitSeedDate = DR.BeginInitSeedDate,
					@DataRunID = DR.DataRunID,
					@DataSetID = DS.DataSetID,
					@EndInitSeedDate = DR.EndInitSeedDate,
					@EventTypeID = DO.EventTypeID,
					@IsLogged = DR.IsLogged,
					@MeasureSetID = DR.MeasureSetID,
					@OwnerID = DS.OwnerID,
					@SeedDate = DR.SeedDate
			FROM	Batch.[Batches] AS B 
					INNER JOIN Batch.DataRuns AS DR
							ON B.DataRunID = DR.DataRunID
					INNER JOIN Batch.DataSets AS DS 
							ON B.DataSetID = DS.DataSetID 
					INNER JOIN Batch.DataOwners AS DO
							ON DS.OwnerID = DO.OwnerID
			WHERE	(B.BatchID = @BatchID);
			
			DECLARE @EventTypeX tinyint; --Owner-specific Default Event Type
			SELECT @EventTypeX = EventTypeID FROM Measure.EventTypes WHERE Abbrev = 'X';
			
			DECLARE @ClaimAttribIN smallint;
			DECLARE @ClaimAttribINBitValue bigint;
			
			SELECT @ClaimAttribIN = ClaimAttribID, @ClaimAttribINBitValue = BitValue FROM Claim.Attributes WHERE Abbrev = 'IN';
			
			IF 1 = 1 --NOT EXISTS(SELECT TOP (1) 1 AS N FROM Proxy.EventKey WHERE MeasureSetID = @MeasureSetID)
				BEGIN
					DELETE FROM Proxy.EventKey;
					
					--1) Calculate Specialties restrictions...
					SELECT  SUM(CASE WHEN MVCS.IsValid = 1 THEN PS.BitValue ELSE 0 END) AS BitSpecialtiesAllowed,
							SUM(CASE WHEN MVCS.IsValid = 0 THEN PS.BitValue ELSE 0 END) AS BitSpecialtiesDenied,
							MVCS.EventCritID 
					INTO	#EventCriteriaSpecialties
					FROM	Measure.EventCriteriaSpecialties AS MVCS
							INNER JOIN Provider.Specialties AS PS
									ON MVCS.SpecialtyID = PS.SpecialtyID
					WHERE	(MVCS.EventCritID IN (SELECT EventCritID FROM Measure.EventCriteria WHERE MeasureSetID = @MeasureSetID))
					GROUP BY MVCS.EventCritID;
					
					CREATE UNIQUE CLUSTERED INDEX IX_#EventCriteriaSpecialties ON #EventCriteriaSpecialties (EventCritID);
					
					--2) Calculate Claim Attribute restrictions...
					SELECT	SUM(CASE WHEN MVCCA.IsValid = 1 THEN CA.BitValue ELSE 0 END) AS BitClaimAttribsAllowed,
							SUM(CASE WHEN MVCCA.IsValid = 0 THEN CA.BitValue ELSE 0 END) AS BitClaimAttribsDenied,
							MVCCA.EventCritID
					INTO	#EventCriteriaClaimAttributes
					FROM	Measure.EventCriteriaClaimAttributes AS MVCCA
							INNER JOIN Claim.Attributes AS CA
									ON MVCCA.ClaimAttribID = CA.ClaimAttribID
					WHERE	(MVCCA.EventCritID IN (SELECT EventCritID FROM Measure.EventCriteria WHERE MeasureSetID = @MeasureSetID))
					GROUP BY MVCCA.EventCritID;
									
					CREATE UNIQUE CLUSTERED INDEX IX_#EventCriteriaClaimAttributes ON #EventCriteriaClaimAttributes (EventCritID);

					--3) Calculate Claim Source Type restrictions...
					SELECT	SUM(CASE WHEN MVST.IsValid = 1 THEN CST.BitValue ELSE 0 END) AS BitClaimSrcTypesAllowed,
							SUM(CASE WHEN MVST.IsValid = 0 THEN CST.BitValue ELSE 0 END) AS BitClaimSrcTypesDenied,
							MVST.EventID
					INTO	#EventSourceTypes
					FROM	Measure.EventSourceTypes AS MVST
							INNER JOIN Claim.SourceTypes AS CST
									ON MVST.ClaimSrcTypeID = CST.ClaimSrcTypeID
					WHERE	(MVST.EventID IN (SELECT EventID FROM Measure.[Events] WHERE MeasureSetID = @MeasureSetID))
					GROUP BY MVST.EventID;
									
					CREATE UNIQUE CLUSTERED INDEX IX_#EventSourceTypes ON #EventSourceTypes (EventID);

					--4) Calculate Event Options requirements...
					SELECT	MVO.EventID, MVO.OptionNbr, 
							COUNT(*) AS CountCriteria,
							COUNT(CASE WHEN Allow = 1 THEN 1 END) AS CountAllowed,
							COUNT(CASE WHEN Allow = 0 THEN 1 END) AS CountDenied
					INTO	#EventOptionCounts
					FROM	Measure.EventOptions AS MVO
							INNER JOIN Measure.[Events] AS MV
									ON MVO.EventID = MV.EventID AND
										MVO.IsEnabled = 1 AND
										MV.IsEnabled = 1
					WHERE	(MV.MeasureSetID = @MeasureSetID)
					GROUP BY MVO.EventID, MVO.OptionNbr;
					
					CREATE UNIQUE CLUSTERED INDEX IX_#EventOptionCounts ON #EventOptionCounts (EventID, OptionNbr);

					SELECT * INTO #MeasureEvents FROM Measure.GetMeasureEvents(DEFAULT, DEFAULT, @MeasureSetID);
					CREATE UNIQUE CLUSTERED INDEX IX_#MeasureEvents ON #MeasureEvents (EventID, MeasureID);

					--5) Populate the Event Key...
					INSERT INTO Proxy.EventKey
							(AfterDOBDays,
							AfterDOBMonths,
							Allow,
							AllowEndDate,
							AllowLab,
							AllowSupplemental,
							BatchID,
							BeginDate,
							BeginDays,
							BeginMonths,
							BitClaimAttribsAllowed,
							BitClaimAttribsDenied,
							BitClaimSrcTypesAllowed,
							BitClaimSrcTypesDenied,
							BitSpecialtiesAllowed,
							BitSpecialtiesDenied,
							ClaimTypeID,
							Code,
							CodeID,
							CodeTypeID,
							CountAllowed,
							CountCriteria,
							CountDenied,
							DataRunID,
							DataSetID,
							DefaultDays,
							DefaultValue,
							Descr,
							EndDate,
							EndDays,
							EndMonths,
							EventCritCodeID,
							EventCritDescr,
							EventCritGuid,
							EventCritID,
							EventGuid,
							EventID,
							EventOptGuid,
							EventOptID,
							EventTypeID,
							[ExpireDate],
							Gender,
							HasClaimAttribReqs,
							HasCodeReqs,
							HasDateReqs,
							HasEnrollReqs,
							HasMemberReqs,
							HasProviderReqs,
							IsClaimAttrib,
							MeasureSetID,
							OptionNbr,
							RankOrder,
							Reference1,
							Reference2,
							Reference3,
							Reference4,
							RequireEndDate,
							RequireEnrolled,
							RequireOnly,
							RequirePaid,
							RequirePrimary,
							Require1stRank,
							Value,
							ValueTypeID)
					SELECT DISTINCT
							MVC.AfterDOBDays,
							MVC.AfterDOBMonths, 
							MVO.Allow, 
							MV.AllowEndDate, 
							MVC.AllowLab,
							MVC.AllowSupplemental,
							@BatchID,
							DATEADD(day, MV.BeginDays, DATEADD(month, MV.BeginMonths, @BeginInitSeedDate)) AS BeginDate,
							MV.BeginDays,
							MV.BeginMonths,
							CASE WHEN MV.IsClaimAttrib = 0 AND MV.AllowEndDate = 1 AND MV.RequireEndDate = 1 THEN @ClaimAttribINBitValue ELSE 0 END | ISNULL(VCCA.BitClaimAttribsAllowed, 0) AS BitClaimAttribsAllowed,
							CASE WHEN MV.IsClaimAttrib = 0 AND MV.AllowEndDate = 0 AND MV.RequireEndDate = 0 THEN @ClaimAttribINBitValue ELSE 0 END | ISNULL(VCCA.BitClaimAttribsDenied, 0) AS BitClaimAttribsDenied,
							ISNULL(VST.BitClaimSrcTypesAllowed, 0) AS BitClaimSrcTypesAllowed,
							ISNULL(VST.BitClaimSrcTypesDenied, 0) AS BitClaimSrcTypesDenied,
							ISNULL(VCS.BitSpecialtiesAllowed, 0) AS BitSpecialtiesAllowed,
							ISNULL(VCS.BitSpecialtiesDenied, 0) AS BitSpecialtiesDenied,
							MVC.ClaimTypeID, 
							MVD.Code, 
							ISNULL(MVD.CodeID, -2147483648) AS CodeID, 
							MVD.CodeTypeID,
							VOC.CountAllowed,
							VOC.CountCriteria,
							VOC.CountDenied,
							@DataRunID,
							@DataSetID,
							MVC.DefaultDays,
							MVC.DefaultValue,
							MV.Descr, 
							DATEADD(day, MV.EndDays, DATEADD(month, MV.EndMonths, @EndInitSeedDate)) AS EndDate,
							MV.EndDays, 
							MV.EndMonths,
							ISNULL(MVD.EventCritCodeID, -2147483648) AS EventCritCodeID, 
							MVC.Descr AS EventCritDescr, 
							MVC.EventCritGuid, 
							MVO.EventCritID,
							MV.EventGuid, 
							MV.EventID, 
							MVO.EventOptGuid, 
							MVO.EventOptID,  
							ISNULL(NULLIF(MV.EventTypeID, @EventTypeX), @EventTypeID) AS EventTypeID, --Converts Owner-specific default, if applicable
							MVC.[ExpireDate],
							MV.Gender, 
							CASE WHEN ISNULL(VCCA.BitClaimAttribsAllowed, 0) > 0 OR
									ISNULL(VCCA.BitClaimAttribsDenied, 0) > 0 
								THEN 1
								ELSE 0
								END AS HasClaimAttribReqs,
							CASE WHEN MVD.EventCritCodeID IS NOT NULL
								THEN 1
								ELSE 0
								END AS HasCodeReqs,
							CASE WHEN MV.AllowEndDate = 0 OR
									MV.BeginDays IS NOT NULL OR
									MV.BeginMonths IS NOT NULL OR
									MV.EndDays IS NOT NULL OR
									MV.EndMonths IS NOT NULL OR
									MV.RequireEndDate = 1
								THEN 1
								ELSE 0 
								END AS HasDateReqs,
							MV.RequireEnrolled AS HasEnrollReqs,
							CASE WHEN MVC.AfterDOBDays IS NOT NULL OR
									MVC.AfterDOBMonths IS NOT NULL OR
									MV.Gender IS NOT NULL
								THEN 1
								ELSE 0 
								END AS HasMemberReqs,	
							CASE WHEN ISNULL(VCS.BitSpecialtiesAllowed, 0) > 0 OR
									ISNULL(VCS.BitSpecialtiesDenied, 0) > 0
								THEN 1
								ELSE 0 
								END AS HasProvderReqs,
							MV.IsClaimAttrib,
							MV.MeasureSetID, 
							MVO.OptionNbr, 
							MVO.RankOrder, 
							MVC.Reference1, 
							MVC.Reference2, 
							MVC.Reference3, 
							MVC.Reference4, 
							MV.RequireEndDate, 
							MV.RequireEnrolled, 
							MVC.RequireOnly, 
							MV.RequirePaid, 
							MVC.RequirePrimary, 
							MVO.Require1stRank,
							MVD.Value,
							MVC.ValueTypeID
					FROM	Measure.[Events] AS MV
							INNER JOIN #MeasureEvents AS MMV
									ON MV.EventID = MMV.EventID
							INNER JOIN Batch.BatchMeasures AS BBM
									ON MMV.MeasureID = BBM.MeasureID
							INNER JOIN Measure.EventOptions AS MVO
									ON MV.EventID = MVO.EventID
							INNER JOIN Measure.EventCriteria AS MVC
									ON MVO.EventCritID = MVC.EventCritID
							INNER JOIN #EventOptionCounts AS VOC
									ON MVO.EventID = VOC.EventID AND
										MVO.OptionNbr = VOC.OptionNbr
							LEFT OUTER JOIN Measure.EventCriteriaCodes AS MVD
									ON MVO.EventCritID = MVD.EventCritID
							LEFT OUTER JOIN #EventCriteriaSpecialties AS VCS
									ON MVO.EventCritID = VCS.EventCritID
							LEFT OUTER JOIN #EventCriteriaClaimAttributes AS VCCA
									ON MVO.EventCritID = VCCA.EventCritID
							LEFT OUTER JOIN #EventSourceTypes AS VST
									ON MV.EventID = VST.EventID
					WHERE	(BBM.BatchID = @BatchID) AND
							(MVC.MeasureSetID = @MeasureSetID) AND
							(MV.MeasureSetID = @MeasureSetID) AND
							(MV.IsEnabled = 1) AND
							(MVO.IsEnabled = 1) AND
							(
								(MVD.EventCritCodeID IS NOT NULL) OR
								(
									(MVD.EventCritCodeID IS NULL) AND
									(
										ISNULL(VCCA.BitClaimAttribsAllowed, 0) > 0 OR
										ISNULL(VCCA.BitClaimAttribsDenied, 0) > 0 OR
										ISNULL(VST.BitClaimSrcTypesAllowed, 0) > 0 OR
										ISNULL(VST.BitClaimSrcTypesDenied, 0) > 0 OR
										ISNULL(VCS.BitSpecialtiesAllowed, 0) > 0 OR
										ISNULL(VCS.BitSpecialtiesDenied, 0) > 0 
									)
								)
							)
					ORDER BY CodeID, EventID, OptionNbr, EventCritID;
			
					SET @CountRecords = ISNULL(@CountRecords, 0) + @@ROWCOUNT;
				END
			ELSE
				SET @CountRecords = 0;

			SET @LogDescr = ' - Setting of active batch event key for BATCH ' + ISNULL(CAST(@BatchID AS varchar), '?') + ' succeeded.'; 
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
			SET @LogDescr = 'Setting of active batch event key for BATCH ' + ISNULL(CAST(@BatchID AS varchar), '?') + ' refresh failed!'; --{FAILURE LOG DESCRIPTION HERE}
			
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
GRANT VIEW DEFINITION ON  [Batch].[SetActiveBatchEventKey] TO [db_executer]
GO
GRANT EXECUTE ON  [Batch].[SetActiveBatchEventKey] TO [db_executer]
GO
GRANT EXECUTE ON  [Batch].[SetActiveBatchEventKey] TO [Processor]
GO
