SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 3/7/2012
-- Description:	(Revised) Combines claims based on their "attributes". (v3)
--				(This version further increases performance and breaks the procedure into three parts:
--				 - Batch.ApplyClaimUpdates
--				 - Batch.CombineClaims
--				 - Batch.IdentifyClaimAttributes)
-- =============================================
CREATE PROCEDURE [Batch].[CombineClaims_v3]
(
	@BatchID int
)
WITH RECOMPILE
AS
BEGIN
	SET NOCOUNT ON;
		
	--Settings @IsDebug = 1 outputs the key temp tables used in this process
	DECLARE @IsDebug bit;
	SET @IsDebug = 0;	
	
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
		SET @LogObjectName = 'CombineClaims'; 
		SET @LogObjectSchema = 'Batch'; 
		
		BEGIN TRY;
				
			IF @BatchID IS NULL
				RAISERROR(' - Combining claims failed!  No batch was specified.', 16, 1);
				
			DECLARE @CountRecords bigint;
			DECLARE @EDCombineDays smallint;
			
			SELECT	@BeginInitSeedDate = DR.BeginInitSeedDate,
					@CountRecords = 0,
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
			
			SELECT	@EDCombineDays = EDCombineDays FROM Batch.DataOwners WHERE OwnerID = @OwnerID;
			
			DECLARE @ClaimTypeE tinyint;
			DECLARE @ClaimTypeL tinyint;
			DECLARE @ClaimTypeP tinyint;

			SELECT @ClaimTypeE = ClaimTypeID FROM Claim.ClaimTypes WHERE Abbrev = 'E';
			SELECT @ClaimTypeL = ClaimTypeID FROM Claim.ClaimTypes WHERE Abbrev = 'L';
			SELECT @ClaimTypeP = ClaimTypeID FROM Claim.ClaimTypes WHERE Abbrev = 'P';
			
			DECLARE @ClaimAttribIN smallint;
			DECLARE @ClaimAttribAIN smallint;
			DECLARE @ClaimAttribNIN smallint;
			DECLARE @ClaimAttribED smallint;
			DECLARE @ClaimAttribOUT smallint;

			SELECT @ClaimAttribIN = ClaimAttribID FROM Claim.Attributes WHERE Abbrev = 'IN';
			SELECT @ClaimAttribAIN = ClaimAttribID FROM Claim.Attributes WHERE Abbrev = 'AIN';
			SELECT @ClaimAttribNIN = ClaimAttribID FROM Claim.Attributes WHERE Abbrev = 'NIN';
			SELECT @ClaimAttribED = ClaimAttribID FROM Claim.Attributes WHERE Abbrev = 'ED';
			SELECT @ClaimAttribOUT = ClaimAttribID FROM Claim.Attributes WHERE Abbrev = 'OUT';

			--Determines the current state of ANSI_WARNINGS and sets it to "OFF" if necessary (Prevents NULL aggregate messages during the INSERT statement)...
			DECLARE @Ansi_Warnings bit;
			SET @Ansi_Warnings = CASE WHEN (@@OPTIONS & 8) = 8 THEN 1 ELSE 0 END;

			IF @Ansi_Warnings = 0
				SET ANSI_WARNINGS ON;
			
						IF OBJECT_ID('tempdb..#ClaimLinesBase') IS NOT NULL
				DROP TABLE #ClaimLinesBase;

			--1) Summarize claim line attributes...
			SELECT	CCL.BeginDate,
					CCL.BeginDate AS CalcBeginDate,
					ISNULL(DATEADD(day, -2, CCL.EndDate), CCL.BeginDate) AS CalcEndDate,
					CONVERT(bigint, NULL) AS DSClaimID,
					CCL.DSClaimLineID,
					CCL.DSMemberID,
					CCL.DSProviderID,
					CCL.EndDate,
					MAX(CONVERT(tinyint, CASE WHEN CCA.ClaimAttribID = @ClaimAttribAIN THEN 1 ELSE 0 END)) AS IsAIN,
					MAX(CONVERT(tinyint, CASE WHEN CCA.ClaimAttribID = @ClaimAttribED THEN 1 ELSE 0 END)) AS IsED,
					MAX(CONVERT(tinyint, CASE WHEN CCA.ClaimAttribID = @ClaimAttribIN THEN 1 ELSE 0 END)) AS IsIN,
					MAX(CONVERT(tinyint, CASE WHEN CCA.ClaimAttribID = @ClaimAttribNIN THEN 1 ELSE 0 END)) AS IsNIN,
					MAX(CONVERT(tinyint, CASE WHEN CCA.ClaimAttribID = @ClaimAttribOUT THEN 1 ELSE 0 END)) AS IsOUT,
					MAX(CONVERT(tinyint, CASE WHEN CCA.DSClaimAttribID IS NULL THEN 1 ELSE 0 END)) AS IsUnknown,
					MIN(CCL.DSClaimID) AS OrigDSClaimID,
					IDENTITY(bigint, 1, 1) AS RowID
			INTO	#ClaimLinesBase
			FROM	Proxy.ClaimLines AS CCL
					LEFT OUTER JOIN Proxy.ClaimAttributes AS CCA
							ON CCL.DataSetID = CCA.DataSetID AND
								CCL.DSClaimLineID = CCA.DSClaimLineID AND
								CCL.DSMemberID = CCA.DSMemberID
			WHERE	CCL.DataSetID = @DataSetID AND
					CCL.ClaimTypeID = @ClaimTypeE
			GROUP BY CCL.BeginDate,
					CCL.DSClaimLineID,
					CCL.DSMemberID,
					CCL.DSProviderID,
					CCL.EndDate
			ORDER BY DSMemberID, CalcEndDate;

			DECLARE @MaxDate datetime;
			DECLARE @MinDate datetime;
			SELECT @MaxDate = MAX(CalcEndDate), @MinDate = MIN(CalcBeginDate) FROM #ClaimLinesBase;

			CREATE UNIQUE CLUSTERED INDEX IX_#ClaimLinesBase ON #ClaimLinesBase (DSMemberID, CalcEndDate, CalcBeginDate, DSProviderID, RowID) WITH (FILLFACTOR = 100);
			CREATE STATISTICS ST_#ClaimLinesBase ON #ClaimLinesBase (DSMemberID, CalcEndDate, CalcBeginDate, DSProviderID, RowID);


			--2) Further summarize claim line attributes by member and date for Oupatient Claims only...
			IF OBJECT_ID('tempdb..#OutpatientClaims') IS NOT NULL
				DROP TABLE #OutpatientClaims;

			SELECT	CalcBeginDate,
					CalcEndDate,
					MIN(DSClaimLineID) AS DSClaimID,
					DSMemberID,
					DSProviderID
			INTO	#OutpatientClaims
			FROM	#ClaimLinesBase
			WHERE	IsOUT = 1
			GROUP BY CalcBeginDate,
					CalcEndDate,
					DSMemberID,
					DSProviderID;
					
			CREATE UNIQUE CLUSTERED INDEX IX_#OutpatientClaims ON #OutpatientClaims (DSMemberID, CalcEndDate, CalcBeginDate, DSProviderID) WITH (FILLFACTOR = 100);
			CREATE STATISTICS ST_#OutpatientClaims ON #OutpatientClaims (DSMemberID, CalcEndDate, CalcBeginDate, DSProviderID);

			UPDATE	CLB
			SET		DSClaimID = OC.DSClaimID
			FROM	#ClaimLinesBase AS CLB
					INNER JOIN #OutpatientClaims AS OC
							ON CLB.CalcBeginDate = OC.CalcBeginDate AND
								CLB.CalcEndDate = OC.CalcEndDate AND
								CLB.DSMemberID = OC.DSMemberID AND
								CLB.DSProviderID = OC.DSProviderID
			WHERE	(CLB.DSClaimID IS NULL) AND
					(
						(
							(CLB.IsAIN = 0) AND
							(CLB.IsED = 0) AND
							(CLB.IsIN = 0) AND
							(CLB.IsNIN = 0) AND
							(CLB.IsOUT = 1)
						) OR
						(CLB.IsUnknown = 1)
					);


			--3a) Further summarize claim line attributes by member and date for ED and Inpatient Claims only...
			IF OBJECT_ID('tempdb..#InpatientClaimLinesByDay') IS NOT NULL
				DROP TABLE #InpatientClaimLinesByDay;

			SELECT	C.D AS CalcDate,
					COUNT(DISTINCT t.DSClaimLineID) AS CountLines,
					CONVERT(bigint, NULL) AS DSClaimID,
					MIN(CASE WHEN t.IsAIN = 1 THEN t.DSClaimLineID END) AS DSClaimLineAIN,
					COALESCE(MIN(CASE WHEN t.IsAIN = 1 THEN t.DSClaimLineID END),
							 MIN(CASE WHEN t.IsNIN = 1 THEN t.DSClaimLineID END),
							 MIN(CASE WHEN t.IsIN = 1 THEN t.DSClaimLineID END),
							 MIN(CASE WHEN t.IsED = 1 THEN t.DSClaimLineID END)) AS DSClaimLineID,
					MIN(CASE WHEN t.IsAIN = 0 AND t.IsNIN = 0 AND t.IsIN = 1 THEN t.DSClaimLineID END) AS DSClaimLineIN,
					MIN(CASE WHEN t.IsNIN = 1 THEN t.DSClaimLineID END) AS DSClaimLineNIN,				
					t.DSMemberID,
					CONVERT(smallint, CASE 
										WHEN MAX(t.IsAIN) = 1 
										THEN 1
										WHEN MAX(t.IsNIN) = 1
										THEN 0
										WHEN MAX(t.IsIN) = 1
										THEN -1
										END) AS InpatientType,
					MAX(t.IsAIN) AS IsAIN,
					MAX(t.IsED) AS IsED,
					MAX(t.IsIN) AS IsIN,
					MAX(t.IsNIN) AS IsNIN,
					MAX(t.IsOUT) AS IsOUT,
					CONVERT(datetime, NULL) AS LastInpatientDate,
					CONVERT(bigint, NULL) AS LastInpatientAIN,
					CONVERT(bigint, NULL) AS LastInpatientID,
					CONVERT(bigint, NULL) AS LastInpatientIN,
					CONVERT(bigint, NULL) AS LastInpatientNIN,
					--MAX(t.DSClaimLineID) AS MaxDSClaimLineID,
					--MIN(t.DSClaimLineID) AS MinDSClaimLineID,
					IDENTITY(bigint, 1, 1) AS RowID
			INTO	#InpatientClaimLinesByDay
			FROM	#ClaimLinesBase AS t
					INNER JOIN dbo.Calendar AS C
							ON C.D BETWEEN t.CalcBeginDate AND t.CalcEndDate
			WHERE	(C.D BETWEEN @MinDate AND @MaxDate) AND
					(
						(t.IsAIN = 1) OR
						(t.IsED = 1) OR
						(t.IsIN = 1) OR
						(t.IsNIN = 1)
					)
			GROUP BY C.D, t.DSMemberID
			--Do not change order, used for "Quirky" UPDATE...
			ORDER BY DSMemberID, CalcDate DESC;

			CREATE UNIQUE CLUSTERED INDEX IX_#InpatientClaimLinesByDay ON #InpatientClaimLinesByDay (RowID) WITH (FILLFACTOR = 100);
			CREATE STATISTICS ST_#InpatientClaimLinesByDay ON #InpatientClaimLinesByDay (RowID);


			--3b) Identify ED & Inpatient claims to combine (using "Quirky" UPDATE)...
			DECLARE @DSClaimID bigint;
			DECLARE @LastDate datetime;
			DECLARE @LastInpatientDate datetime;
			DECLARE @LastInpatientAIN bigint;
			DECLARE @LastInpatientID bigint;
			DECLARE @LastInpatientIN bigint;
			DECLARE @LastInpatientNIN bigint;
			DECLARE @LastInpatientType smallint;
			DECLARE @LastMemberID bigint;

			UPDATE	t
			SET		@LastInpatientDate = LastInpatientDate = CASE WHEN @LastMemberID = DSMemberID THEN @LastInpatientDate END,
					@LastInpatientAIN = LastInpatientAIN = CASE WHEN @LastMemberID = DSMemberID AND DATEDIFF(day, CalcDate, @LastDate) <= 1 THEN @LastInpatientAIN END,
					@LastInpatientID = LastInpatientID = CASE WHEN @LastMemberID = DSMemberID THEN @LastInpatientID END,
					@LastInpatientIN = LastInpatientIN = CASE WHEN @LastMemberID = DSMemberID AND DATEDIFF(day, CalcDate, @LastDate) <= 1 THEN @LastInpatientIN END,
					@LastInpatientNIN = LastInpatientNIN = CASE WHEN @LastMemberID = DSMemberID AND DATEDIFF(day, CalcDate, @LastDate) <= 1 THEN @LastInpatientNIN END,
					@DSClaimID = DSClaimID = COALESCE(CASE 
														--Identify ED Visit Leading to Inpatient Stays
														WHEN @DSClaimID IS NOT NULL AND
															 ISNULL(@LastMemberID, DSMemberID) = DSMemberID AND	
															 DATEDIFF(day, CalcDate, @LastInpatientDate) <= @EDCombineDays AND
															 IsED = 1 AND
															 (
																(InpatientType IS NULL) OR 
																(
																	(@LastInpatientType = 1) AND
																	(InpatientType IN (-1, 0))
																)
															 )
														THEN @LastInpatientID
														
														--Identify Continued Inpatient Stays
														WHEN @DSClaimID IS NOT NULL AND
															 ISNULL(@LastMemberID, DSMemberID) = DSMemberID AND
															 DATEDIFF(day, CalcDate, @LastDate) <= 1 AND
															(
																(InpatientType = @LastInpatientType) OR
																(InpatientType = -1 AND @LastInpatientType IS NOT NULL)
															)
														THEN @DSClaimID
														
														WHEN IsAIN = 1 
														THEN @LastInpatientAIN
														
														WHEN IsNIN = 1 
														THEN @LastInpatientNIN
														
														WHEN IsIN = 1 
														THEN @LastInpatientIN
														END,
														DSClaimLineID),		
					@LastDate = CalcDate,
					@LastInpatientDate = CASE WHEN IsAIN = 1 OR IsIN = 1 OR IsNIN = 1 THEN CalcDate ELSE @LastInpatientDate END,
					@LastInpatientAIN = CASE WHEN IsAIN = 1 THEN ISNULL(@LastInpatientAIN, DSClaimLineAIN) END,
					@LastInpatientID = CASE WHEN IsAIN = 1 OR IsIN = 1 OR IsNIN = 1 THEN @DSClaimID ELSE @LastInpatientID END,
					@LastInpatientIN = CASE WHEN IsIN = 1 THEN ISNULL(@LastInpatientIN, DSClaimLineIN) END,
					@LastInpatientNIN = CASE WHEN IsNIN = 1 THEN ISNULL(@LastInpatientNIN, DSClaimLineNIN) END,
					@LastInpatientType = COALESCE(CASE 
														--COPIED FROM: Identify ED Visit Leading to Inpatient Stays
														WHEN @DSClaimID IS NOT NULL AND
															 ISNULL(@LastMemberID, DSMemberID) = DSMemberID AND	
															 DATEDIFF(day, CalcDate, @LastInpatientDate) <= @EDCombineDays AND
															 IsED = 1 AND
															 (
																(InpatientType IS NULL) OR 
																(
																	(@LastInpatientType = 1) AND
																	(InpatientType IN (-1, 0))
																)
															 )
														THEN @LastInpatientType
														END,
														InpatientType),
					@LastMemberID = DSMemberID
			FROM	#InpatientClaimLinesByDay AS t
			OPTION (MAXDOP 1);

			-- 3c) Update #ClaimLinesBase with the DSClaimID for inpatient/ED visits
			IF OBJECT_ID('tempdb..#InpatientClaims') IS NOT NULL
				DROP TABLE #InpatientClaims;

			SELECT	MIN(CalcDate) AS BeginDate,
					DSClaimID,
					DSMemberID,
					MAX(IsAIN) AS IsAIN,
					MAX(IsED) AS IsED,
					MAX(IsIN) AS IsIN,
					MAX(IsNIN) AS IsNIN,
					MAX(CalcDate) AS EndDate
			INTO	#InpatientClaims
			FROM	#InpatientClaimLinesByDay
			GROUP BY DSClaimID, DSMemberID;

			CREATE INDEX IX_#InpatientClaims ON #InpatientClaims (DSMemberID, EndDate, BeginDate) WITH (FILLFACTOR = 100);
			CREATE STATISTICS ST_#InpatientClaims ON #InpatientClaims (DSMemberID, EndDate, BeginDate);

			UPDATE	CLB
			SET		DSClaimID = IC.DSClaimID
			FROM	#ClaimLinesBase AS CLB
					INNER JOIN #InpatientClaims AS IC
							ON CLB.DSMemberID = IC.DSMemberID AND
								CLB.CalcBeginDate BETWEEN IC.BeginDate AND IC.EndDate AND
								CLB.CalcEndDate BETWEEN IC.BeginDate AND IC.EndDate
			WHERE	(CLB.DSClaimID IS NULL) AND
					(
						(CLB.IsAIN = 1) OR 
						(
							(CLB.IsIN = 1) AND 
							(CLB.IsNIN = 0)
						) OR 
						(CLB.IsED = 1) OR
						(CLB.IsUnknown = 1)
					) AND 
					(IC.IsAIN = 1);
								
			UPDATE	CLB
			SET		DSClaimID = IC.DSClaimID
			FROM	#ClaimLinesBase AS CLB
					INNER JOIN #InpatientClaims AS IC
							ON CLB.DSMemberID = IC.DSMemberID AND
								CLB.CalcBeginDate BETWEEN IC.BeginDate AND IC.EndDate AND
								CLB.CalcEndDate BETWEEN IC.BeginDate AND IC.EndDate
			WHERE	(CLB.DSClaimID IS NULL) AND
					(
						(CLB.IsNIN = 1) OR 
						(CLB.IsIN = 1) OR 
						(CLB.IsED = 1) OR
						(CLB.IsUnknown = 1)
					) AND 
					(IC.IsNIN = 1);

			UPDATE	CLB
			SET		DSClaimID = IC.DSClaimID
			FROM	#ClaimLinesBase AS CLB
					INNER JOIN #InpatientClaims AS IC
							ON CLB.DSMemberID = IC.DSMemberID AND
								CLB.CalcBeginDate BETWEEN IC.BeginDate AND IC.EndDate AND
								CLB.CalcEndDate BETWEEN IC.BeginDate AND IC.EndDate
			WHERE	(CLB.DSClaimID IS NULL) AND
					(
						(CLB.IsIN = 1) OR 
						(CLB.IsED = 1) OR
						(CLB.IsUnknown = 1)
					) AND 
					(IC.IsIN = 1);
					
			--4) Create composite claim key for applying to actual claims...
			IF OBJECT_ID('tempdb..#ClaimKey') IS NOT NULL
				DROP TABLE #ClaimKey;
					
			SELECT DISTINCT
					ISNULL(DSClaimID, DSClaimLineID) AS DSClaimID,
					DSClaimLineID
			INTO	#ClaimKey
			FROM	#ClaimLinesBase;
			
			CREATE UNIQUE CLUSTERED INDEX IX_#ClaimKey ON #ClaimKey (DSClaimLineID) WITH (FILLFACTOR = 100);
			CREATE STATISTICS ST_#ClaimKey ON #ClaimKey (DSClaimLineID);
			
			--------------------------------------------------------------------------------------------
			--5) If Debug, Output key temp tables...
			IF ISNULL(@IsDebug, 0) = 1
				BEGIN;
					--5a) #ClaimLinesBase
					IF OBJECT_ID('Temp.Batch_CombineClaims_ClaimLinesBase') IS NOT NULL	
						DROP TABLE Temp.Batch_CombineClaims_ClaimLinesBase;
						
					SELECT * INTO Temp.Batch_CombineClaims_ClaimLinesBase FROM #ClaimLinesBase;
					
					--5b) #OutpatientClaims
					IF OBJECT_ID('Temp.Batch_CombineClaims_OutpatientClaims') IS NOT NULL	
						DROP TABLE Temp.Batch_CombineClaims_OutpatientClaims;
						
					SELECT * INTO Temp.Batch_CombineClaims_OutpatientClaims FROM #OutpatientClaims;
					
					--5c) #InpatientClaimLinesByDay
					IF OBJECT_ID('Temp.Batch_CombineClaims_InpatientClaimLinesByDay') IS NOT NULL	
						DROP TABLE Temp.Batch_CombineClaims_InpatientClaimLinesByDay;
						
					SELECT * INTO Temp.Batch_CombineClaims_InpatientClaimLinesByDay FROM #InpatientClaimLinesByDay;
					
					--5d) #InpatientClaims
					IF OBJECT_ID('Temp.Batch_CombineClaims_InpatientClaims') IS NOT NULL	
						DROP TABLE Temp.Batch_CombineClaims_InpatientClaims;
						
					SELECT * INTO Temp.Batch_CombineClaims_InpatientClaims FROM #InpatientClaims;
					
					--5e) #ClaimKey
					IF OBJECT_ID('Temp.Batch_CombineClaims_ClaimKey') IS NOT NULL	
						DROP TABLE Temp.Batch_CombineClaims_ClaimKey;
						
					SELECT * INTO Temp.Batch_CombineClaims_ClaimKey FROM #ClaimKey;
				END;
			--------------------------------------------------------------------------------------------

			--6) Apply DSClaimIDs to the Proxy claims tables...
			--UPDATE Claim Lines with DSClaimID------------------
			UPDATE	TCL
			SET		DSClaimID = ISNULL(t.DSClaimID, TCL.DSClaimLineID)
			FROM	Proxy.ClaimLines AS TCL
					LEFT OUTER JOIN #ClaimKey AS t
							ON TCL.DSClaimLineID = t.DSClaimLineID
			WHERE	(TCL.DSClaimID IS NULL);

			--UPDATE Claim Codes with DSClaimID-----------------
			UPDATE	TCC
			SET		DSClaimID = ISNULL(t.DSClaimID, TCC.DSClaimLineID)
			FROM	Proxy.ClaimCodes AS TCC
					LEFT OUTER JOIN #ClaimKey AS t
							ON TCC.DSClaimLineID = t.DSClaimLineID
			WHERE	(TCC.DSClaimID IS NULL);

			--INSERT Final Claims-------------------------------
			DELETE FROM Proxy.Claims;
			
			INSERT INTO Proxy.Claims
					(BatchID, BeginDate, ClaimTypeID, DataRunID, DataSetID, DSClaimID, DSMemberID,
					DSProviderID, EndDate, LOS, POS, ServDate)  
			SELECT	@BatchID,
					MIN(BeginDate), 
					ClaimTypeID,
					@DataRunID,
					@DataSetID,
					DSClaimID, 
					DSMemberID,
					CASE WHEN COUNT(DISTINCT DSProviderID) = 1 THEN MIN(DSProviderID) END AS DSProviderID,
					MAX(EndDate),
					NULL,
					CASE WHEN COUNT(DISTINCT POS) = 1 THEN MIN(POS) END AS POS,
					CASE WHEN COUNT(DISTINCT ServDate) = 1 THEN MIN(ServDate) ELSE MIN(BeginDate) END AS ServDate
			FROM	Proxy.ClaimLines AS TCL
			WHERE	(TCL.DSClaimID IS NOT NULL)
			GROUP BY ClaimTypeID, DSClaimID, DSMemberID;
			
			SELECT @CountRecords = ISNULL(@CountRecords, 0) + @@ROWCOUNT;

			--UPDATE Event Base with DSClaimID-------------------
			UPDATE	VB
			SET		DSClaimID = t.DSClaimID 
			FROM	Proxy.EventBase AS VB
					INNER JOIN Proxy.ClaimLines AS t
							ON VB.DSClaimLineID = t.DSClaimLineID
			WHERE	VB.DSClaimID IS NULL;
			
			IF @Ansi_Warnings = 1
				SET ANSI_WARNINGS ON;
			ELSE
				SET ANSI_WARNINGS OFF;
						
			SET @LogDescr = ' - Combining claims for BATCH ' + ISNULL(CAST(@BatchID AS varchar), '?') + ' succeeded.'; 
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
			SET @LogDescr = ' - Combining claims for BATCH ' + ISNULL(CAST(@BatchID AS varchar), '?') + ' refresh failed!'; --{FAILURE LOG DESCRIPTION HERE}
			
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
GRANT EXECUTE ON  [Batch].[CombineClaims_v3] TO [Processor]
GO
