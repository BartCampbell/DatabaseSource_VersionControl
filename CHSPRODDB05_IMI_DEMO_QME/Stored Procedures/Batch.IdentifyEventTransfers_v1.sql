SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 1/28/2011
-- Description:	Updates event data from matched transfers. (v1)
-- =============================================
CREATE PROCEDURE [Batch].[IdentifyEventTransfers_v1]
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
	
	DECLARE @BeginInitSeedDate datetime;
	DECLARE @DataRunID int;
	DECLARE @DataSetID int;
	DECLARE @EndInitSeedDate datetime;
	DECLARE @IsLogged bit;
	DECLARE @MeasureSetID int;
	DECLARE @OwnerID int;
	DECLARE @SeedDate datetime;
	
	DECLARE @Result int;
	
		BEGIN TRY;
		
		SET @LogBeginTime = GETDATE();
		SET @LogObjectName = 'IdentifyEventTransfers'; 
		SET @LogObjectSchema = 'Batch'; 
		
		BEGIN TRY;
				
			IF @BatchID IS NULL
				RAISERROR(' - Identifying event transfers failed!  No batch was specified.', 16, 1);
				
			DECLARE @CountRecords bigint;
			
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
			
			DECLARE @CountResults bigint;

			CREATE TABLE #Transfers
			(
				DSMemberID bigint NOT NULL,
				EventXferID int NOT NULL,
				FromBeginDate datetime NOT NULL,
				FromDSClaimLineID bigint NOT NULL,
				FromEndDate datetime NOT NULL,
				FromEventID int NOT NULL,
				FromEventBaseID bigint NOT NULL,
				ToBeginDate datetime NOT NULL,
				ToDSClaimLineID bigint NOT NULL,
				ToEndDate datetime NOT NULL,
				ToEventID int NOT NULL,
				ToEventBaseID bigint NOT NULL
			);
			
			CREATE TABLE #TransferCorrectDates
			(
				FromBeginDate datetime NOT NULL,
				FromEventBaseID bigint NOT NULL,
				ToEndDate datetime NOT NULL
			);

			DECLARE @i int;

			WHILE 1 = 1
				BEGIN

					INSERT INTO #Transfers 
					SELECT	TV.DSMemberID,
							MVT.EventXferID, 
							TV.BeginDate AS FromBeginDate,
							COALESCE(TV.XferID, TV.DSClaimLineID, TV.DSClaimID) AS FromDSClaimLineID,
							TV.EndDate AS FromEndDate,
							MVT.FromEventID,
							ISNULL(TV.XferID, TV.EventBaseID) AS FromEventBaseID,
							t.BeginDate AS ToBeginDate,
							COALESCE(t.DSClaimLineID, t.DSClaimID) AS ToDSClaimLineID,
							t.EndDate AS ToEndDate,
							MVT.ToEventID,
							t.EventBaseID AS ToEventBaseID
					FROM	Proxy.[Events] AS TV
							INNER JOIN Measure.EventTransfers AS MVT
									ON TV.EventID = MVT.FromEventID AND
										TV.EndDate IS NOT NULL
							INNER JOIN Proxy.[Events] AS t
									ON MVT.ToEventID = t.EventID AND
										TV.EventBaseID <> t.EventBaseID AND
										TV.DSMemberID = t.DSMemberID AND
										t.BeginDate BETWEEN DATEADD(mm, MVT.BeginMonths, DATEADD(dd, MVT.BeginDays, TV.EndDate)) AND 
															DATEADD(mm, MVT.EndMonths, DATEADD(dd, MVT.EndDays, TV.EndDate)) AND
										TV.EndDate < t.EndDate;
					
					SET @CountResults = ISNULL(@CountResults, 0) + @@ROWCOUNT;

					--DELETE FROM #Transfers WHERE FromDSClaimLineID IN (SELECT DISTINCT ToDSClaimLineID FROM #Transfers);
					DELETE FROM #Transfers WHERE FromEventBaseID IN (SELECT DISTINCT ToEventBaseID FROM #Transfers);
					
					SET @CountResults = ISNULL(@CountResults, 0) - @@ROWCOUNT;
					
					
					INSERT INTO #TransferCorrectDates
					SELECT	MIN(FromBeginDate) AS FromBeginDate,
							FromEventBaseID, 
							MAX(ToEndDate) AS ToEndDate
					FROM	#Transfers
					GROUP BY FromEventBaseID;
					
					CREATE CLUSTERED INDEX IX_#TransferCorrectDates ON #TransferCorrectDates (FromEventBaseID);
					
					UPDATE	X
					SET		FromBeginDate = XDC.FromBeginDate,
							ToEndDate = XDC.ToEndDate
					FROM	#Transfers AS X
							INNER JOIN #TransferCorrectDates AS XDC
									ON X.FromEventBaseID = XDC.FromEventBaseID;
									
					DROP INDEX IX_#TransferCorrectDates ON #TransferCorrectDates;
					TRUNCATE TABLE #TransferCorrectDates;
					
					
					--Apply From-side Transfer Info
					UPDATE	TV
					SET		BeginDate = X.FromBeginDate,
							EndDate = X.ToEndDate,
							IsXfer = 1,
							XferID = X.FromEventBaseID 
					FROM	Proxy.[Events] AS TV
							INNER JOIN #Transfers AS X
									ON TV.EventBaseID = X.FromEventBaseID;
					
					UPDATE	TV
					SET		BeginDate = X.FromBeginDate,
							EndDate = X.ToEndDate,
							IsXfer = 1,
							XferID = X.FromEventBaseID 
					FROM	Proxy.[Events] AS TV
							INNER JOIN #Transfers AS X
									ON TV.XferID = X.FromEventBaseID
					WHERE	(TV.XferID IS NOT NULL);
					
					--Apply To-side	Transfer Info
					UPDATE	TV
					SET		BeginDate = X.FromBeginDate,
							EndDate = X.ToEndDate,
							IsXfer = 1,
							XferID = CASE WHEN TV.XferID IS NULL 
												THEN X.FromEventBaseID 
												ELSE TV.XferID 
												END
					FROM	Proxy.[Events] AS TV
							INNER JOIN #Transfers AS X
									ON TV.EventBaseID = X.ToEventBaseID;
									
					
									
					SET @CountRecords = ISNULL(@CountRecords, 0) + @CountResults;
					
					SET @i = ISNULL(@i, 0) + 1;
					
					IF @CountResults <= 0 OR 
						@i > 48 --Prevents infinite loop
						BREAK;
					ELSE
						BEGIN
							SET @CountResults = 0;		
							TRUNCATE TABLE #Transfers;
						END 
				END;
						
			SET @LogDescr = ' - Identifying event transfers for BATCH ' + ISNULL(CAST(@BatchID AS varchar), '?') + ' succeeded.'; 
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
			SET @LogDescr = 'Identifying event transfers for BATCH ' + ISNULL(CAST(@BatchID AS varchar), '?') + ' refresh failed!'; --{FAILURE LOG DESCRIPTION HERE}
			
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
GRANT VIEW DEFINITION ON  [Batch].[IdentifyEventTransfers_v1] TO [db_executer]
GO
GRANT EXECUTE ON  [Batch].[IdentifyEventTransfers_v1] TO [db_executer]
GO
GRANT EXECUTE ON  [Batch].[IdentifyEventTransfers_v1] TO [Processor]
GO
