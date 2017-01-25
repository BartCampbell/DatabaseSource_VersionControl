SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- =============================================
-- Author:		Kriz, Mike
-- Create date: 1/28/2011
-- Description:	Combines claims and updates claim information across claim tables. (v1)
-- =============================================
CREATE PROCEDURE [Batch].[CombineClaims_v1]
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
			--DECLARE @ClaimTypeL tinyint;
			--DECLARE @ClaimTypeP tinyint;

			SELECT @ClaimTypeE = ClaimTypeID FROM Claim.ClaimTypes WHERE Abbrev = 'E';
			--SELECT @ClaimTypeL = ClaimTypeID FROM Claim.ClaimTypes WHERE Abbrev = 'L';
			--SELECT @ClaimTypeP = ClaimTypeID FROM Claim.ClaimTypes WHERE Abbrev = 'P';

			/*DECLARE @EventTypeC tinyint;
			DECLARE @EventTypeL tinyint;
			DECLARE @EventTypeD tinyint;
			DECLARE @EventTypeP tinyint;

			SELECT @EventTypeC = EventTypeID FROM Measure.EventTypes WHERE Abbrev = 'C'
			SELECT @EventTypeL = EventTypeID FROM Measure.EventTypes WHERE Abbrev = 'L'
			SELECT @EventTypeD = EventTypeID FROM Measure.EventTypes WHERE Abbrev = 'D'
			SELECT @EventTypeP = EventTypeID FROM Measure.EventTypes WHERE Abbrev = 'P'*/
			
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
			GROUP BY EventBaseID,
					EventID,
					OptionNbr 
			HAVING	(COUNT(DISTINCT CASE WHEN Allow = 1 THEN EventCritID END) >= MAX(CountAllowed)) AND
					(COUNT(DISTINCT CASE WHEN Allow = 0 THEN EventCritID END) = 0)
			ORDER BY EventBaseID;
								
			--Use results to identify Claim Attributes...
			WITH DateEvents AS
			(
				SELECT DISTINCT
						AllowEndDate,
						BeginDate,
						EndDate,
						EventID,
						RequireEndDate
				FROM	Proxy.EventKey 
			),
			ClaimLineEvents AS
			(
				SELECT DISTINCT
						V.DSClaimLineID, V.EventID
				FROM	DateEvents AS DV
						INNER JOIN #EventOptions AS V
								ON DV.EventID = V.EventID AND
									((V.ClaimTypeID <> @ClaimTypeE) OR
									(V.ClaimTypeID = @ClaimTypeE AND
									((DV.AllowEndDate = 1) OR
									(DV.AllowEndDate = 0 AND V.EndDate IS NULL)) AND
									((DV.RequireEndDate = 0) OR
									(DV.RequireEndDate = 1 AND V.EndDate IS NOT NULL)) AND
									((DV.BeginDate IS NULL) OR
									(DV.BeginDate IS NOT NULL AND DV.BeginDate <= COALESCE(V.EndDate, V.BeginDate))) AND
									((DV.EndDate IS NULL) OR
									(DV.EndDate IS NOT NULL AND DV.EndDate >= COALESCE(V.EndDate, V.BeginDate)))))
			)
			SELECT DISTINCT
					VCA.ClaimAttribID, /*CAST(NULL AS bigint)*/ IDENTITY(bigint, 1, 1) AS DSClaimAttribID, CLV.DSClaimLineID 
			INTO	#ClaimLineAttribs
			FROM	ClaimLineEvents AS CLV
					INNER JOIN Measure.EventsToClaimAttributes AS VCA
							ON CLV.EventID = VCA.EventID 
					INNER JOIN Proxy.ClaimLines AS TCL
							ON CLV.DSClaimLineID = TCL.DSClaimLineID AND
								TCL.DSClaimID IS NULL
					INNER JOIN Claim.Attributes AS CA
							ON VCA.ClaimAttribID = CA.ClaimAttribID AND
								TCL.ClaimTypeID = CA.ClaimTypeID 
								
			CREATE UNIQUE CLUSTERED INDEX IX_tmp_ClaimLineAttribs ON #ClaimLineAttribs (DSClaimLineID ASC, ClaimAttribID ASC);

			--Combine overlapping inpatient stays
			CREATE TABLE #Claims
			(
				DSClaimID bigint NOT NULL,
				DSClaimLineID bigint NOT NULL,
				RowID int IDENTITY(1,1) NOT NULL
			);			
			
			WITH StartLines
			AS
			(
				SELECT	TCL.* 
				FROM	#ClaimLineAttribs AS CLA
						INNER JOIN Proxy.ClaimLines AS TCL
								ON CLA.DSClaimLineID = TCL.DSClaimLineID AND
									TCL.ClaimTypeID = @ClaimTypeE AND
									CLA.ClaimAttribID = @ClaimAttribIN 
			)
			INSERT INTO #Claims
			SELECT	t.DSClaimLineID AS DSClaimID, TCL.DSClaimLineID
			FROM	StartLines AS t
					INNER JOIN Proxy.ClaimLines as TCL
							ON t.DSMemberID = TCL.DSMemberID AND
								TCL.ClaimTypeID = @ClaimTypeE AND
								t.DSClaimLineID <> TCL.DSClaimLineID AND
								(((t.BeginDate < TCL.BeginDate) AND (t.EndDate > TCL.BeginDate)) OR
								(TCL.BeginDate BETWEEN DATEADD(dd, 1, t.BeginDate) AND DATEADD(dd, -1, t.EndDate)) OR
								(TCL.EndDate BETWEEN DATEADD(dd, 1, t.BeginDate) AND DATEADD(dd, -1, t.EndDate)) OR
								((t.BeginDate = TCL.BeginDate) AND (TCL.EndDate IS NOT NULL)));

			--WHILE @@ROWCOUNT > 0
			--	UPDATE	C
			--	SET		DSClaimID = t.DSClaimID
			--	FROM	#Claims AS C
			--			INNER JOIN #Claims AS t
			--					ON C.DSClaimID = t.DSClaimLineID AND
			--						t.DSClaimID <> t.DSClaimLineID;

			WITH ClaimAttribs AS
			(
				SELECT DISTINCT
						CLA.ClaimAttribID, CLA.DSClaimLineID AS DSClaimID
				FROM	#ClaimLineAttribs AS CLA
			),
			ClaimLineAttribs AS
			(
				SELECT DISTINCT
						CA.ClaimAttribID, t.DSClaimLineID
				FROM	#Claims AS t
						INNER JOIN ClaimAttribs AS CA
								ON t.DSClaimID = CA.DSClaimID 
			)
			INSERT INTO #ClaimLineAttribs 
					(ClaimAttribID, DSClaimLineID)
			SELECT DISTINCT
					CLA.ClaimAttribID, CLA.DSClaimLineID 
			FROM	ClaimLineAttribs CLA
					LEFT OUTER JOIN #ClaimLineAttribs AS t
							ON CLA.ClaimAttribID = t.ClaimAttribID AND
								CLA.DSClaimLineID = t.DSClaimLineID 
			WHERE	(t.DSClaimLineID IS NULL);

			--Combine ED and Outpatient Visits that match on member, date, provider and pos
			WITH StartLines
			AS
			(
				SELECT	TCL.* 
				FROM	#ClaimLineAttribs AS CLA
						INNER JOIN Proxy.ClaimLines AS TCL
								ON CLA.DSClaimLineID = TCL.DSClaimLineID AND
									TCL.ClaimTypeID = @ClaimTypeE AND
									CLA.ClaimAttribID IN(@ClaimAttribED, @ClaimAttribOUT)
			)
			INSERT INTO #Claims 
			SELECT DISTINCT
					t.DSClaimLineID AS DSClaimID, TCL.DSClaimLineID
			FROM	StartLines AS t
					INNER JOIN Proxy.ClaimLines as TCL
							ON t.DSMemberID = TCL.DSMemberID AND
								t.DSProviderID = TCL.DSProviderID AND
								TCL.ClaimTypeID = @ClaimTypeE AND
								(t.POS IS NULL OR
								TCL.POS IS NULL OR
								t.POS = TCL.POS) AND
								t.DSClaimLineID > TCL.DSClaimLineID AND
								(t.BeginDate = TCL.BeginDate);

			--WHILE @@ROWCOUNT > 0
			--	UPDATE	C
			--	SET		DSClaimID = t.DSClaimID
			--	FROM	#Claims AS C
			--			INNER JOIN #Claims AS t
			--					ON C.DSClaimID = t.DSClaimLineID AND
			--						t.DSClaimID <> t.DSClaimLineID;

			WITH ClaimAttribs AS
			(
				SELECT DISTINCT
						CLA.ClaimAttribID, CLA.DSClaimLineID AS DSClaimID
				FROM	#ClaimLineAttribs AS CLA
			),
			ClaimLineAttribs AS
			(
				SELECT DISTINCT
						CA.ClaimAttribID, t.DSClaimLineID
				FROM	#Claims AS t
						INNER JOIN ClaimAttribs AS CA
								ON t.DSClaimID = CA.DSClaimID 
			)
			INSERT INTO #ClaimLineAttribs 
					(ClaimAttribID, DSClaimLineID)
			SELECT DISTINCT
					CLA.ClaimAttribID, CLA.DSClaimLineID 
			FROM	ClaimLineAttribs CLA
					LEFT OUTER JOIN #ClaimLineAttribs AS t
							ON CLA.ClaimAttribID = t.ClaimAttribID AND
								CLA.DSClaimLineID = t.DSClaimLineID 
			WHERE	(t.DSClaimLineID IS NULL);

			--Combine ED visits with inpatient stays within 1 day
			WITH EDLines
			AS
			(
				SELECT	TCL.* 
				FROM	#ClaimLineAttribs AS CLA
						INNER JOIN Proxy.ClaimLines AS TCL
								ON CLA.DSClaimLineID = TCL.DSClaimLineID AND
									TCL.ClaimTypeID = @ClaimTypeE AND
									CLA.ClaimAttribID IN (@ClaimAttribED)
			),
			InpatientLines AS
			(
				SELECT	TCL.* 
				FROM	#ClaimLineAttribs AS CLA
						INNER JOIN Proxy.ClaimLines AS TCL
								ON CLA.DSClaimLineID = TCL.DSClaimLineID AND
									TCL.ClaimTypeID = @ClaimTypeE AND
									CLA.ClaimAttribID IN (@ClaimAttribIN)
			)
			INSERT INTO	#Claims
			SELECT DISTINCT
					t.DSClaimLineID AS DSClaimID, IL.DSClaimLineID
			FROM	EDLines AS t
					INNER JOIN InpatientLines as IL
							ON t.DSMemberID = IL.DSMemberID AND
								t.DSClaimLineID <> IL.DSClaimLineID AND
								(t.BeginDate BETWEEN DATEADD(day, (ABS(@EDCombineDays) * -1), IL.BeginDate) AND IL.EndDate);

			--WHILE @@ROWCOUNT > 0
			--	UPDATE	C
			--	SET		DSClaimID = t.DSClaimID
			--	FROM	#Claims AS C
			--			INNER JOIN #Claims AS t
			--					ON C.DSClaimID = t.DSClaimLineID AND
			--						t.DSClaimID <> t.DSClaimLineID;

			WITH ClaimAttribs AS
			(
				SELECT DISTINCT
						CLA.ClaimAttribID, CLA.DSClaimLineID AS DSClaimID
				FROM	#ClaimLineAttribs AS CLA
			),
			ClaimLineAttribs AS
			(
				SELECT DISTINCT
						CA.ClaimAttribID, t.DSClaimLineID
				FROM	#Claims AS t
						INNER JOIN ClaimAttribs AS CA
								ON t.DSClaimID = CA.DSClaimID 
			)
			INSERT INTO #ClaimLineAttribs 
					(ClaimAttribID, DSClaimLineID)
			SELECT DISTINCT
					CLA.ClaimAttribID, CLA.DSClaimLineID 
			FROM	ClaimLineAttribs CLA
					LEFT OUTER JOIN #ClaimLineAttribs AS t
							ON CLA.ClaimAttribID = t.ClaimAttribID AND
								CLA.DSClaimLineID = t.DSClaimLineID 
			WHERE	(t.DSClaimLineID IS NULL);

			DECLARE @MaxRecursion tinyint;
			DECLARE @Recursion tinyint;
			
			SET @MaxRecursion = 10;
			SET @Recursion = 0;		
			
			DECLARE @RowCount int;
			DECLARE @Break bit;
								
			--Address a chance that DSClaimLineID could be associated with more than one "combined claim".
			CREATE TABLE #CrossClaims
			(
				DSClaimID bigint NOT NULL,
				DSClaimLineID bigint NOT NULL
			); 
		
			SET @Break = 0;
			
			WHILE 1 = 1 --Part 1 of 4 (Same Claim Line associated with more than one "Claim")
				BEGIN;
					TRUNCATE TABLE #CrossClaims;
				
					CREATE UNIQUE CLUSTERED INDEX IX_#Claims ON #Claims (DSClaimLineID, DSClaimID, RowID);
				
					INSERT INTO #CrossClaims
							(DSClaimID, DSClaimLineID)
					SELECT DISTINCT
							C1.DSClaimID, C2.DSClaimID
					FROM	#Claims AS C1
							INNER JOIN #Claims AS C2
									ON C1.DSClaimLineID = C2.DSClaimLineID AND
										C1.DSClaimID <> C2.DSClaimID;
										
					--PRINT CONVERT(varchar(256), GETDATE(), 109) + '  #CrossClaims (Loop, Part 1 of 4) --> Records: ' + CONVERT(varchar(256), @@ROWCOUNT);
									
					CREATE UNIQUE CLUSTERED INDEX IX_#CrossClaims ON  #CrossClaims (DSClaimLineID, DSClaimID);
									
					INSERT INTO #Claims
							(DSClaimID, DSClaimLineID)
					SELECT 
							CC.DSClaimID, CC.DSClaimLineID
					FROM	#CrossClaims AS CC
							LEFT OUTER JOIN #Claims AS C
									ON CC.DSClaimID = C.DSClaimID AND
										CC.DSClaimLineID = C.DSClaimLineID 
					WHERE	C.DSClaimLineID IS NULL
									
					IF @@ROWCOUNT = 0
						SET @Break = 1;				
									
					DROP INDEX IX_#Claims ON #Claims;
					DROP INDEX IX_#CrossClaims ON #CrossClaims;
										
					IF @Break = 1
						BREAK;
						
					--PRINT CONVERT(varchar(256), GETDATE(), 109) + '  #Claims Insert (Loop, Part 1 of 4)';
						
					SET @Recursion = ISNULL(@Recursion, 0) + 1
					IF @Recursion >= @MaxRecursion 
						BREAK;
				END;
			
			CREATE UNIQUE CLUSTERED INDEX IX_#Claims ON #Claims (DSClaimLineID, DSClaimID, RowID);
						
			TRUNCATE TABLE #CrossClaims;
			INSERT INTO #CrossClaims --Part 2 of 4 (Create a switched version of Claim and Claim Line)
					(DSClaimID, DSClaimLineID)
			SELECT DISTINCT
					DSClaimLineID, DSClaimID
			FROM	#Claims
			WHERE	DSClaimID <> DSClaimLineID 
											
			CREATE UNIQUE CLUSTERED INDEX IX_#CrossClaims ON  #CrossClaims (DSClaimLineID, DSClaimID);
			
			INSERT INTO #Claims
					(DSClaimID, DSClaimLineID)
			SELECT 
					CC.DSClaimID, CC.DSClaimLineID
			FROM	#CrossClaims AS CC
					LEFT OUTER JOIN #Claims AS C
							ON CC.DSClaimID = C.DSClaimID AND
								CC.DSClaimLineID = C.DSClaimLineID 
			WHERE	C.DSClaimLineID IS NULL
			
			DROP INDEX IX_#Claims ON #Claims;
			DROP INDEX IX_#CrossClaims ON #CrossClaims;
			
			--PRINT CONVERT(varchar(256), GETDATE(), 109) + '  #Claims (Part 2 of 4) --> Records: ' + CONVERT(varchar(256), @@ROWCOUNT);
			
			SET @Recursion = 0;
			
			SET @Break = 0;
			WHILE 1 = 1 -- Part 3 of 4
				BEGIN;
					TRUNCATE TABLE #CrossClaims;
				
					CREATE UNIQUE CLUSTERED INDEX IX_#Claims ON #Claims (DSClaimLineID, DSClaimID, RowID);
								
					INSERT INTO #CrossClaims
							(DSClaimID, DSClaimLineID)
					SELECT DISTINCT
							C1.DSClaimID, C2.DSClaimLineID
					FROM	#Claims AS C1
							INNER JOIN #Claims AS C2
									ON C1.DSClaimLineID = C2.DSClaimID AND
										C1.DSClaimID <> C2.DSClaimID
					UNION
					SELECT DISTINCT
							C1.DSClaimID, C2.DSClaimLineID
					FROM	#Claims AS C1
							INNER JOIN #Claims AS C2
									ON C1.DSClaimID = C2.DSClaimLineID AND
										C1.DSClaimID <> C2.DSClaimID;
								
					--PRINT CONVERT(varchar(256), GETDATE(), 109) + '  #CrossClaims (Loop, Part 3 of 4) --> Records: ' + CONVERT(varchar(256), @@ROWCOUNT);
					
					CREATE UNIQUE CLUSTERED INDEX IX_#CrossClaims ON  #CrossClaims (DSClaimLineID, DSClaimID);
									
					INSERT INTO #Claims
							(DSClaimID, DSClaimLineID)
					SELECT 
							CC.DSClaimID, CC.DSClaimLineID
					FROM	#CrossClaims AS CC
							LEFT OUTER JOIN #Claims AS C
									ON CC.DSClaimID = C.DSClaimID AND
										CC.DSClaimLineID = C.DSClaimLineID 
					WHERE	C.DSClaimLineID IS NULL
					
					IF @@ROWCOUNT = 0
						SET @Break = 1;
					
					DROP INDEX IX_#Claims ON #Claims;
					DROP INDEX IX_#CrossClaims ON #CrossClaims;
					
					IF @Break = 1
						BREAK;
					
					--PRINT CONVERT(varchar(256), GETDATE(), 109) + '  #Claims Insert (Loop, Part 3 of 4)';
						
					SET @Recursion = ISNULL(@Recursion, 0) + 1
					IF @Recursion >= @MaxRecursion 
						BREAK;
				END;
				
			CREATE UNIQUE CLUSTERED INDEX IX_#Claims ON #Claims (DSClaimLineID, DSClaimID, RowID);									
				
			TRUNCATE TABLE #CrossClaims;
			INSERT INTO #CrossClaims	--Part 4 of 4 (Create a switched version of Claim and Claim Line
					(DSClaimID, DSClaimLineID)
			SELECT DISTINCT
					DSClaimLineID, DSClaimID
			FROM	#Claims
			WHERE	DSClaimLineID <> DSClaimID 
			
			CREATE UNIQUE CLUSTERED INDEX IX_#CrossClaims ON  #CrossClaims (DSClaimLineID, DSClaimID);
			
			--PRINT CONVERT(varchar(256), GETDATE(), 109) + '  #CrossClaims (Part 4 of 4) --> Records: ' + CONVERT(varchar(256), @@ROWCOUNT);
			
			INSERT INTO #Claims
					(DSClaimID, DSClaimLineID)
			SELECT	CC.DSClaimID, CC.DSClaimLineID
			FROM	#CrossClaims AS CC
					LEFT OUTER JOIN #Claims AS C
							ON CC.DSClaimID = C.DSClaimID AND
								CC.DSClaimLineID = C.DSClaimLineID 
			WHERE	C.DSClaimLineID IS NULL
			
			--PRINT CONVERT(varchar(256), GETDATE(), 109) + '  #Claims (Part 4 of 4) --> Records: ' + CONVERT(varchar(256), @@ROWCOUNT);		
			
			--CREATE TABLE #DeleteClaims
			--(
			--	DSClaimID bigint NOT NULL,
			--	DSClaimLineID bigint NOT NULL,
			--	RowID int NOT NULL
			--); 
			
			--WHILE 1 = 1
			--	BEGIN
			--		TRUNCATE TABLE #DeleteClaims 
			--		INSERT INTO #DeleteClaims SELECT DSClaimLineID, DSClaimID, MAX(RowID) AS RowID FROM #Claims GROUP BY DSClaimID, DSClaimLineID HAVING(COUNT(*) > 1);
					
			--		DELETE FROM #Claims WHERE RowID IN (SELECT RowID FROM #DeleteClaims);
					
			--		IF @@ROWCOUNT = 0
			--			BREAK;
			--	END
			
			
			
			SELECT MIN(DSClaimID) AS DSClaimID, DSClaimLineID INTO #CombinedClaims FROM #Claims GROUP BY DSClaimLineID
			
			--PRINT CONVERT(varchar(256), GETDATE(), 109) + '  #CombinedClaims (Part 1 of 2) --> Records: ' + CONVERT(varchar(256), @@ROWCOUNT);
			
			--------------------------------------------------------------------------------------------------------------------
			--INSERT ANY REMAINING UNCOMBINED CLAIMS INTO #Claims WITH THE CLAIM ID POINTING TO ITSELF
			-- * This step used to run before Steps 1-4.  If accuracy problems occur, place before Step 1-4 again.

			INSERT INTO #CombinedClaims
			SELECT DISTINCT
					DSClaimLineID AS DSClaimID, DSClaimLineID
			FROM	Proxy.ClaimLines AS TCL
			WHERE	TCL.DSClaimLineID NOT IN (SELECT DISTINCT DSClaimLineID FROM #Claims);

			--PRINT CONVERT(varchar(256), GETDATE(), 109) + '  #CombinedClaims (Part 2 of 2) --> Records: ' + CONVERT(varchar(256), @@ROWCOUNT);
			--------------------------------------------------------------------------------------------------------------------
			
			DROP TABLE #Claims;
			DROP TABLE #CrossClaims;
			
			CREATE UNIQUE CLUSTERED INDEX IX_tmp_CombinedClaims ON #CombinedClaims (DSClaimLineID ASC);	

			--SELECT DISTINCT * FROM #Claims AS t INNER JOIN Proxy.ClaimLines AS TCL ON t.DSClaimLineID = TCL.DSClaimLineID WHERE t.DSClaimID <> t.DSClaimLineID ORDER BY t.DSClaimID;

			--SELECT * FROM #Claims WHERE DSClaimLineID IN (SELECT DSClaimLineID FROM #Claims GROUP BY DSClaimLineID HAVING (COUNT(*) > 1))
			
			DECLARE @UpdateClaims bit;
			IF EXISTS (SELECT TOP 1 1 FROM Claim.ClaimLines WHERE DataSetID = @DataSetID)
				SET @UpdateClaims = 1;
			ELSE
				SET @UpdateClaims = 0;


			--UPDATE TEMP Claim Lines with Claim ID------------------	
			UPDATE	TCL
			SET		DSClaimID = t.DSClaimID 
			FROM	Proxy.ClaimLines AS TCL
					INNER JOIN #CombinedClaims AS t
							ON TCL.DSClaimLineID = t.DSClaimLineID AND
								TCL.DSClaimID IS NULL;

			--UPDATE REAL Claim Lines with Claim ID------------------	
			--IF @@ROWCOUNT > 0
			IF @UpdateClaims = 1
				UPDATE	TCL
				SET		DSClaimID = t.DSClaimID 
				FROM	Claim.ClaimLines AS TCL
						INNER JOIN #CombinedClaims AS t
								ON TCL.DSClaimLineID = t.DSClaimLineID AND
									TCL.DSClaimID IS NULL;

			--UPDATE TEMP Claim Codes with Claim ID------------------
			--IF @@ROWCOUNT > 0
				UPDATE	TCC
				SET		DSClaimID = t.DSClaimID 
				FROM	Proxy.ClaimCodes AS TCC
						INNER JOIN #CombinedClaims AS t
								ON TCC.DSClaimLineID = t.DSClaimLineID AND
									TCC.DSClaimID IS NULL;

			--UPDATE REAL Claim Codes with Claim ID------------------
			--IF @@ROWCOUNT > 0
			IF @UpdateClaims = 1
				UPDATE	TCC
				SET		DSClaimID = t.DSClaimID 
				FROM	Claim.ClaimCodes AS TCC
						INNER JOIN #CombinedClaims AS t
								ON TCC.DSClaimLineID = t.DSClaimLineID AND
									TCC.DSClaimID IS NULL;

			--INSERT Final Claims-------------------------------
			--IF @@ROWCOUNT > 0
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
				GROUP BY ClaimTypeID, DSClaimID, DSMemberID;

			--IF @@ROWCOUNT > 0 
			IF @UpdateClaims = 1
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
				FROM	Proxy.Claims 

			--INSERT Final Claim Attributes----------------------
			IF 1 = 1 --@@ROWCOUNT > 0
				BEGIN
					DECLARE @DSClaimAttribID bigint;
					SET @DSClaimAttribID = 0;

					--UPDATE #ClaimLineAttribs SET @DSClaimAttribID = DSClaimAttribID = @DSClaimAttribID + 1;

					--WITH Test AS
					--(
					--	SELECT	DISTINCT
					--			CLA.ClaimAttribID, CLA.DSClaimAttribID, C.DSClaimID, CLA.DSClaimLineID 
					--	FROM	#ClaimLineAttribs AS CLA
					--			INNER JOIN #CombinedClaims AS C
					--					ON CLA.DSClaimLineID = C.DSClaimLineID 
					--)
					--SELECT * FROM Test WHERE DSClaimAttribID IN (SELECT DSClaimAttribID FROM Test GROUP BY DSClaimAttribID HAVING COUNT(*) > 1);

					INSERT INTO Proxy.ClaimAttributes 
							(BatchID, ClaimAttribID, DataRunID, DataSetID, 
							DSClaimAttribID, /*DSClaimID,*/ DSClaimLineID, DSMemberID)
					SELECT	DISTINCT
							@BatchID,
							CLA.ClaimAttribID,
							@DataRunID,
							TCL.DataSetID,
							CLA.DSClaimAttribID,
							--C.DSClaimID,
							CLA.DSClaimLineID,
							TCL.DSMemberID
					FROM	#ClaimLineAttribs AS CLA
							INNER JOIN #CombinedClaims AS C
									ON CLA.DSClaimLineID = C.DSClaimLineID 
							INNER JOIN Proxy.ClaimLines AS TCL
									ON C.DSClaimLineID = TCL.DSClaimLineID AND
										CLA.DSClaimLineID = TCL.DSClaimLineID
				END

			--IF @@ROWCOUNT > 0 
			IF @UpdateClaims = 1
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
				FROM	Proxy.ClaimAttributes 
								
			--Apply new DSClaimID to existing Temp.EventBase records as needed
			UPDATE	VB
			SET		DSClaimID = t.DSClaimID 
			FROM	Proxy.EventBase AS VB
					INNER JOIN #CombinedClaims AS t
							ON VB.DSClaimLineID = t.DSClaimLineID
			WHERE	VB.DSClaimID IS NULL
			

			SELECT @CountRecords = COUNT(*) FROM #CombinedClaims WHERE DSClaimID <> DSClaimLineID;
						
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
GRANT EXECUTE ON  [Batch].[CombineClaims_v1] TO [Processor]
GO
