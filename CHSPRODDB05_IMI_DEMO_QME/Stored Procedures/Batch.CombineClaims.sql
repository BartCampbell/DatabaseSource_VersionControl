SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 6/15/2012
-- Description:	(Revised) Combines claims based on their "attributes". (v6)
--				(This version further increases performance and breaks the procedure into three parts:
--				 - Batch.ApplyClaimUpdates
--				 - Batch.CombineClaims
--				 - Batch.IdentifyClaimAttributes)
--				VERSION 4 CHANGES:
--				- Moved "Outpatient" combining to after inpatient
--				- Changed "Outpatient" combining to now combine all non-inpatient, encounter claims, regardless of type,
--				  by Member, Provider, Begin Date, and End Date.
--				- FYI: Version 4 changes may result in slower processing time for this proc, but it is intended to save 
--				  much more processing time during later processing.
--				VERSION 5 CHANGES:
--				- Incorporates bit-wise logic to help identify overlapping inpatient stays more efficiently
--				- Match all "unknown"-type claims to inpatient stays with overlapping dates (even the first day) and the same provider (Added HEDIS 2015)
--				- Match all "unknown"-type claims to inpatient stays with overlapping dates (even the first day) where the provider has a surgery specialty (Added HEDIS 2015)
--				VERSION 6 CHANGES:
--				- Removed step required to calculate provider specialties, since BitSpecialties is now part of the engine's Providers tables
-- =============================================
CREATE PROCEDURE [Batch].[CombineClaims]
(
	@BatchID int
)
WITH RECOMPILE
AS
BEGIN
	SET NOCOUNT ON;
		

	/*DEBUG SETTINGS************************************************************************************/
	--Setting @IsDebug = 1 outputs the key temp tables used in this process
	DECLARE @IsDebug bit;
	SET @IsDebug = 0;	

	--Setting @DebugCustomerMemberID will only return debug rows for the specified member
	DECLARE @DebugCustomerMemberID varchar(20);
	SET @DebugCustomerMemberID = NULL;
	/***************************************************************************************************/
	
	
	DECLARE @LogBeginTime datetime;
	DECLARE @LogDescr varchar(256);
	DECLARE @LogEndTime datetime;
	DECLARE @LogEntryXrefGuid uniqueidentifier;
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
		
		--Added to determine @LogEntryXrefGuid value---------------------------
		SELECT @LogEntryXrefGuid = [Log].GetEntryXrefGuid (@LogObjectSchema, @LogObjectName);
		-----------------------------------------------------------------------
				
		BEGIN TRY;
				
			IF @BatchID IS NULL
				RAISERROR(' - Combining claims failed!  No batch was specified.', 16, 1);
				
			DECLARE @CountRecords bigint;
			DECLARE @EDCombineDays smallint;
			
			--Retrieve Batch information...
			SELECT	@BeginInitSeedDate = DR.BeginInitSeedDate,
					@CountRecords = 0,
					@DataRunID = DR.DataRunID,
					@DataSetID = DS.DataSetID,
					@EDCombineDays = DO.EDCombineDays,
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
					INNER JOIN Batch.DataOwners AS DO
							ON DS.OwnerID = DO.OwnerID
			WHERE	(B.BatchID = @BatchID);

			
			--Debugging Prep
			DECLARE @DebugDSMemberID bigint;
		
			IF @IsDebug = 1 AND @DebugCustomerMemberID IS NOT NULL
				SELECT	@DebugDSMemberID = PM.DSMemberID 
				FROM	Proxy.Members AS PM WITH(NOLOCK)
				WHERE	(PM.BatchID = @BatchID) AND 
						(PM.DataRunID = @DataRunID) AND 
						(PM.DataSetID = @DataSetID) AND 
						(PM.CustomerMemberID = @DebugCustomerMemberID);
			
			--Retrieve Engine Type and Settings...
			DECLARE @AllowClaimUpdates bit;
			DECLARE @AllowFinalizePurgeInternal bit;
			DECLARE @AllowFinalizePurgeLog bit;
			DECLARE @AllowTruncate bit;
			
			SELECT TOP 1
					@AllowClaimUpdates = ET.AllowClaimUpdates,
					@AllowFinalizePurgeInternal = ET.AllowFinalizePurgeInternal,
					@AllowFinalizePurgeLog = ET.AllowFinalizePurgeLog,
					@AllowTruncate = ET.AllowTruncate
			FROM	Engine.Settings AS ES
					INNER JOIN Engine.[Types] AS ET
							ON ES.EngineTypeID = ET.EngineTypeID;
			
			--Retrieve Claim Types... 
			DECLARE @ClaimTypeE tinyint;		--Encounter claims
			DECLARE @ClaimTypeL tinyint;		--Lab claims
			DECLARE @ClaimTypeP tinyint;		--Pharmacy claims

			SELECT @ClaimTypeE = ClaimTypeID FROM Claim.ClaimTypes WHERE Abbrev = 'E';
			SELECT @ClaimTypeL = ClaimTypeID FROM Claim.ClaimTypes WHERE Abbrev = 'L';
			SELECT @ClaimTypeP = ClaimTypeID FROM Claim.ClaimTypes WHERE Abbrev = 'P';
			
			--Retrieve Claim Attributes... 
			DECLARE @ClaimAttribIN smallint;	--Inpatient
			DECLARE @ClaimAttribAIN smallint;	--Inpatient, Acute
			DECLARE @ClaimAttribNIN smallint;	--Inpatient, Nonacute
			DECLARE @ClaimAttribED smallint;	--Emergency Department
			DECLARE @ClaimAttribOUT smallint;	--Outpatient

			SELECT @ClaimAttribIN = ClaimAttribID FROM Claim.Attributes WHERE Abbrev = 'IN';
			SELECT @ClaimAttribAIN = ClaimAttribID FROM Claim.Attributes WHERE Abbrev = 'AIN';
			SELECT @ClaimAttribNIN = ClaimAttribID FROM Claim.Attributes WHERE Abbrev = 'NIN';
			SELECT @ClaimAttribED = ClaimAttribID FROM Claim.Attributes WHERE Abbrev = 'ED';
			SELECT @ClaimAttribOUT = ClaimAttribID FROM Claim.Attributes WHERE Abbrev = 'OUT';

			--Retrieve Claim Attributes (Bitwise)... 
			DECLARE @BitClaimAttribIN bigint;	--Inpatient
			DECLARE @BitClaimAttribAIN bigint;	--Inpatient, Acute
			DECLARE @BitClaimAttribNIN bigint;	--Inpatient, Nonacute
			DECLARE @BitClaimAttribED bigint;	--Emergency Department
			DECLARE @BitClaimAttribOUT bigint;	--Outpatient

			SELECT @BitClaimAttribIN = BitValue FROM Claim.Attributes WHERE Abbrev = 'IN';
			SELECT @BitClaimAttribAIN = BitValue FROM Claim.Attributes WHERE Abbrev = 'AIN';
			SELECT @BitClaimAttribNIN = BitValue FROM Claim.Attributes WHERE Abbrev = 'NIN';
			SELECT @BitClaimAttribED = BitValue FROM Claim.Attributes WHERE Abbrev = 'ED';
			SELECT @BitClaimAttribOUT = BitValue FROM Claim.Attributes WHERE Abbrev = 'OUT';

			--Retrieve Provider Specialties (Bitwise)...
			DECLARE @BitSpecialtyAnesth bigint;	--Anesthesiology
			DECLARE @BitSpecialtyHosp bigint;	--Hospital
			DECLARE @BitSpecialtySNF bigint;	--Skilled Nursing Facility
			DECLARE @BitSpecialtySurg bigint;	--Surgeon

			SELECT @BitSpecialtyAnesth = BitValue FROM Provider.Specialties WHERE Abbrev = 'Anesth';
			SELECT @BitSpecialtyHosp = BitValue FROM Provider.Specialties WHERE Abbrev = 'Hosp';
			SELECT @BitSpecialtySNF = BitValue FROM Provider.Specialties WHERE Abbrev = 'SNF';
			SELECT @BitSpecialtySurg = BitValue FROM Provider.Specialties WHERE Abbrev = 'Surg';


			--Determines the current state of ANSI_WARNINGS and sets it to "OFF" if necessary (Prevents NULL aggregate messages during the INSERT statement)...
			DECLARE @Ansi_Warnings bit;
			SET @Ansi_Warnings = CASE WHEN (@@OPTIONS & 8) = 8 THEN 1 ELSE 0 END;

			IF @Ansi_Warnings = 0
				SET ANSI_WARNINGS ON;
			
						IF OBJECT_ID('tempdb..#ClaimLinesBase') IS NOT NULL
				DROP TABLE #ClaimLinesBase;

			--1) Summarize claim line attributes...
			SELECT	CCL.BeginDate,
					SUM(DISTINCT CA.BitValue) AS BitClaimAttribs,
					MIN(PP.BitSpecialties) AS BitSpecialties,
					CCL.BeginDate AS CalcBeginDate,
					--ISNULL(DATEADD(day, -2, CCL.EndDate), CCL.BeginDate) AS CalcEndDate,
					ISNULL(CASE WHEN DATEADD(day, -2, CCL.EndDate) > CCL.BeginDate THEN DATEADD(day, -2, CCL.EndDate) END, CCL.BeginDate) AS CalcEndDate,  --Changed 2/22/2014 for RRU certification, would not combine 1 or 2 day stays previously
					MIN(CCL.ClaimSrcTypeID) AS ClaimSrcTypeID,
					CONVERT(bigint, NULL) AS DSClaimID,
					CCL.DSClaimLineID,
					CCL.DSMemberID * CASE WHEN MAX(CONVERT(tinyint, CCL.IsSupplemental)) = 1 THEN -1 ELSE 1 END AS DSMemberID, --Changed 2/5/2016 as easy way to keep supplemental and non-supplemental separated
					CCL.DSProviderID,
					CCL.EndDate,
					MAX(CONVERT(tinyint, CASE WHEN CCA.ClaimAttribID = @ClaimAttribAIN THEN 1 ELSE 0 END)) AS IsAIN,
					MAX(CONVERT(tinyint, CASE WHEN CCA.ClaimAttribID = @ClaimAttribED THEN 1 ELSE 0 END)) AS IsED,
					MAX(CONVERT(tinyint, CASE WHEN CCA.ClaimAttribID = @ClaimAttribIN THEN 1 ELSE 0 END)) AS IsIN,
					MAX(CONVERT(tinyint, CASE WHEN CCA.ClaimAttribID = @ClaimAttribNIN THEN 1 ELSE 0 END)) AS IsNIN,
					MAX(CONVERT(tinyint, CASE WHEN CCA.ClaimAttribID = @ClaimAttribOUT THEN 1 ELSE 0 END)) AS IsOUT,
					MAX(CONVERT(tinyint, CCL.IsSupplemental)) AS IsSupplemental,
					MAX(CONVERT(tinyint, CASE WHEN CCA.DSClaimAttribID IS NULL THEN 1 ELSE 0 END)) AS IsUnknown,
					MIN(CCL.DSClaimID) AS OrigDSClaimID,
					IDENTITY(bigint, 1, 1) AS RowID
			INTO	#ClaimLinesBase
			FROM	Proxy.ClaimLines AS CCL
					LEFT OUTER JOIN Proxy.ClaimAttributes AS CCA
							ON CCL.DataSetID = CCA.DataSetID AND
								CCL.DSClaimLineID = CCA.DSClaimLineID AND
								CCL.DSMemberID = CCA.DSMemberID
					LEFT OUTER JOIN Claim.Attributes AS CA
							ON CCA.ClaimAttribID = CA.ClaimAttribID
					LEFT OUTER JOIN Proxy.Providers AS PP
							ON CCL.DSProviderID = PP.DSProviderID
			WHERE	(CCL.BatchID = @BatchID) AND
					(CCL.DataRunID = @DataRunID) AND
					(CCL.DataSetID = @DataSetID) AND
					(CCL.ClaimTypeID = @ClaimTypeE) -- Encounter claims only
			GROUP BY CCL.BeginDate,
					CCL.DSClaimLineID,
					CCL.DSMemberID,
					CCL.DSProviderID,
					CCL.EndDate
			ORDER BY DSMemberID, CalcEndDate;

			DECLARE @MaxDate datetime;
			DECLARE @MinDate datetime;
			SELECT @MaxDate = MAX(CalcEndDate), @MinDate = MIN(CalcBeginDate) FROM #ClaimLinesBase;

			CREATE UNIQUE CLUSTERED INDEX IX_#ClaimLinesBase ON #ClaimLinesBase (DSClaimLineID);
			CREATE UNIQUE NONCLUSTERED INDEX IX_#ClaimLinesBase2 ON #ClaimLinesBase (DSMemberID, CalcEndDate, CalcBeginDate, DSProviderID, RowID) INCLUDE (IsAIN, IsED, IsIN, IsNIN, IsOUT, IsUnknown);

			--2a) Further summarize claim line attributes by member and date for ED and Inpatient Claims only...
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
					CASE WHEN MIN(t.DSProviderID) = MAX(t.DSProviderID) THEN MIN(T.DSProviderID) END AS DSProviderID,
					MAX(t.BitClaimAttribs) |
						MAX(CASE WHEN t.IsAIN = 1 THEN @BitClaimAttribAIN ELSE 0 END) |
						MAX(CASE WHEN t.IsNIN = 1 THEN @BitClaimAttribNIN ELSE 0 END) |
						MAX(CASE WHEN t.IsIN = 1 THEN @BitClaimAttribIN ELSE 0 END) |
						MAX(CASE WHEN t.IsED = 1 THEN @BitClaimAttribED ELSE 0 END) AS InpatientType,
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
					CONVERT(bigint, NULL) AS LastInpatientType,
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

			CREATE UNIQUE CLUSTERED INDEX IX_#InpatientClaimLinesByDay ON #InpatientClaimLinesByDay (RowID);


			--2b) Identify ED & Inpatient claims to combine (using "Quirky" UPDATE)...
			DECLARE @DSClaimID bigint
			DECLARE @LastDate datetime;
			DECLARE @LastDSClaimID bigint;
			DECLARE @LastInpatientDate datetime;
			DECLARE @LastInpatientAIN bigint;
			DECLARE @LastInpatientID bigint;
			DECLARE @LastInpatientIN bigint;
			DECLARE @LastInpatientNIN bigint;
			DECLARE @LastInpatientType bigint;
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
																(@BitClaimAttribAIN | @BitClaimAttribIN | @BitClaimAttribNIN & InpatientType = 0) OR 
																(
																	(@BitClaimAttribAIN & @LastInpatientType > 0) AND
																	(@BitClaimAttribIN | @BitClaimAttribNIN & InpatientType > 0)
																)
															 )
														THEN @LastInpatientID
														
														--Identify Continued Inpatient Stays
														WHEN @DSClaimID IS NOT NULL AND
															 ISNULL(@LastMemberID, DSMemberID) = DSMemberID AND
															 DATEDIFF(day, CalcDate, @LastDate) <= 1 AND
			                                                 (          
																(@BitClaimAttribAIN | @BitClaimAttribNIN & @LastInpatientType & InpatientType > 0) OR
																(
																	(@BitClaimAttribAIN | @BitClaimAttribIN | @BitClaimAttribNIN & @LastInpatientType > 0) AND --Last stay is any kind of inpatient stay
																	(@BitClaimAttribIN & InpatientType > 0 AND @BitClaimAttribAIN | @BitClaimAttribNIN & InpatientType = 0) -- Current stay is a generic inpatient stay (not clearly acute or nonacute)
																) OR
																(
																	(@BitClaimAttribAIN | @BitClaimAttribIN | @BitClaimAttribNIN & InpatientType > 0) AND --Current stay is any kind of inpatient stay
																	(@BitClaimAttribIN & @LastInpatientType > 0 AND @BitClaimAttribAIN | @BitClaimAttribNIN & @LastInpatientType = 0) -- Last stay is a generic inpatient stay (not clearly acute or nonacute)
																)                                                              
															 )
														THEN @DSClaimID
														END,
														DSClaimLineID),		
					@LastDate = CalcDate,
					@LastInpatientDate = CASE WHEN IsAIN = 1 OR IsIN = 1 OR IsNIN = 1 THEN CalcDate ELSE @LastInpatientDate END,
					@LastInpatientAIN = CASE WHEN IsAIN = 1 THEN ISNULL(@LastInpatientAIN, DSClaimLineAIN) END,
					@LastInpatientID = CASE WHEN IsAIN = 1 OR IsIN = 1 OR IsNIN = 1 THEN @DSClaimID ELSE @LastInpatientID END,
					@LastInpatientIN = CASE WHEN IsIN = 1 THEN ISNULL(@LastInpatientIN, DSClaimLineIN) END,
					@LastInpatientNIN = CASE WHEN IsNIN = 1 THEN ISNULL(@LastInpatientNIN, DSClaimLineNIN) END,
					@LastInpatientType = LastInpatientType = COALESCE(CASE 
																		--COPIED FROM: Identify ED Visit Leading to Inpatient Stays
																		WHEN @DSClaimID IS NOT NULL AND
																				ISNULL(@LastMemberID, DSMemberID) = DSMemberID AND	
																				DATEDIFF(day, CalcDate, @LastInpatientDate) <= @EDCombineDays AND
																				IsED = 1 AND
																				(
																					(@BitClaimAttribAIN | @BitClaimAttribIN | @BitClaimAttribNIN & InpatientType = 0) OR 
																					(
																						(@BitClaimAttribAIN & @LastInpatientType > 0) AND
																						(@BitClaimAttribIN | @BitClaimAttribNIN & InpatientType > 0)
																					)
																				)
																		THEN @LastInpatientType
																		END,
																		CASE 
																			WHEN @LastDSClaimID = @DSClaimID 
																			THEN @LastInpatientType | InpatientType
																			END,                                                          
																		InpatientType),
					@LastMemberID = DSMemberID,
					@LastDSClaimID = @DSClaimID
			FROM	#InpatientClaimLinesByDay AS t
			--Do not change, required for accuracy with "Quirky" UPDATE...
			OPTION (MAXDOP 1); 

			--2c) Update #ClaimLinesBase with the DSClaimID for inpatient/ED visits
			IF OBJECT_ID('tempdb..#InpatientClaims') IS NOT NULL
				DROP TABLE #InpatientClaims;

			SELECT	MIN(CalcDate) AS BeginDate,
					DSClaimID,
					DSMemberID,
					CASE WHEN MIN(DSProviderID) = MAX(DSProviderID) THEN MIN(DSProviderID) END AS DSProviderID,
					MAX(CalcDate) AS EndDate,
					MAX(IsAIN) AS IsAIN,
					MAX(IsED) AS IsED,
					MAX(IsIN) AS IsIN,
					MAX(IsNIN) AS IsNIN,
					CASE WHEN MIN(CalcDate) = MAX(CalcDate) THEN 1 ELSE 0 END AS IsSingleDay
			INTO	#InpatientClaims
			FROM	#InpatientClaimLinesByDay
			GROUP BY DSClaimID, DSMemberID;

			CREATE UNIQUE CLUSTERED INDEX IX_#InpatientClaims ON #InpatientClaims (DSMemberID, EndDate, BeginDate, DSClaimID);

			--Match Acute Inpatient Stays...
			UPDATE	CLB
			SET		DSClaimID = IC.DSClaimID
			FROM	#ClaimLinesBase AS CLB WITH(INDEX(IX_#ClaimLinesBase2))
					INNER JOIN #InpatientClaims AS IC WITH(INDEX(IX_#InpatientClaims))
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
						(
							(CLB.IsUnknown = 1) AND 
							(IsSingleDay = 0) AND 
							(
								((CLB.CalcBeginDate <= IC.BeginDate) AND (CLB.CalcEndDate >= IC.EndDate)) OR 
								((CLB.CalcBeginDate = IC.EndDate) AND (CLB.CalcEndDate = IC.EndDate) AND (CLB.BeginDate < CLB.EndDate) AND (CLB.EndDate > IC.EndDate)) OR 
								((CLB.CalcBeginDate <= IC.BeginDate) AND (CLB.BeginDate < CLB.EndDate) AND (CLB.CalcEndDate BETWEEN IC.BeginDate AND IC.EndDate)) OR                         
								(CLB.CalcBeginDate BETWEEN DATEADD(day, 1, IC.BeginDate) AND DATEADD(day, -1, IC.EndDate)) OR
								(CLB.CalcEndDate BETWEEN DATEADD(day, 1, IC.BeginDate) AND DATEADD(day, -1, IC.EndDate))                              
							)
						)
					) AND 
					(IC.IsAIN = 1);
						
			--Match Non-acute Inpatient Stays...		
			UPDATE	CLB
			SET		DSClaimID = IC.DSClaimID
			FROM	#ClaimLinesBase AS CLB WITH(INDEX(IX_#ClaimLinesBase2))
					INNER JOIN #InpatientClaims AS IC WITH(INDEX(IX_#InpatientClaims))
							ON CLB.DSMemberID = IC.DSMemberID AND
								CLB.CalcBeginDate BETWEEN IC.BeginDate AND IC.EndDate AND
								CLB.CalcEndDate BETWEEN IC.BeginDate AND IC.EndDate
			WHERE	(CLB.DSClaimID IS NULL) AND
					(
						(CLB.IsNIN = 1) OR 
						(CLB.IsIN = 1) OR 
						(CLB.IsED = 1) OR
						(
							(CLB.IsUnknown = 1) AND 
							(IsSingleDay = 0) AND 
							(
								((CLB.CalcBeginDate <= IC.BeginDate) AND (CLB.CalcEndDate >= IC.EndDate)) OR 
								((CLB.CalcBeginDate = IC.EndDate) AND (CLB.CalcEndDate = IC.EndDate) AND (CLB.BeginDate < CLB.EndDate) AND (CLB.EndDate > IC.EndDate)) OR 
								((CLB.CalcBeginDate <= IC.BeginDate) AND (CLB.BeginDate < CLB.EndDate) AND (CLB.CalcEndDate BETWEEN IC.BeginDate AND IC.EndDate)) OR                         
								(CLB.CalcBeginDate BETWEEN DATEADD(day, 1, IC.BeginDate) AND DATEADD(day, -1, IC.EndDate)) OR
								(CLB.CalcEndDate BETWEEN DATEADD(day, 1, IC.BeginDate) AND DATEADD(day, -1, IC.EndDate))                              
							)
						)
					) AND 
					(IC.IsNIN = 1);

			--Match any remaining Inpatient Stays...
			UPDATE	CLB
			SET		DSClaimID = IC.DSClaimID
			FROM	#ClaimLinesBase AS CLB WITH(INDEX(IX_#ClaimLinesBase2))
					INNER JOIN #InpatientClaims AS IC WITH(INDEX(IX_#InpatientClaims))
							ON CLB.DSMemberID = IC.DSMemberID AND
								CLB.CalcBeginDate BETWEEN IC.BeginDate AND IC.EndDate AND
								CLB.CalcEndDate BETWEEN IC.BeginDate AND IC.EndDate
			WHERE	(CLB.DSClaimID IS NULL) AND
					(
						(CLB.IsIN = 1) OR 
						(CLB.IsED = 1) OR
						(
							(CLB.IsUnknown = 1) AND 
							(IsSingleDay = 0) AND 
							(
								((CLB.CalcBeginDate <= IC.BeginDate) AND (CLB.CalcEndDate >= IC.EndDate)) OR 
								((CLB.CalcBeginDate = IC.EndDate) AND (CLB.CalcEndDate = IC.EndDate) AND (CLB.BeginDate < CLB.EndDate) AND (CLB.EndDate > IC.EndDate)) OR 
								((CLB.CalcBeginDate <= IC.BeginDate) AND (CLB.BeginDate < CLB.EndDate) AND (CLB.CalcEndDate BETWEEN IC.BeginDate AND IC.EndDate)) OR                         
								(CLB.CalcBeginDate BETWEEN DATEADD(day, 1, IC.BeginDate) AND DATEADD(day, -1, IC.EndDate)) OR
								(CLB.CalcEndDate BETWEEN DATEADD(day, 1, IC.BeginDate) AND DATEADD(day, -1, IC.EndDate))                            
							)
						)
					) AND 
					(IC.IsIN = 1);
					
			--2d) Match unknowns by same member and provider or surgery specialty when inside an inpatient stay... (added 2/2014)
			SELECT DISTINCT
					CLB.BeginDate,
					CLB.BitSpecialties,
					CLB.DSClaimLineID,
					CLB.DSMemberID,
					CLB.DSProviderID,
					--CLB.EndDate --Replaced by ISNULL statement below on 10/15/2014 for FSP
					ISNULL(CLB.EndDate, CLB.CalcBeginDate) AS EndDate 
			INTO	#UnknownClaims         
			FROM	#ClaimLinesBase AS CLB WITH(INDEX(IX_#ClaimLinesBase2))
					INNER JOIN #InpatientClaims AS IC WITH(INDEX(IX_#InpatientClaims))
							ON CLB.DSMemberID = IC.DSMemberID AND
								(
									(
										(CLB.CalcBeginDate BETWEEN IC.BeginDate AND IC.EndDate) AND
										(CLB.CalcEndDate BETWEEN IC.BeginDate AND IC.EndDate) AND
										(IC.IsSingleDay = 1) AND
										(CLB.EndDate IS NOT NULL) --Not sure if needed, but mirrors old behavior, added 10/15/2014 for FSP
									) OR
									(
										--Added 10/15/2014 for FSP
										(
											(CLB.CalcBeginDate = IC.BeginDate) OR
											(CLB.CalcBeginDate BETWEEN IC.BeginDate AND DATEADD(dd, 1, IC.EndDate)) --Added 1 day calc due to RRU 2/9/2016
										) AND
										(CLB.EndDate IS NULL)
									)
								)

			WHERE	(CLB.IsUnknown = 1) AND          
					(CLB.DSClaimID IS NULL);          

			CREATE UNIQUE CLUSTERED INDEX IX_#UnknownClaims ON #UnknownClaims (DSMemberID, EndDate, BeginDate, DSProviderID, DSClaimLineID);

			SELECT  MIN(CLB.DSClaimID) AS DSClaimID, 
					UC.DSClaimLineID,
					MIN(CLB.DSMemberID) AS DSMemberID
			INTO	#UnknownClaimsCombine
			FROM	#UnknownClaims AS UC WITH(INDEX(IX_#UnknownClaims))
					INNER JOIN #ClaimLinesBase AS CLB WITH(INDEX(IX_#ClaimLinesBase2))
							ON UC.DSMemberID = CLB.DSMemberID AND
								(
									(UC.DSProviderID = CLB.DSProviderID) OR
									(UC.BitSpecialties & @BitSpecialtySurg > 0) OR
									(UC.BitSpecialties & @BitSpecialtyAnesth > 0) --Added for RRU 2/9/2016
								) AND
								(
									((UC.EndDate IS NULL) AND (UC.BeginDate BETWEEN CLB.BeginDate AND DATEADD(dd, -1, CLB.EndDate))) OR
                                    ((UC.EndDate IS NULL) AND (UC.BeginDate = CLB.BeginDate) AND (UC.BeginDate = CLB.EndDate)) OR
									((UC.EndDate IS NOT NULL) AND (UC.BeginDate BETWEEN DATEADD(dd, 1, CLB.BeginDate) AND DATEADD(dd, -1, CLB.EndDate))) OR                                  
									((UC.EndDate IS NOT NULL) AND (UC.EndDate BETWEEN DATEADD(dd, 1, CLB.BeginDate) AND DATEADD(dd, -1, CLB.EndDate))) OR
									((UC.EndDate IS NOT NULL) AND (UC.BeginDate = CLB.BeginDate) AND (UC.EndDate BETWEEN CLB.BeginDate AND CLB.EndDate)) OR                                
									((UC.EndDate IS NOT NULL) AND (UC.BeginDate < UC.EndDate) AND (UC.EndDate = CLB.EndDate) AND (UC.BeginDate BETWEEN CLB.BeginDate AND CLB.EndDate))                             
								)  
			WHERE	(CLB.DSClaimID IS NOT NULL) --(e.g. already determined to be inpatient)        
			GROUP BY UC.DSClaimLineID;

			CREATE UNIQUE CLUSTERED INDEX IX_#UnknownClaimsCombine ON #UnknownClaimsCombine (DSClaimLineID);

			UPDATE	CLB
			SET		DSClaimID = UCC.DSClaimID
			FROM	#ClaimLinesBase AS CLB WITH(INDEX(1))
					INNER JOIN #UnknownClaimsCombine AS UCC WITH(INDEX(IX_#UnknownClaimsCombine))
							ON CLB.DSClaimLineID = UCC.DSClaimLineID;

			--3) Further summarize claim line attributes by member and date for Oupatient Claims only...
			IF OBJECT_ID('tempdb..#OutpatientClaims') IS NOT NULL
				DROP TABLE #OutpatientClaims;

			SELECT	CalcBeginDate,
					CalcEndDate,
					MIN(DSClaimLineID) AS DSClaimID,
					DSMemberID,
					DSProviderID
			INTO	#OutpatientClaims
			FROM	#ClaimLinesBase
			WHERE	DSClaimID IS NULL
			GROUP BY CalcBeginDate,
					CalcEndDate,
					DSMemberID,
					DSProviderID;
					
			CREATE UNIQUE CLUSTERED INDEX IX_#OutpatientClaims ON #OutpatientClaims (DSMemberID, CalcEndDate, CalcBeginDate, DSProviderID);

			UPDATE	CLB
			SET		DSClaimID = OC.DSClaimID
			FROM	#ClaimLinesBase AS CLB WITH(INDEX(IX_#ClaimLinesBase2))
					INNER JOIN #OutpatientClaims AS OC WITH(INDEX(IX_#OutpatientClaims))
							ON CLB.CalcBeginDate = OC.CalcBeginDate AND
								CLB.CalcEndDate = OC.CalcEndDate AND
								CLB.DSMemberID = OC.DSMemberID AND
								CLB.DSProviderID = OC.DSProviderID
			WHERE	(CLB.DSClaimID IS NULL);
					
			--4) Create composite claim key for applying to actual claims...
			IF OBJECT_ID('tempdb..#ClaimKey') IS NOT NULL
				DROP TABLE #ClaimKey;
					
			SELECT	MIN(BeginDate) AS BeginDate,
					ISNULL(DSClaimID, DSClaimLineID) AS DSClaimID,
					DSClaimLineID,
					MAX(EndDate) AS EndDate,
					CONVERT(bit, CASE WHEN DSMemberID < 0 THEN 1 ELSE 0 END) AS IsSupplemental
			INTO	#ClaimKey
			FROM	#ClaimLinesBase
			GROUP BY DSClaimID, DSClaimLineID, DSMemberID;
		
			CREATE UNIQUE CLUSTERED INDEX IX_#ClaimKey ON #ClaimKey (DSClaimLineID);

			--Added 2/20/2014 as part of RRU certification----------------------------------------------
			CREATE NONCLUSTERED INDEX IX_#ClaimKey_DSClaimID ON #ClaimKey (DSClaimID) INCLUDE (BeginDate, EndDate);

			SELECT MIN(BeginDate) AS BeginDate, DSClaimID, MAX(EndDate) AS EndDate INTO #ClaimKeyDates FROM #ClaimKey GROUP BY DSClaimID;
			CREATE UNIQUE CLUSTERED INDEX IX_#ClaimKeyDates ON #ClaimKeyDates (DSClaimID);

			UPDATE	CK
			SET		BeginDate = CKD.BeginDate,
					EndDate = CKD.EndDate
			FROM	#ClaimKey AS CK WITH(INDEX(IX_#ClaimKey_DSClaimID))
					INNER JOIN #ClaimKeyDates AS CKD WITH(INDEX(IX_#ClaimKeyDates))
							ON CK.DSClaimID = CKD.DSClaimID; 
							
			DROP INDEX IX_#ClaimKey_DSClaimID ON #ClaimKey;
			DROP TABLE #ClaimKeyDates;         
			
			--------------------------------------------------------------------------------------------
			--5) If Debug, Output key temp tables...
			IF ISNULL(@IsDebug, 0) = 1
				BEGIN;
					--5a) #ClaimLinesBase
					IF OBJECT_ID('Temp.Batch_CombineClaims_ClaimLinesBase') IS NOT NULL	
						DROP TABLE Temp.Batch_CombineClaims_ClaimLinesBase;
						
					SELECT * INTO Temp.Batch_CombineClaims_ClaimLinesBase FROM #ClaimLinesBase WHERE ((@DebugDSMemberID IS NULL) OR (DSMemberID = @DebugDSMemberID));
					
					--5b) #OutpatientClaims
					IF OBJECT_ID('Temp.Batch_CombineClaims_OutpatientClaims') IS NOT NULL	
						DROP TABLE Temp.Batch_CombineClaims_OutpatientClaims;
						
					SELECT * INTO Temp.Batch_CombineClaims_OutpatientClaims FROM #OutpatientClaims WHERE ((@DebugDSMemberID IS NULL) OR (DSMemberID = @DebugDSMemberID));
					
					--5c) #InpatientClaimLinesByDay
					IF OBJECT_ID('Temp.Batch_CombineClaims_InpatientClaimLinesByDay') IS NOT NULL	
						DROP TABLE Temp.Batch_CombineClaims_InpatientClaimLinesByDay;
						
					SELECT * INTO Temp.Batch_CombineClaims_InpatientClaimLinesByDay FROM #InpatientClaimLinesByDay WHERE ((@DebugDSMemberID IS NULL) OR (DSMemberID = @DebugDSMemberID));
					
					--5d) #InpatientClaims
					IF OBJECT_ID('Temp.Batch_CombineClaims_InpatientClaims') IS NOT NULL	
						DROP TABLE Temp.Batch_CombineClaims_InpatientClaims;
						
					SELECT * INTO Temp.Batch_CombineClaims_InpatientClaims FROM #InpatientClaims WHERE ((@DebugDSMemberID IS NULL) OR (DSMemberID = @DebugDSMemberID));
					
					--5e) #UnknownClaims
					IF OBJECT_ID('Temp.Batch_CombineClaims_UnknownClaims') IS NOT NULL	
						DROP TABLE Temp.Batch_CombineClaims_UnknownClaims;
						
					SELECT * INTO Temp.Batch_CombineClaims_UnknownClaims FROM #UnknownClaims WHERE ((@DebugDSMemberID IS NULL) OR (DSMemberID = @DebugDSMemberID));
					
					--5f) #UnknownClaimsCombine
					IF OBJECT_ID('Temp.Batch_CombineClaims_UnknownClaimsCombine') IS NOT NULL	
						DROP TABLE Temp.Batch_CombineClaims_UnknownClaimsCombine;
						
					SELECT * INTO Temp.Batch_CombineClaims_UnknownClaimsCombine FROM #UnknownClaimsCombine WHERE ((@DebugDSMemberID IS NULL) OR (DSMemberID = @DebugDSMemberID));

					--5g) #ClaimKey
					IF OBJECT_ID('Temp.Batch_CombineClaims_ClaimKey') IS NOT NULL	
						DROP TABLE Temp.Batch_CombineClaims_ClaimKey;
						
					SELECT * INTO Temp.Batch_CombineClaims_ClaimKey FROM #ClaimKey;
				END;
			--------------------------------------------------------------------------------------------

			--6) Apply DSClaimIDs to the Proxy claims tables...
			--UPDATE Claim Lines with DSClaimID------------------
			IF @AllowClaimUpdates = 1 OR 1 = 1
				UPDATE	CL
				SET		DSClaimID = ISNULL(t.DSClaimID, CL.DSClaimLineID)
				FROM	Proxy.ClaimLines AS CL
						LEFT OUTER JOIN #ClaimKey AS t
								ON CL.DSClaimLineID = t.DSClaimLineID
				WHERE	(CL.DSClaimID IS NULL);

			--UPDATE Claim Codes with DSClaimID-----------------
			IF @AllowClaimUpdates = 1 OR 1 = 1
				UPDATE	CC
				SET		DSClaimID = ISNULL(t.DSClaimID, CC.DSClaimLineID)
				FROM	Proxy.ClaimCodes AS CC
						LEFT OUTER JOIN #ClaimKey AS t
								ON CC.DSClaimLineID = t.DSClaimLineID
				WHERE	(CC.DSClaimID IS NULL);
			
			--UPDATE Claim Source with DSClaimID----------------
			UPDATE	CS
			SET		ClaimBeginDate = COALESCE(t.BeginDate, CS.BeginDate),
					ClaimCompareDate = COALESCE(t.EndDate, t.BeginDate, CS.EndDate, CS.BeginDate),
					ClaimEndDate = COALESCE(t.EndDate, CS.EndDate),
					DSClaimID = ISNULL(t.DSClaimID, CS.DSClaimLineID)
			FROM	Proxy.ClaimSource AS CS
					LEFT OUTER JOIN #ClaimKey AS t WITH(INDEX(1))
							ON CS.DSClaimLineID = t.DSClaimLineID
			WHERE	(CS.DSClaimID IS NULL)
			OPTION (FORCE ORDER);
			
			SELECT @CountRecords = @@ROWCOUNT;

			--INSERT Final Claims-------------------------------
			IF @AllowClaimUpdates = 1 OR 1 = 1
				BEGIN;
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
					
					SELECT @CountRecords = @@ROWCOUNT;
				END;

			--UPDATE Event Base with DSClaimID-------------------
			UPDATE	VB
			SET		DSClaimID = ISNULL(t.DSClaimID, VB.DSClaimLineID)
			FROM	Proxy.EventBase AS VB
					LEFT OUTER JOIN #ClaimKey AS t
							ON VB.DSClaimLineID = t.DSClaimLineID
			WHERE	(VB.DSClaimID IS NULL);
			
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
			SET @LogDescr = ' - Combining claims for BATCH ' + ISNULL(CAST(@BatchID AS varchar), '?') + ' refresh failed!'; --{FAILURE LOG DESCRIPTION HERE}
			
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
GRANT VIEW DEFINITION ON  [Batch].[CombineClaims] TO [db_executer]
GO
GRANT EXECUTE ON  [Batch].[CombineClaims] TO [db_executer]
GO
GRANT EXECUTE ON  [Batch].[CombineClaims] TO [Processor]
GO
