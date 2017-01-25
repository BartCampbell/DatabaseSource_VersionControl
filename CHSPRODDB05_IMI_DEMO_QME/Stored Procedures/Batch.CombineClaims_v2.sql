SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 1/4/2012
-- Description:	(Revised) Combines claims and updates claim information across claim tables. (v2)
-- =============================================
CREATE PROCEDURE [Batch].[CombineClaims_v2]
(
	@BatchID int
)
WITH RECOMPILE
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
		SET @LogObjectName = 'CombineClaims'; 
		SET @LogObjectSchema = 'Batch'; 
		
		BEGIN TRY;
				
			IF @BatchID IS NULL
				RAISERROR(' - Combining claims failed!  No batch was specified.', 16, 1);
				
			DECLARE @CountRecords int;
			DECLARE @EDCombineDays smallint;
			
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

			IF OBJECT_ID('tempdb..#EventOptions') IS NOT NULL
				DROP TABLE #EventOptions;

			DECLARE @CreateIndexSql nvarchar(MAX);
			DECLARE @CreateStatisticSql nvarchar(MAX);
			DECLARE @DropIndexSql nvarchar(MAX);
			DECLARE @DropStatisticSql nvarchar(MAX);
			
			SET @CreateIndexSql =		'CREATE NONCLUSTERED INDEX IX_temporary_EventBase_forBatch' + CONVERT(nvarchar(MAX), @BatchID) + ' ' +
										'ON Internal.EventBase (EventID ASC, EventBaseID ASC, OptionNbr ASC) ' + 
										'INCLUDE (Allow, BeginDate, ClaimTypeID, CodeID, CountAllowed, DSClaimID, DSClaimLineID, DSMemberID, DSProviderID, EndDate, EventCritID) ' + 
										'WHERE (BatchID = ' + CONVERT(nvarchar(MAX), @BatchID) + ') ' + 
										'WITH (ONLINE = ON);';
									
			SET @CreateStatisticSql =	'CREATE STATISTICS ST_temporary_EventBase_forBatch' + CONVERT(nvarchar(MAX), @BatchID) + ' ' +
										'ON Internal.EventBase (EventID, EventBaseID, OptionNbr) ' +
										'WHERE (BatchID = ' + CONVERT(nvarchar(MAX), @BatchID) + ');'
									
			SET @DropIndexSql =			'DROP INDEX IX_temporary_EventBase_forBatch' + CONVERT(nvarchar(MAX), @BatchID) + ' ' +
										'ON Internal.EventBase;';

			SET @DropStatisticSql =		'DROP STATISTICS Internal.EventBase.ST_temporary_EventBase_forBatch' + CONVERT(nvarchar(MAX), @BatchID) + ';';

			--Determines the current state of ANSI_WARNINGS and sets it to "OFF" if necessary (Prevents NULL aggregate messages during the INSERT statement)...
			DECLARE @Ansi_Warnings bit;
			SET @Ansi_Warnings = CASE WHEN (@@OPTIONS & 8) = 8 THEN 1 ELSE 0 END;

			IF @Ansi_Warnings = 0
				SET ANSI_WARNINGS ON;

			EXEC (@CreateIndexSql);
			EXEC (@CreateStatisticSql);

			--Determine Temp.EventBase results...
			SELECT	@BatchID AS BatchID,
					MIN(BeginDate) AS BeginDate,
					MIN(ClaimTypeID) AS ClaimTypeID,
					MIN(CodeID) AS CodeID,
					MIN(DSClaimID) AS DSClaimID,
					MIN(DSClaimLineID) AS DSClaimLineID,
					MIN(DSMemberID) AS DSMemberID,
					MIN(DSProviderID) AS DSProviderID,
					MAX(EndDate) AS EndDate,
					EventBaseID,
					EventID,
					OptionNbr AS OptionNbr
			INTO	#EventOptions
			FROM	Proxy.EventBase 
			WHERE	(BatchID = @BatchID) AND
					(EventID IN (SELECT DISTINCT VCA.EventID FROM Measure.EventsToClaimAttributes AS VCA))
			GROUP BY EventBaseID,
					EventID,
					OptionNbr 
			HAVING	(COUNT(DISTINCT CASE WHEN Allow = 1 THEN EventCritID END) >= MAX(CountAllowed)) AND
					(COUNT(DISTINCT CASE WHEN Allow = 0 THEN EventCritID END) = 0)
			ORDER BY EventBaseID;
				
			SET ANSI_WARNINGS ON;
								
			EXEC (@DropIndexSql);
			EXEC (@DropStatisticSql)			

			SET ANSI_WARNINGS OFF;
								
			CREATE UNIQUE CLUSTERED INDEX IX_#EventOptions ON #EventOptions (EventID ASC, OptionNbr ASC, EventBaseID ASC);
			CREATE STATISTICS ST_#EventOptions ON #EventOptions (EventID, OptionNbr, EventBaseID);
								
			--Use results to identify Claim Attributes...
			IF OBJECT_ID('tempdb..#ClaimLineAttribs') IS NOT NULL
				DROP TABLE #ClaimLineAttribs;
				
			SELECT DISTINCT
					AllowEndDate,
					BeginDate,
					EndDate,
					EventID,
					RequireEndDate
			INTO	#DateEventReqs
			FROM	Proxy.EventKey;
			
			CREATE UNIQUE CLUSTERED INDEX IX_#DateEventReqs ON #DateEventReqs (EventID, BeginDate, EndDate, AllowEndDate, RequireEndDate);
			CREATE STATISTICS ST_#DateEventReqs ON #DateEventReqs (EventID, BeginDate, EndDate, AllowEndDate, RequireEndDate);
				
			SELECT DISTINCT
					V.DSClaimLineID, V.EventID
			INTO	#ClaimLineEvents
			FROM	#DateEventReqs AS DV
					INNER JOIN #EventOptions AS V
							ON DV.EventID = V.EventID AND
								(
									(V.ClaimTypeID <> @ClaimTypeE) OR
									(
										(V.ClaimTypeID = @ClaimTypeE) AND
										(
											(DV.AllowEndDate = 1) OR
											(DV.AllowEndDate = 0 AND V.EndDate IS NULL)
										) AND
										(
											(DV.RequireEndDate = 0) OR
											(DV.RequireEndDate = 1 AND V.EndDate IS NOT NULL)
										) AND
										(
											(DV.BeginDate IS NULL) OR
											(DV.BeginDate IS NOT NULL AND DV.BeginDate <= COALESCE(V.EndDate, V.BeginDate))
										) AND
										(
											(DV.EndDate IS NULL) OR
											(DV.EndDate IS NOT NULL AND DV.EndDate >= COALESCE(V.EndDate, V.BeginDate))
										)
									)
								);
			
			
			CREATE UNIQUE CLUSTERED INDEX IX_#ClaimLineEvents ON #ClaimLineEvents (DSClaimLineID, EventID);
			CREATE STATISTICS ST_#ClaimLineEvents ON #ClaimLineEvents (DSClaimLineID, EventID);
			
			SELECT DISTINCT
					VCA.ClaimAttribID,
					IDENTITY(bigint, 1, 1) AS DSClaimAttribID, 
					CLV.DSClaimLineID 
			INTO	#ClaimLineAttribs
			FROM	#ClaimLineEvents AS CLV
					INNER JOIN Measure.EventsToClaimAttributes AS VCA
							ON CLV.EventID = VCA.EventID 
					INNER JOIN Proxy.ClaimLines AS TCL
							ON CLV.DSClaimLineID = TCL.DSClaimLineID AND
								TCL.DSClaimID IS NULL
					INNER JOIN Claim.Attributes AS CA
							ON VCA.ClaimAttribID = CA.ClaimAttribID AND
								TCL.ClaimTypeID = CA.ClaimTypeID 
			WHERE	(TCL.BatchID = @BatchID);
			
			DROP TABLE #DateEventReqs;
			DROP TABLE #ClaimLineEvents;
									
			--Clean up the #EventOptions temporary table		
			IF OBJECT_ID('tempdb..#EventOptions') IS NOT NULL
				DROP TABLE #EventOptions;
								
			CREATE UNIQUE CLUSTERED INDEX IX_#ClaimLineAttribs ON #ClaimLineAttribs (DSClaimLineID ASC, ClaimAttribID ASC);
			CREATE STATISTICS ST_#ClaimLineAttribs ON #ClaimLineAttribs (DSClaimLineID, ClaimAttribID);
						
			--Create the Claim Line Key used for combining claims 	
			IF OBJECT_ID('tempdb..#ClaimLineKey') IS NOT NULL
				DROP TABLE #ClaimLineKey;
			
			SELECT	CONVERT(datetime, NULL) AS BeginDate,
					DSClaimLineID AS DSClaimID,
					DSClaimLineID,
					CONVERT(bigint, NULL) AS DSMemberID,
					CONVERT(bigint, NULL) AS DSProviderID,
					CONVERT(datetime, NULL) AS EndDate,
					CONVERT(bit, 0) AS IsAcute,
					CONVERT(bit, MAX(CASE WHEN ClaimAttribID = @ClaimAttribED THEN 1 ELSE 0 END)) AS IsED,
					CONVERT(bit, MAX(CASE WHEN ClaimAttribID = @ClaimAttribIN THEN 1 ELSE 0 END)) AS IsInpatient,
					CONVERT(bit, MAX(CASE WHEN ClaimAttribID = @ClaimAttribAIN THEN 1 ELSE 0 END)) AS IsInpatientAcute,
					CONVERT(bit, MAX(CASE WHEN ClaimAttribID = @ClaimAttribNIN THEN 1 ELSE 0 END)) AS IsInpatientNonacute,
					CONVERT(bit, MAX(CASE WHEN ClaimAttribID = @ClaimAttribOUT THEN 1 ELSE 0 END)) AS IsOutpatient,
					CONVERT(bit, 0) AS IsUnknown,
					CONVERT(varchar(2), NULL) AS POS
			INTO	#ClaimLineKey
			FROM	#ClaimLineAttribs AS CLA				
			GROUP BY DSClaimLineID;
			
			UPDATE	CLK
			SET		BeginDate = CCL.BeginDate,
					DSMemberID = CCL.DSMemberID,
					DSProviderID = CCL.DSProviderID,
					EndDate = CCL.EndDate,
					POS = CCL.POS
			FROM	#ClaimLineKey AS CLK
					INNER JOIN Claim.ClaimLines AS CCL
							ON CLK.DSClaimLineID = CCL.DSClaimLineID;
			
			INSERT INTO #ClaimLineKey
			        (BeginDate,
			        DSClaimID,
			        DSClaimLineID,
			        DSMemberID,
			        DSProviderID,
			        EndDate,
			        IsAcute,
					IsED,
					IsInpatient,
					IsInpatientAcute,
					IsInpatientNonacute,
					IsOutpatient,
					IsUnknown,
					POS)
			SELECT	CCL.BeginDate,
					CCL.DSClaimLineID AS DSClaimID,
					CCL.DSClaimLineID,
					CCL.DSMemberID,
					CCL.DSProviderID,
					CCL.EndDate,
					CONVERT(bit, 0) AS IsAcute,
					CONVERT(bit, 0) AS IsED,
					CONVERT(bit, 0) AS IsInpatient,
					CONVERT(bit, 0) AS IsInpatientAcute,
					CONVERT(bit, 0) AS IsInpatientNonacute,
					CONVERT(bit, 0) AS IsOutpatient,
					CONVERT(bit, 1) AS IsUnknown,
					CCL.POS
			FROM	Claim.ClaimLines AS CCL
					LEFT OUTER JOIN #ClaimLineKey AS CLK
							ON CCL.DSClaimLineID = CLK.DSClaimLineID
			WHERE	(CLK.DSClaimLineID IS NULL) AND
					(CCL.ClaimTypeID = @ClaimTypeE);
			
			CREATE UNIQUE CLUSTERED INDEX IX_#ClaimLineKey ON #ClaimLineKey (DSClaimLineID ASC);
			CREATE STATISTICS ST_#ClaimLineKey ON #ClaimLineKey (DSClaimLineID);
			
			DECLARE @i int;
			
			WHILE ISNULL(@i, 0) < 10
				BEGIN
					SET @i = ISNULL(@i, 0) + 1;
				
					--Create the Claim Line Key used for combining claims 	
					IF OBJECT_ID('tempdb..#CombineBase') IS NOT NULL
						DROP TABLE #CombineBase;
					
					SELECT	BeginDate,
							COUNT(DISTINCT DSClaimID) AS CountClaims,
							COUNT(DISTINCT DSClaimLineID) AS CountClaimLines,
							COUNT(DISTINCT DSProviderID) AS CountProviders,
							COUNT(DISTINCT POS) AS CountPOS,
							MIN(DSClaimID) AS DSClaimID,
							DSMemberID,
							DSProviderID,
							EndDate,
							MAX(CONVERT(smallint, IsAcute)) AS IsAcute,
							MAX(CONVERT(smallint, IsED)) AS IsED,
							MAX(CONVERT(smallint, IsInpatient)) AS IsInpatient,
							MAX(CONVERT(smallint, IsInpatientAcute)) AS IsInpatientAcute,
							MAX(CONVERT(smallint, IsInpatientNonacute)) AS IsInpatientNonacute,
							MAX(CONVERT(smallint, IsOutpatient)) AS IsOutpatient,
							MIN(CONVERT(smallint, IsUnknown)) AS IsUnknown,
							MAX(CONVERT(smallint, IsUnknown)) AS IsUnknownMax
					INTO	#CombineBase
					FROM	#ClaimLineKey
					GROUP BY BeginDate,
							DSMemberID, 
							DSProviderID,
							EndDate;
							
					UPDATE	CLK
					SET		DSClaimID = CB.DSClaimID
					FROM	#ClaimLineKey AS CLK
							INNER JOIN #CombineBase AS CB
									ON CLK.DSMemberID = CB.DSMemberID AND
										CLK.DSProviderID = CB.DSProviderID AND
										(CLK.BeginDate = CB.BeginDate OR (CLK.BeginDate IS NULL AND CB.BeginDate IS NULL)) AND
										(CLK.EndDate = CB.EndDate OR (CLK.EndDate IS NULL AND CB.EndDate IS NULL))
					WHERE	(CB.CountClaims > 1);
							
					CREATE UNIQUE INDEX IX_#CombineBase ON #CombineBase (DSMemberID ASC, BeginDate ASC, EndDate ASC, DSProviderID ASC) WITH (FILLFACTOR = 100);
					CREATE STATISTICS ST_#CombineBase ON #CombineBase (DSMemberID, BeginDate, EndDate, DSProviderID);
					
					--Determine inpatient claims to combine	
					IF OBJECT_ID('tempdb..#Combine') IS NOT NULL
						DROP TABLE #Combine;
					
					SELECT	CB.DSMemberID,
							CASE WHEN MIN(CB.BeginDate) > MIN(t.BeginDate) THEN MIN(t.BeginDate) ELSE MIN(CB.BeginDate) END AS BeginDate,
							CASE WHEN CB.DSClaimID > t.DSClaimID THEN t.DSClaimID ELSE CB.DSClaimID END AS DSClaimID,
							CASE WHEN MIN(CB.EndDate) < MIN(t.EndDate) OR MIN(CB.EndDate) IS NULL THEN ISNULL(MIN(t.EndDate), MIN(t.BeginDate)) ELSE MIN(CB.EndDate) END AS EndDate,
							MIN(CB.BeginDate) AS FromBeginDate,
							MIN(t.BeginDate) AS ToBeginDate,
							MAX(CB.EndDate) AS FromEndDate,
							MAX(t.EndDate) AS ToEndDate,
							MAX(CB.IsED) AS IsED,
							MAX(CB.IsInpatientAcute) AS IsInpatientAcute,
							MIN(CB.IsInpatientNonacute) AS IsInpatientNonAcute
					INTO	#Combine
					FROM	#CombineBase AS CB
							INNER JOIN #CombineBase AS t
									ON CB.DSMemberID = t.DSMemberID AND
										CB.DSClaimID <> t.DSClaimID AND
										(
											--Matching for overlapping inpatient stays
											(
												(CB.EndDate IS NOT NULL) AND
												(t.EndDate IS NOT NULL) AND
												(CB.EndDate BETWEEN DATEADD(dd, 1, t.BeginDate) AND t.EndDate) AND 
												(
													(CB.IsInpatient = 1)
												) AND
												(
													(t.IsInpatient = 1)
												) AND
												(
													((CB.IsInpatientAcute = 1) AND (t.IsInpatientAcute = 1)) OR
													((CB.IsInpatientAcute = 1) AND (t.IsInpatientAcute = 0) AND (t.IsInpatientNonAcute = 0)) OR
													((CB.IsInpatientNonAcute = 1) AND (CB.IsAcute = 0) AND (CB.IsInpatientAcute = 0) AND (t.IsAcute = 0) AND (t.IsInpatientAcute = 0))
												)
											) OR
											--Matching stand-alone ED Visits to inpatient stays
											(
												(CB.EndDate IS NULL) AND
												(CB.IsED = 1) AND
												(CB.BeginDate BETWEEN DATEADD(day, @EDCombineDays * -1, t.BeginDate) AND t.EndDate) AND
												(
													(t.IsInpatient = 1)
												)
											)	
										)
					GROUP BY CB.DSMemberID,
							CASE WHEN CB.DSClaimID > t.DSClaimID THEN t.DSClaimID ELSE CB.DSClaimID END;
							
					IF @@ROWCOUNT = 0
						BREAK;
							
					--Combine Acute Inpatient Stays
					UPDATE	CLK
					SET		BeginDate = C.BeginDate,
							DSClaimID = C.DSClaimID,
							EndDate =  C.EndDate,
							IsAcute = 1
					FROM	#ClaimLineKey AS CLK
							INNER JOIN #Combine AS C
									ON CLK.DSMemberID = C.DSMemberID AND
										(
											((CLK.BeginDate BETWEEN C.BeginDate AND C.EndDate) AND (CLK.EndDate BETWEEN C.BeginDate AND C.EndDate)) OR
											((CLK.BeginDate BETWEEN C.BeginDate AND DATEADD(DAY, -1, C.EndDate)) AND (CLK.IsED = 1)) OR
											(CLK.BeginDate BETWEEN DATEADD(DAY, 1, C.BeginDate) AND DATEADD(DAY, -1, C.EndDate)) OR
											(CLK.EndDate BETWEEN DATEADD(DAY, 1, C.BeginDate) AND DATEADD(DAY, -1, C.EndDate))
										)
					WHERE	(C.IsInpatientAcute = 1);
					
					--Combine Nonacute Inpatient Stays
					UPDATE	CLK
					SET		BeginDate = C.BeginDate,
							DSClaimID = C.DSClaimID,
							EndDate =  C.EndDate
					FROM	#ClaimLineKey AS CLK
							INNER JOIN #Combine AS C
									ON CLK.DSMemberID = C.DSMemberID AND
										(
											((CLK.BeginDate BETWEEN C.BeginDate AND C.EndDate) AND (CLK.EndDate BETWEEN C.BeginDate AND C.EndDate)) OR
											((CLK.BeginDate BETWEEN C.BeginDate AND DATEADD(DAY, -1, C.EndDate)) AND (CLK.IsED = 1)) OR
											(CLK.BeginDate BETWEEN DATEADD(DAY, 1, C.BeginDate) AND DATEADD(DAY, -1, C.EndDate)) OR
											(CLK.EndDate BETWEEN DATEADD(DAY, 1, C.BeginDate) AND DATEADD(DAY, -1, C.EndDate))
										)
					WHERE	(C.IsInpatientAcute = 0) AND
							(CLK.IsAcute = 0);
				END;
				
			--Summarize the combined claims
			IF OBJECT_ID('tempdb..#ClaimKey') IS NOT NULL
				DROP TABLE #ClaimKey;
				
			SELECT DISTINCT 
					DSClaimID,
					DSClaimLineID
			INTO	#ClaimKey
			FROM	#ClaimLineKey;
			
			CREATE UNIQUE CLUSTERED INDEX IX_#ClaimKey ON #ClaimKey (DSClaimLineID) WITH (FILLFACTOR = 100);
			CREATE STATISTICS ST_#ClaimKey ON #ClaimKey (DSClaimLineID);
			
			INSERT INTO #ClaimKey
					(DSClaimID,
					DSClaimLineID)
			SELECT	CCL.DSClaimLineID AS DSClaimID,
					CCL.DSClaimLineID
			FROM	Proxy.ClaimLines AS CCL
					LEFT OUTER JOIN #ClaimKey AS CK
							ON CCL.DSClaimLineID = CK.DSClaimLineID
			WHERE	(CK.DSClaimLineID IS NULL);
			
			IF OBJECT_ID('tempdb..#ClaimLineKey') IS NOT NULL
				DROP TABLE #ClaimLineKey;
			
			DECLARE @UpdateClaims bit;
			IF EXISTS (SELECT TOP 1 1 FROM Claim.ClaimLines WHERE DataSetID = @DataSetID)
				SET @UpdateClaims = 1;
			ELSE
				SET @UpdateClaims = 0;


			--UPDATE TEMP Claim Lines with Claim ID------------------	
			UPDATE	TCL
			SET		DSClaimID = t.DSClaimID 
			FROM	Proxy.ClaimLines AS TCL
					INNER JOIN #ClaimKey AS t
							ON TCL.DSClaimLineID = t.DSClaimLineID AND
								TCL.DSClaimID IS NULL;

			--UPDATE REAL Claim Lines with Claim ID------------------	
			IF @UpdateClaims = 1
				UPDATE	TCL
				SET		DSClaimID = t.DSClaimID 
				FROM	Claim.ClaimLines AS TCL
						INNER JOIN #ClaimKey AS t
								ON TCL.DSClaimLineID = t.DSClaimLineID AND
									TCL.DSClaimID IS NULL;

			--UPDATE TEMP Claim Codes with Claim ID------------------
			UPDATE	TCC
			SET		DSClaimID = t.DSClaimID 
			FROM	Proxy.ClaimCodes AS TCC
					INNER JOIN #ClaimKey AS t
							ON TCC.DSClaimLineID = t.DSClaimLineID AND
								TCC.DSClaimID IS NULL;

			--UPDATE REAL Claim Codes with Claim ID------------------
			IF @UpdateClaims = 1
				UPDATE	TCC
				SET		DSClaimID = t.DSClaimID 
				FROM	Claim.ClaimCodes AS TCC
						INNER JOIN #ClaimKey AS t
								ON TCC.DSClaimLineID = t.DSClaimLineID AND
									TCC.DSClaimID IS NULL;

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

			--IF @@ROWCOUNT > 0 
			IF @UpdateClaims = 1
				BEGIN
					DELETE FROM Claim.Claims WHERE DataSetID = @DataSetID;
				
					INSERT INTO Claim.Claims
							(BeginDate,
							ClaimTypeID,
							DataSetID,
							DSClaimID,
							DSMemberID,
							DSProviderID,
							EndDate,
							LOS,
							POS,
							ServDate)
					SELECT	BeginDate,
							ClaimTypeID,
							DataSetID,
							DSClaimID,
							DSMemberID,
							DSProviderID,
							EndDate,
							LOS,
							POS,
							ServDate 
					FROM	Proxy.Claims;
				END;

			--INSERT Final Claim Attributes----------------------
			IF 1 = 1 --@@ROWCOUNT > 0
				BEGIN
					DECLARE @DSClaimAttribID bigint;
					SET @DSClaimAttribID = 0;
					
					DELETE FROM Proxy.ClaimAttributes;

					INSERT INTO Proxy.ClaimAttributes 
							(BatchID, ClaimAttribID, DataRunID, DataSetID, 
							DSClaimAttribID, DSClaimID, DSClaimLineID, DSMemberID)
					SELECT	DISTINCT
							@BatchID,
							CLA.ClaimAttribID,
							@DataRunID,
							TCL.DataSetID,
							CLA.DSClaimAttribID,
							C.DSClaimID,
							CLA.DSClaimLineID,
							TCL.DSMemberID
					FROM	#ClaimLineAttribs AS CLA
							INNER JOIN #ClaimKey AS C
									ON CLA.DSClaimLineID = C.DSClaimLineID 
							INNER JOIN Proxy.ClaimLines AS TCL
									ON C.DSClaimLineID = TCL.DSClaimLineID AND
										CLA.DSClaimLineID = TCL.DSClaimLineID;
				END

			--IF @@ROWCOUNT > 0 
			IF @UpdateClaims = 1
				BEGIN
					DELETE FROM Claim.ClaimAttributes WHERE DataSetID = @DataSetID;
				
					INSERT INTO Claim.ClaimAttributes
							(ClaimAttribID,
							DataSetID,
							DSClaimAttribID,
							--DSClaimID,
							DSClaimLineID,
							DSMemberID)
					SELECT	ClaimAttribID,
							DataSetID,
							DSClaimAttribID,
							--DSClaimID,
							DSClaimLineID,
							DSMemberID 
					FROM	Proxy.ClaimAttributes;
				END;
								
			--Apply new DSClaimID to existing Temp.EventBase records as needed
			UPDATE	VB
			SET		DSClaimID = t.DSClaimID 
			FROM	Proxy.EventBase AS VB
					INNER JOIN #ClaimKey AS t
							ON VB.DSClaimLineID = t.DSClaimLineID
			WHERE	VB.DSClaimID IS NULL
			
			SELECT @CountRecords = COUNT(*) FROM #ClaimKey WHERE DSClaimID <> DSClaimLineID;
			
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
			SET @LogDescr = 'Combining claims for BATCH ' + ISNULL(CAST(@BatchID AS varchar), '?') + ' refresh failed!'; --{FAILURE LOG DESCRIPTION HERE}
			
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
GRANT EXECUTE ON  [Batch].[CombineClaims_v2] TO [Processor]
GO
