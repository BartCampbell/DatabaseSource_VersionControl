SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- =============================================
-- Author:		Kriz, Mike
-- Create date: 7/26/2011
-- Description:	Determines valid entity enrollment.
-- =============================================
CREATE PROCEDURE [Batch].[ValidateEntityEnrollment_v2]
(
	@BatchID int,
	@CountRecords bigint = 0 OUTPUT,
	@Iteration tinyint
)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @Debug bit;
	SET @Debug = 1;
	
	DECLARE @LogBeginTime datetime;
	DECLARE @LogDescr varchar(256);
	DECLARE @LogEndTime datetime;
	DECLARE @LogObjectName nvarchar(128);
	DECLARE @LogObjectSchema nvarchar(128);
	
	DECLARE @BeginInitSeedDate datetime;
	DECLARE @CalculateXml bit;
	DECLARE @DataRunID int;
	DECLARE @DataSetID int;
	DECLARE @EndInitSeedDate datetime;
	DECLARE @IsLogged bit;
	DECLARE @MeasureSetID int;
	DECLARE @OwnerID int;
	DECLARE @SeedDate datetime;
	
	BEGIN TRY;
		
		SET @LogBeginTime = GETDATE();
		SET @LogObjectName = 'ValidateEntityEnrollment'; 
		SET @LogObjectSchema = 'Batch'; 
	
		SELECT	@BeginInitSeedDate = DR.BeginInitSeedDate,
				@CalculateXml = DR.CalculateXml,
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
		
		----------------------------------------------------------------------------------------------
		IF @BatchID IS NOT NULL AND	@Iteration IS NOT NULL AND EXISTS (SELECT TOP 1 1 FROM Proxy.EntityBase)
			BEGIN;
				DECLARE @Result int;
				
				--Determines the current state of ANSI_WARNINGS and sets it to "OFF" if necessary (Prevents NULL aggregate messages during the INSERT statement)...
				DECLARE @Ansi_Warnings bit;
				SET @Ansi_Warnings = CASE WHEN (@@OPTIONS & 8) = 8 THEN 1 ELSE 0 END;

				IF @Ansi_Warnings = 1
					SET ANSI_WARNINGS OFF;
				
				SELECT	BenefitID,
						ISNULL(MIN(CASE WHEN ActualHasPayer = 1 AND ActualEnrollGroupID IS NOT NULL THEN BitProductLines END), MIN(BitProductLines)) AS BitProductLines,
						ISNULL(MIN(CASE WHEN ActualHasPayer = 1 THEN ActualEnrollGroupID END), MIN(ActualEnrollGroupID)) AS EnrollGroupID,
						EntityBaseID, 
						EntityID,
						MAX(ActualHasAnchor) AS HasAnchor,
						MAX(ActualHasPayer) AS HasPayer,
						ISNULL(MAX(LastSegBeginDate), MAX(CASE WHEN ActualHasPayer = 1 THEN EnrollSegBeginDate END)) AS LastSegBeginDate,
						ISNULL(MAX(LastSegEndDate), MAX(CASE WHEN ActualHasPayer = 1 THEN EnrollSegEndDate END)) AS LastSegEndDate,
						MeasEnrollID,
						OptionNbr,
						ProductClassID,
						MAX(ActualGaps) AS TotGaps
				INTO	#Enrollment
				FROM	Proxy.EntityEnrollment AS TEN
				--WHERE	(ActualBeginDate <= TEN.EndEnrollDate) --Added WHERE to combat bad data in AAB Deck, 11/9/2015.  (Overlapping enrollment segments, exposed by remove of ProductlassID filtering)
				GROUP BY BenefitID,
						EntityBaseID, 
						EntityID,
						MeasEnrollID,
						OptionNbr,
						ProductClassID,
						CASE WHEN ActualHasPayer = 1 THEN ActualEnrollGroupID END --Added 4/13/2016 to allow for dual-eligibles under different enrollment groups to be counted as both
				HAVING	SUM(ActualGaps) <= MAX(Gaps) AND
						SUM(ActualGapDays) <= MAX(GapDays) AND
						SUM(ActualGapMaxDays) <= MAX(GapDays);
						
				IF @Debug = 1 AND @@ROWCOUNT = 0 --Disable overwrite of tables if the resultset returns no rows to evaluate. (Prevents secondary iterations from clearing the table.) 
					SET @Debug = 0;

				IF @Debug = 1
					BEGIN;
						IF OBJECT_ID('Temp.ValidateEntityEnrollment_Enrollment') IS NOT NULL
							DROP TABLE Temp.ValidateEntityEnrollment_Enrollment;

						SELECT * INTO Temp.ValidateEntityEnrollment_Enrollment FROM #Enrollment;
					END;

				SELECT	COUNT(*) AS CountBenefits, MeasEnrollID
				INTO	#Benefits
				FROM	Measure.EnrollmentBenefits 
				GROUP BY MeasEnrollID
				
				CREATE UNIQUE CLUSTERED INDEX IX_#Benefits ON #Benefits (MeasEnrollID);
					
				SELECT	COUNT(*) AS CountEnrolls, MEN.EntityID, 
						CONVERT(bit, MIN(CONVERT(tinyint, MEN.IgnoreClass))) AS IgnoreClass,
						ME.MaxEnrollGaps, MEN.OptionNbr
				INTO	#Enrolls
				FROM	Measure.EntityEnrollment AS MEN
						INNER JOIN Measure.Entities AS ME
								ON MEN.EntityID = ME.EntityID
				WHERE	(MEN.IsEnabled = 1)
				GROUP BY MEN.EntityID, MEN.OptionNbr, ME.MaxEnrollGaps
				
				CREATE UNIQUE CLUSTERED INDEX IX_#Enrolls ON #Enrolls (EntityID, OptionNbr);
				
				SELECT	ISNULL(MIN(CASE WHEN t.HasPayer = 1 THEN t.BitProductLines END), MIN(t.BitProductLines)) AS BitProductLines,
						ISNULL(MIN(CASE WHEN t.HasPayer = 1 THEN t.EnrollGroupID END), MIN(t.EnrollGroupID)) AS EnrollGroupID,
						t.EntityBaseID, t.EntityID, MAX(t.HasPayer) AS HasPayer,
						MAX(t.LastSegBeginDate) AS LastSegBeginDate,
						MAX(t.LastSegEndDate) AS LastSegEndDate,
						t.MeasEnrollID, t.OptionNbr, MAX(t.TotGaps) AS TotGaps
				INTO	#ValidEnrolls
				FROM	#Enrollment AS t
						INNER JOIN #Benefits AS B
								ON t.MeasEnrollID = B.MeasEnrollID 
						/* Evaluate Anchor Date ***************************/
						INNER JOIN Measure.Enrollment AS MEN
								ON t.MeasEnrollID = MEN.MeasEnrollID AND
									(
										(
											(MEN.AnchorDays IS NULL) AND
											(MEN.AnchorMonths IS NULL)
										) OR
										(t.HasAnchor = 1)
									)
						/***************************************************/
				GROUP BY B.CountBenefits, 
						t.EntityBaseID, 
						t.EntityID, 
						t.MeasEnrollID, 
						t.OptionNbr,
						CASE WHEN t.HasPayer = 1 THEN t.EnrollGroupID END --Added 4/13/2016 to allow for dual-eligibles under different enrollment groups to be counted as both
				HAVING (COUNT(DISTINCT t.BenefitID) >= B.CountBenefits)

				IF @Debug = 1
					BEGIN;
						IF OBJECT_ID('Temp.ValidateEntityEnrollment_ValidEnrolls') IS NOT NULL
							DROP TABLE Temp.ValidateEntityEnrollment_ValidEnrolls;

						SELECT * INTO Temp.ValidateEntityEnrollment_ValidEnrolls FROM #ValidEnrolls;
					END;
				
				CREATE UNIQUE CLUSTERED INDEX IX_#ValidEnrolls ON #ValidEnrolls (EntityID, OptionNbr, MeasEnrollID, EntityBaseID, EnrollGroupID);
				
				DELETE FROM Proxy.EntityEligible;
				
				SELECT 	ISNULL(MIN(CASE WHEN t.HasPayer = 1 THEN t.BitProductLines END), MIN(t.BitProductLines)) AS BitProductLines,
						ISNULL(MIN(CASE WHEN t.HasPayer = 1 THEN t.EnrollGroupID END), MIN(t.EnrollGroupID)) AS EnrollGroupID,
						t.EntityBaseID, t.EntityID, 
						IDENTITY(bigint, 1, 1) AS ID,
						MAX(t.LastSegBeginDate) AS LastSegBeginDate,
						MAX(t.LastSegEndDate) AS LastSegEndDate,
						t.OptionNbr
				INTO	#ValidOptions
				FROM	#ValidEnrolls AS t
						INNER JOIN #Enrolls AS N
								ON t.EntityID = N.EntityID AND
									t.OptionNbr = N.OptionNbr 
						INNER JOIN Proxy.EnrollmentKey AS PEK
								ON t.EnrollGroupID = PEK.EnrollGroupID 
				GROUP BY N.CountEnrolls, t.EntityBaseID, t.EntityID, t.OptionNbr, N.MaxEnrollGaps, 
						CASE WHEN N.IgnoreClass = 1 THEN 0 ELSE PEK.ProductClassID END, --Added HEDIS 2016 as part of the "HasPayer" code
						CASE WHEN t.HasPayer = 1 THEN t.EnrollGroupID END --Added 4/13/2016 to allow for dual-eligibles under different enrollment groups to be counted as both
				HAVING	(COUNT(DISTINCT t.MeasEnrollID) >= N.CountEnrolls) AND
						(SUM(t.TotGaps) <= ISNULL(N.MaxEnrollGaps, SUM(t.TotGaps)))
				ORDER BY t.EntityID, t.OptionNbr, t.EntityBaseID;

				CREATE UNIQUE CLUSTERED INDEX IX_#ValidOptions ON #ValidOptions (ID);
				CREATE NONCLUSTERED INDEX IX_#ValidOptions2 ON #ValidOptions (EnrollGroupID, EntityID) INCLUDE (EntityBaseID, LastSegBeginDate, LastSegEndDate);

				IF @Debug = 1
					BEGIN;
						IF OBJECT_ID('Temp.ValidateEntityEnrollment_ValidOptions') IS NOT NULL
							DROP TABLE Temp.ValidateEntityEnrollment_ValidOptions;

						SELECT * INTO Temp.ValidateEntityEnrollment_ValidOptions FROM #ValidOptions;
					END;

				WITH EnrollmentFreeEntities AS
				(
					SELECT DISTINCT
							ME.EntityID
					FROM	Measure.Entities AS ME
							LEFT OUTER JOIN Measure.EntityEnrollment AS MEN
									ON ME.EntityID = MEN.EntityID AND
										MEN.IsEnabled = 1
					WHERE	(ME.MeasureSetID = @MeasureSetID) AND
							(MEN.MeasEnrollID IS NULL)
				)
				SELECT	@BatchID AS BatchID,
						MIN(t.BitProductLines) AS BitProductLines,
						@DataRunID AS DataRunID,
						@DataSetID AS DataSetID,
						MIN(t.EnrollGroupID) AS EnrollGroupID, 
						t.EntityBaseID,
						MAX(t.LastSegBeginDate) AS LastSegBeginDate,
						MAX(t.LastSegEndDate) AS LastSegEndDate
				INTO	#EntityEligible
				FROM	#ValidOptions AS t
						/***** APPLIES PRODUCT LINE REQUIREMENTS ***************************/
						INNER JOIN Measure.EntityProductLines AS MEPL
								ON t.EntityID = MEPL.EntityID
						INNER JOIN Proxy.EnrollmentKey AS PEK
								ON t.EnrollGroupID = PEK.EnrollGroupID 
						INNER JOIN Product.PayerProductLines AS PPPL 
								ON PEK.PayerID = PPPL.PayerID AND
									MEPL.ProductLineID = PPPL.ProductLineID
						/*******************************************************************/
				GROUP BY t.EntityBaseID, 
						t.EnrollGroupID --Added 4/13/2016 to allow for dual-eligibles under different enrollment groups to be counted as both
				UNION 
				SELECT DISTINCT
						@BatchID AS BatchID,
						0 AS BitProductLines,
						@DataRunID AS DataRunID,
						@DataSetID AS DataSetID,
						-1 AS EnrollGroupID, 
						EntityBaseID,
						NULL AS LastSegBeginDate,
						NULL AS LastSegEndDate
				FROM	Proxy.EntityBase AS TEB
						INNER JOIN EnrollmentFreeEntities AS t
								ON TEB.EntityID = t.EntityID AND
									TEB.RankOrder = 1;
									
				IF @Debug = 1
					BEGIN;
						IF OBJECT_ID('Temp.ValidateEntityEnrollment_EntityEligible') IS NOT NULL
							DROP TABLE Temp.ValidateEntityEnrollment_EntityEligible;

						SELECT * INTO Temp.ValidateEntityEnrollment_EntityEligible FROM #EntityEligible;
					END;

				IF @Ansi_Warnings = 1
					SET ANSI_WARNINGS ON;

				CREATE UNIQUE CLUSTERED INDEX IX_#EntityEligible ON #EntityEligible (EntityBaseID, EnrollGroupID);

				IF OBJECT_ID('tempdb..#ExtendSegments') IS NOT NULL
					DROP TABLE #ExtendSegments;

				CREATE TABLE #ExtendSegments
				(
					BitBenefits bigint NOT NULL,
					DSMemberID bigint NOT NULL,
					EnrollGroupID int NOT NULL,
					EntityBaseID bigint NOT NULL,
					LastSegDate datetime NOT NULL,
					LoopCounter smallint NOT NULL DEFAULT (0),
					NewDate datetime NOT NULL,
					ProductClassID tinyint NOT NULL
				);

				SELECT	SUM(DISTINCT PB.BitValue) AS BitBenefits,
						SUM(DISTINCT PPL.BitValue) AS BitProductLines,
						ME.EntityID,
						CONVERT(bit, MIN(CONVERT(tinyint, MEN.IgnoreClass))) AS IgnoreClass,
						ME.ReqAllEnrollSegInProdLines
				INTO	#EntityEnrollmentReqs
				FROM	Measure.Entities AS ME
						INNER JOIN Measure.EntityProductLines AS MEPL
								ON MEPL.EntityID = ME.EntityID
						INNER JOIN Product.ProductLines AS PPL
								ON PPL.ProductLineID = MEPL.ProductLineID
						INNER JOIN Measure.EntityEnrollment AS MEN
								ON MEN.EntityID = ME.EntityID
						INNER JOIN Measure.EnrollmentBenefits AS MNB
								ON MNB.MeasEnrollID = MEN.MeasEnrollID
						INNER JOIN Product.Benefits AS PB
								ON PB.BenefitID = MNB.BenefitID
				WHERE	ME.IsEnabled = 1 AND
						ME.MeasureSetID = @MeasureSetID
				GROUP BY ME.EntityID,
						ME.ReqAllEnrollSegInProdLines;

				CREATE UNIQUE CLUSTERED INDEX IX_#EntityEnrollmentReqs ON #EntityEnrollmentReqs (EntityID);

				SELECT	PNK.BatchID,
						SUM(DISTINCT PPL.BitValue) AS BitProductLines,
                        PNK.DataRunID,
                        PNK.DataSetID,
                        PNK.EnrollGroupID,
                        PNK.PayerID,
                        PNK.PopulationID,
                        PNK.ProductClassID,
                        PNK.ProductTypeID
				INTO	#EnrollmentKey
				FROM	Proxy.EnrollmentKey AS PNK 
						INNER JOIN Product.PayerProductLines AS PPPL WITH(NOLOCK)
								ON PPPL.PayerID = PNK.PayerID
						INNER JOIN Product.ProductLines AS PPL WITH(NOLOCK)
								ON PPL.ProductLineID = PPPL.ProductLineID
				GROUP BY PNK.BatchID,
                        PNK.DataRunID,
                        PNK.DataSetID,
                        PNK.EnrollGroupID,
                        PNK.PayerID,
                        PNK.PopulationID,
                        PNK.ProductClassID,
                        PNK.ProductTypeID;

				CREATE UNIQUE CLUSTERED INDEX IX_#EnrollmentKey ON #EnrollmentKey (EnrollGroupID, ProductClassID, BatchID);
						
				--Part A: Extend segments earlier, when applicable...
				INSERT INTO #ExtendSegments
						(BitBenefits,
						DSMemberID,
						EnrollGroupID,
						EntityBaseID,
						LastSegDate,
						NewDate,
						ProductClassID)
				SELECT DISTINCT
						ISNULL(ENR.BitBenefits, 0) AS BitBenefits,
						PEB.DSMemberID,
						PEL.EnrollGroupID,
						PEL.EntityBaseID, 
						PEL.LastSegBeginDate, 
						PEL.LastSegBeginDate AS NewDate, 
						CASE WHEN ENR.IgnoreClass = 1 THEN 0 ELSE PNK.ProductClassID END AS ProductClassID
				FROM	#EntityEligible AS PEL
						INNER JOIN Proxy.EntityBase AS PEB
								ON PEL.BatchID = PEB.BatchID AND
									PEL.DataRunID = PEB.DataRunID AND
									PEL.DataSetID = PEB.DataSetID AND
									PEL.EntityBaseID = PEB.EntityBaseID              
						INNER JOIN #EnrollmentKey PNK
								ON PEL.BatchID = PNK.BatchID AND
									PEL.DataRunID = PNK.DataRunID AND
									PEL.DataSetID = PNK.DataSetID AND
									PEL.EnrollGroupID = PNK.EnrollGroupID
						LEFT OUTER JOIN #EntityEnrollmentReqs AS ENR
								ON ENR.EntityID = PEB.EntityID
				WHERE	(PEL.LastSegBeginDate IS NOT NULL) AND
						(
							(ENR.ReqAllEnrollSegInProdLines = 0) OR
							(PNK.BitProductLines & ENR.BitProductLines > 0)
						);

				CREATE UNIQUE CLUSTERED INDEX IX_#ExtendSegments ON #ExtendSegments (EntityBaseID, EnrollGroupID);       
				CREATE NONCLUSTERED INDEX IX_#ExtendSegments2 ON #ExtendSegments (DSMemberID, NewDate);

				DECLARE @i smallint;

				SET @i = 0;
				WHILE (1 = 1)
					BEGIN;
						SET @i = @i + 1;

						UPDATE	t
						SET		LoopCounter = LoopCounter + 1,
								NewDate = PN.BeginDate
						FROM	#ExtendSegments AS t
								INNER JOIN Proxy.Enrollment AS PN
										ON t.DSMemberID = PN.DSMemberID AND
											t.NewDate BETWEEN PN.EndDate AND DATEADD(dd, 1, PN.EndDate) AND
											PN.EndDate > PN.BeginDate AND
											PN.BitBenefits & t.BitBenefits = t.BitBenefits
								INNER JOIN Proxy.EnrollmentKey AS PNK
										ON PN.BatchID = PNK.BatchID AND
											PN.DataRunID = PNK.DataRunID AND
											PN.DataSetID = PNK.DataSetID AND
											PN.EnrollGroupID = PNK.EnrollGroupID AND
											(t.ProductClassID = 0 OR t.ProductClassID = PNK.ProductClassID);

						IF @@ROWCOUNT = 0 OR @i >= 1000
							BREAK;
					END;

				UPDATE	EL
				SET		LastSegBeginDate = NewDate
				FROM	#EntityEligible AS EL
						INNER JOIN #ExtendSegments AS t
								ON EL.EntityBaseID = t.EntityBaseID
				WHERE	(t.LoopCounter > 0);

				TRUNCATE TABLE #ExtendSegments;
				DROP INDEX IX_#ExtendSegments ON #ExtendSegments;
				DROP INDEX IX_#ExtendSegments2 ON #ExtendSegments;
				
				--Part B: Extend segments later, when applicable...
				INSERT INTO #ExtendSegments
						(BitBenefits,
						DSMemberID,
						EnrollGroupID,
						EntityBaseID,
						LastSegDate,
						NewDate,
						ProductClassID)
				SELECT DISTINCT
						ISNULL(ENR.BitBenefits, 0) AS BitBenefits,
						PEB.DSMemberID,
						PEL.EnrollGroupID,
						PEL.EntityBaseID, 
						PEL.LastSegEndDate, 
						PEL.LastSegEndDate AS NewDate, 
						CASE WHEN ENR.IgnoreClass = 1 THEN 0 ELSE PNK.ProductClassID END AS ProductClassID
				FROM	#EntityEligible AS PEL
						INNER JOIN Proxy.EntityBase AS PEB
								ON PEL.BatchID = PEB.BatchID AND
									PEL.DataRunID = PEB.DataRunID AND
									PEL.DataSetID = PEB.DataSetID AND
									PEL.EntityBaseID = PEB.EntityBaseID              
						INNER JOIN #EnrollmentKey PNK
								ON PEL.BatchID = PNK.BatchID AND
									PEL.DataRunID = PNK.DataRunID AND
									PEL.DataSetID = PNK.DataSetID AND
									PEL.EnrollGroupID = PNK.EnrollGroupID
						LEFT OUTER JOIN #EntityEnrollmentReqs AS ENR
								ON ENR.EntityID = PEB.EntityID
				WHERE	(PEL.LastSegBeginDate IS NOT NULL) AND
						(
							(ENR.EntityID IS NULL) OR
							(PNK.BitProductLines & ENR.BitProductLines > 0)
						);

				CREATE UNIQUE CLUSTERED INDEX IX_#ExtendSegments ON #ExtendSegments (EntityBaseID, EnrollGroupID);       
				CREATE NONCLUSTERED INDEX IX_#ExtendSegments2 ON #ExtendSegments (DSMemberID, NewDate);

				SET @i = 0;
				WHILE (1 = 1)
					BEGIN;
						SET @i = @i + 1;

						UPDATE	t
						SET		LoopCounter = LoopCounter + 1,
								NewDate = PN.EndDate
						FROM	#ExtendSegments AS t
								INNER JOIN Proxy.Enrollment AS PN
										ON t.DSMemberID = PN.DSMemberID AND
											t.NewDate BETWEEN DATEADD(dd, -1, PN.BeginDate) AND PN.BeginDate AND
											PN.EndDate > PN.BeginDate AND
											PN.BitBenefits & t.BitBenefits = t.BitBenefits               
								INNER JOIN Proxy.EnrollmentKey AS PNK
										ON PN.BatchID = PNK.BatchID AND
											PN.DataRunID = PNK.DataRunID AND
											PN.DataSetID = PNK.DataSetID AND
											PN.EnrollGroupID = PNK.EnrollGroupID AND
											(t.ProductClassID = 0 OR t.ProductClassID = PNK.ProductClassID);

						IF @@ROWCOUNT = 0 OR @i >= 1000
							BREAK;
					END;

				UPDATE	EL
				SET		LastSegEndDate = NewDate
				FROM	#EntityEligible AS EL
						INNER JOIN #ExtendSegments AS t
								ON EL.EntityBaseID = t.EntityBaseID AND
									t.EnrollGroupID = EL.EnrollGroupID
				WHERE	(t.LoopCounter > 0);

				TRUNCATE TABLE #ExtendSegments;


				INSERT INTO Proxy.EntityEligible
						(BatchID,
						BitProductLines,
						DataRunID,
						DataSetID,
						EnrollGroupID,
						EntityBaseID,
						LastSegBeginDate,
						LastSegEndDate)
				SELECT	BatchID,
						BitProductLines,
						DataRunID,
						DataSetID,
						EnrollGroupID,
						EntityBaseID,
						LastSegBeginDate,
						LastSegEndDate
				FROM	#EntityEligible
				ORDER BY EntityBaseID;

				IF @CalculateXml = 1 
					BEGIN;
						--Build Xml enrollment element(s)...
						SELECT	t.EntityBaseID,
								t.EnrollGroupID,
								EntityEnrollInfo = (
														SELECT	PPC.Abbrev AS class,
																dbo.ConvertDateToYYYYMMDD(t.LastSegBeginDate) AS lastSegBeginDate,
																dbo.ConvertDateToYYYYMMDD(t.LastSegEndDate) AS lastSegEndDate,
																PP.Abbrev AS payer,
																Member.ConvertEnrollGroupIDToGuid(t.EnrollGroupID) AS payerinfo,
																NULLIF(Product.ConvertBitProductLinesToAbbrevs(t.BitProductLines), '') AS productLines
														FOR XML RAW('enrollment'), TYPE
													)
						INTO	#EntityEligibleXml
						FROM	#EntityEligible AS t
								INNER JOIN Proxy.EnrollmentKey AS PEK
										ON PEK.EnrollGroupID = t.EnrollGroupID
								INNER JOIN Product.Payers AS PP
										ON PP.PayerID = PEK.PayerID
								INNER JOIN Product.ProductClasses AS PPC
										ON PPC.ProductClassID = PEK.ProductClassID;

						--Consolidate and apply Xml enrollment element(s)...
						WITH EntityEligibleXml AS
						(
							SELECT	EntityBaseID,
									dbo.CombineXml(EntityEnrollInfo, 1) AS EntityEnrollInfo
							FROM	#EntityEligibleXml
							GROUP BY EntityBaseID
						)
						UPDATE	PEB
						SET		EntityEnrollInfo = t.EntityEnrollInfo
						FROM	Proxy.EntityBase AS PEB
								INNER JOIN EntityEligibleXml AS t
										ON t.EntityBaseID = PEB.EntityBaseID;
					END;

				SET @CountRecords = ISNULL(@CountRecords, 0) + @@ROWCOUNT;
			END;
		
		RETURN 0;
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
											@PerformRollback = 0,
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
GRANT VIEW DEFINITION ON  [Batch].[ValidateEntityEnrollment_v2] TO [db_executer]
GO
GRANT EXECUTE ON  [Batch].[ValidateEntityEnrollment_v2] TO [db_executer]
GO
GRANT EXECUTE ON  [Batch].[ValidateEntityEnrollment_v2] TO [Processor]
GO
