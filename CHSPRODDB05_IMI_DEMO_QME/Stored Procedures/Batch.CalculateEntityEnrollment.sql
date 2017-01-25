SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 2/17/2011
-- Description:	Calculates continuous enrollment for entities.
-- =============================================
CREATE PROCEDURE [Batch].[CalculateEntityEnrollment]
(
	@BatchID int,
	@CountRecords bigint = 0 OUTPUT,
	@Iteration tinyint
)
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @BeginInitSeedDate datetime;
	DECLARE @DataRunID int;
	DECLARE @DataSetID int;
	DECLARE @EndInitSeedDate datetime;
	DECLARE @IsLogged bit;
	DECLARE @MeasureSetID int;
	DECLARE @OwnerID int;
	DECLARE @SeedDate datetime;
	
	BEGIN TRY;
		
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
		WHERE (B.BatchID = @BatchID);
			
		----------------------------------------------------------------------------------------------
		IF @BatchID IS NOT NULL AND	@Iteration IS NOT NULL
			BEGIN;
			
				/**MOVED TO PROCESSENTITIES******************************************************************************/
				--DECLARE @Result int;
				--EXEC @Result = Batch.QuantifyEntityCriteria @BatchID = @BatchID, @Iteration = @Iteration;
				
				--IF @Result <> 0
				--	RAISERROR('Unable to quantify entity criteria.  Enrollment initialization failed!', 16, 1);
							
				--EXEC @Result = Batch.ProcessEntityEnrollment @BatchID = @BatchID, @Iteration = @Iteration;
							
				--IF @Result <> 0
				--	RAISERROR('Unable to calculate entity enrollment.  Enrollment initialization failed!', 16, 1);
				/********************************************************************************************************/
							
				--STEP #1, Identify valid product lines for entities when restricted...
				SELECT	SUM(DISTINCT PPL.BitValue) AS BitProductLines,
						ME.EntityID
				INTO	#EntityEnrollmentReqs
				FROM	Measure.Entities AS ME WITH(NOLOCK)
						INNER JOIN Measure.EntityProductLines AS MEPL WITH(NOLOCK)
								ON MEPL.EntityID = ME.EntityID
						INNER JOIN Product.ProductLines AS PPL
								ON PPL.ProductLineID = MEPL.ProductLineID
				WHERE	ME.ReqAllEnrollSegInProdLines = 1 AND
						ME.MeasureSetID = @MeasureSetID
				GROUP BY ME.EntityID;

				CREATE UNIQUE CLUSTERED INDEX IX_#EntityEnrollmentReqs ON #EntityEnrollmentReqs (EntityID);

				--STEP #2, Identify the product lines associated with each enrollment group...
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

				--STEP #3, Restrict the calculation to only entities that match any product line restrictions, if applicable...
				SELECT	PEN.* 
				INTO	#EntityEnrollment 
				FROM	Proxy.EntityEnrollment AS PEN
						--Below added for new feature to optionally restrict product lines for specified entities 
						LEFT OUTER JOIN #EnrollmentKey AS NK
								ON NK.BatchID = PEN.BatchID AND
									NK.EnrollGroupID = PEN.EnrollGroupID AND
									NK.ProductClassID = PEN.ProductClassID
						LEFT OUTER JOIN #EntityEnrollmentReqs AS ENR
								ON ENR.EntityID = PEN.EntityID
				WHERE	(
							(ENR.EntityID IS NULL) OR
							(NK.EnrollGroupID IS NULL) OR 
							(NK.BitProductLines & ENR.BitProductLines > 0)
						); 
			
				CREATE UNIQUE CLUSTERED INDEX IX_#EntityEnrollment ON #EntityEnrollment (EntityEnrollID ASC);

				DECLARE @ActualBeginGap smallint;
				DECLARE @ActualBeginGapDays smallint;
				DECLARE @ActualEndGap smallint;
				DECLARE @ActualEndGapDays smallint;
				DECLARE @BeginDate datetime;
				DECLARE @BenefitID smallint;
				DECLARE @EndDate datetime;
				DECLARE @EntityBaseID bigint;
				DECLARE @EntityEnrollSetID bigint;
				DECLARE @EntityEnrollSetLineID bigint;
				DECLARE @LastSegBeginDate datetime;
				DECLARE @LastSegEndDate datetime;
				DECLARE @MeasEnrollID int;
				DECLARE @ProductClassID tinyint;

				--Prep work to identify "Entity Enrollment Sets" (uses the "quirky" UPDATE method)
				UPDATE	TEN
				SET		@EntityEnrollSetID = EntityEnrollSetID = CASE 
																	WHEN @EntityBaseID IS NULL OR
																		@BenefitID <> BenefitID OR
																		@EntityBaseID <> EntityBaseID OR
																		@MeasEnrollID <> MeasEnrollID OR
																		@ProductClassID <> ProductClassID
																	THEN ISNULL(@EntityEnrollSetID, 0) + 1
																	ELSE @EntityEnrollSetID
																	END,
						@EntityEnrollSetLineID = EntityEnrollSetLineID = CASE 
																			WHEN @EntityBaseID IS NULL OR
																				@BenefitID <> BenefitID OR
																				@EntityBaseID <> EntityBaseID OR
																				@MeasEnrollID <> MeasEnrollID OR
																				@ProductClassID <> ProductClassID
																			THEN 1
																			ELSE ISNULL(@EntityEnrollSetLineID, 0) + 1
																			END,
						@BenefitID = BenefitID,
						@EntityBaseID = EntityBaseID,
						@MeasEnrollID = MeasEnrollID,
						@ProductClassID = ProductClassID
				FROM	#EntityEnrollment AS TEN WITH(TABLOCKX)
				OPTION	(MAXDOP 1);
						

				SELECT	EntityEnrollSetID, 
						MAX(EntityEnrollSetLineID) AS MaxEntityEnrollSetLineID,
						MIN(EntityEnrollSetLineID) AS MinEntityEnrollSetLineID
				INTO	#ActualRow
				FROM	#EntityEnrollment
				GROUP BY EntityEnrollSetID

				--Prep work to mark the first row of each "Entity Enrollment Set"
				UPDATE	TEN
				SET		ActualFirstRow = 1
				FROM	#EntityEnrollment AS TEN
						INNER JOIN #ActualRow AS t
								ON TEN.EntityEnrollSetID = t.EntityEnrollSetID AND
									TEN.EntityEnrollSetLineID = t.MinEntityEnrollSetLineID;

				--Prep work to mark the last row of each "Entity Enrollment Set"
				UPDATE	TEN
				SET		ActualLastRow = 1
				FROM	#EntityEnrollment AS TEN
						INNER JOIN #ActualRow AS t
								ON TEN.EntityEnrollSetID = t.EntityEnrollSetID AND
									TEN.EntityEnrollSetLineID = t.MaxEntityEnrollSetLineID;
						
				--Clear the variables
				SELECT	@BenefitID = NULL,
						@EntityBaseID = NULL,
						@MeasEnrollID = NULL,
						@ProductClassID = NULL

				--Calculate continuous enrollment (uses the "quirky" UPDATE method)
				UPDATE	TEN
				SET		@BeginDate = ActualBeginDate = CASE 
															WHEN @BeginDate IS NULL OR
																@BenefitID <> BenefitID OR
																@EntityBaseID <> EntityBaseID OR
																@MeasEnrollID <> MeasEnrollID OR
																@ProductClassID <> ProductClassID
															THEN BeginEnrollDate
															ELSE @EndDate
															END,
						@ActualBeginGapDays = ActualBeginGapDays =  CASE 
																		WHEN @BeginDate < EnrollSegBeginDate 
																		THEN 
																			CASE
																				WHEN ActualFirstRow = 0
																				THEN DATEDIFF(dd, @BeginDate, EnrollSegBeginDate) - 1
																					--Not enrolled on first row, so no minus 1--
																				ELSE DATEDIFF(dd, @BeginDate, EnrollSegBeginDate) 
																				END
																		ELSE 0 
																		END,

						@ActualBeginGap = ActualBeginGap = CASE 
																WHEN @ActualBeginGapDays > 0 
																THEN 1 
																ELSE 0 
																END,
						@ActualEndGapDays = ActualEndGapDays = CASE
																	WHEN ActualLastRow = 1 AND 
																		EnrollSegEndDate < EndEnrollDate 
																	THEN DATEDIFF(dd, EnrollSegEndDate, EndEnrollDate)
																	ELSE 0
																	END,
						@ActualEndGap = ActualEndGap = CASE
															WHEN @ActualEndGapDays > 0
															THEN 1
															ELSE 0
															END,
						ActualGapDays = @ActualBeginGapDays + @ActualEndGapDays,
						ActualGapMaxDays = CASE 
											WHEN @ActualBeginGapDays > @ActualEndGapDays 
											THEN @ActualBeginGapDays 
											ELSE @ActualEndGapDays 
											END,
						ActualGaps = @ActualBeginGap + @ActualEndGap,
						ActualEnrollGroupID = CASE 
													WHEN (ActualLastRow = 1 AND PayerDate IS NOT NULL) OR
														(PayerDate BETWEEN EnrollSegBeginDate AND EnrollSegEndDate )
													THEN EnrollGroupID 
													END,
						ActualHasAnchor = CASE
											WHEN AnchorDate BETWEEN EnrollSegBeginDate AND EnrollSegEndDate
											THEN 1
											ELSE 0
											END,
						ActualHasPayer = CASE
											--WHEN PayerDate BETWEEN BeginEnrollDate AND EndEnrollDate --Why!? 4/13/2016
											WHEN (ActualLastRow = 1 AND PayerDate BETWEEN BeginEnrollDate AND EndEnrollDate) OR
												(PayerDate BETWEEN EnrollSegBeginDate AND EnrollSegEndDate)
											THEN 1
											ELSE 0
											END,
						
						@EndDate = EnrollSegEndDate,
						@BenefitID = BenefitID,
						@EntityBaseID = EntityBaseID,
						
						@LastSegBeginDate = CASE
												WHEN ActualFirstRow = 1 OR @ActualBeginGap > 0
												THEN EnrollSegBeginDate
												ELSE @LastSegBeginDate
												END,
						@LastSegEndDate =	CASE 
												WHEN @ActualBeginGap > 0 OR ActualLastRow = 1
												THEN EnrollSegEndDate
												ELSE @LastSegEndDate
												END,						
						
						LastSegBeginDate = CASE WHEN ActualLastRow = 1 THEN @LastSegBeginDate END,
						LastSegEndDate = CASE WHEN ActualLastRow = 1 THEN @LastSegEndDate END,
						
						@MeasEnrollID = MeasEnrollID,
						@ProductClassID = ProductClassID
				FROM	#EntityEnrollment AS TEN WITH(TABLOCKX)
				OPTION	(MAXDOP 1);						
				
				--Apply ActualHasPayer flag to previous enrollment segment(s), ending at the same time as the payer/last segment AND with an ending gap...
				--(Added 4/14/2016 as part of covering for dual-eligibles via different enrollment groups on concurrent enrollment segments).
				--(Intended for just those measures with potential for ending gaps)
				CREATE UNIQUE NONCLUSTERED INDEX IX_#EntityEnrollment2 ON #EntityEnrollment (EntityEnrollSetID, EntityEnrollSetLineID) 
					INCLUDE (ActualEndGap, ActualHasPayer, EnrollSegEndDate);

				UPDATE	EN1
				SET		EN1.ActualHasPayer = 1
				FROM	#EntityEnrollment AS EN1 WITH(INDEX(IX_#EntityEnrollment2))
						INNER JOIN #EntityEnrollment AS EN2 WITH(INDEX(IX_#EntityEnrollment2))
								ON EN2.EntityEnrollSetID = EN1.EntityEnrollSetID AND
									EN2.EnrollSegEndDate = EN1.EnrollSegEndDate AND
									EN2.EntityEnrollSetLineID > EN1.EntityEnrollSetLineID
				WHERE	EN2.ActualEndGap > 0 AND
						EN2.ActualHasPayer = 1 AND
						EN1.ActualHasPayer = 0;

				DROP INDEX IX_#EntityEnrollment2 ON #EntityEnrollment;

				--Apply calculation data to the real table...
				UPDATE	PEN
				SET		
						--From the first UPDATE...
						EntityEnrollSetID = TEN.EntityEnrollSetID,
						EntityEnrollSetLineID = TEN.EntityEnrollSetLineID,
						
						--From the second UPDATE...
						ActualFirstRow = TEN.ActualFirstRow,
						ActualLastRow = TEN.ActualLastRow,
						
						--From the third UPDATE...
						ActualBeginDate = TEN.ActualBeginDate,
						ActualBeginGapDays = TEN.ActualBeginGapDays,
						ActualBeginGap = TEN.ActualBeginGap,
						ActualEndGapDays = TEN.ActualEndGapDays,
						ActualEndGap = TEN.ActualEndGap,
						ActualGapDays = TEN.ActualGapDays,
						ActualGapMaxDays = TEN.ActualGapMaxDays,
						ActualGaps = TEN.ActualGaps,
						ActualEnrollGroupID = TEN.ActualEnrollGroupID,
						ActualHasAnchor = TEN.ActualHasAnchor,
						ActualHasPayer = TEN.ActualHasPayer,
						
						LastSegBeginDate = TEN.LastSegBeginDate,
						LastSegEndDate = TEN.LastSegEndDate
						
				FROM	Proxy.EntityEnrollment AS PEN
						INNER JOIN #EntityEnrollment AS TEN
								ON PEN.EntityEnrollID = TEN.EntityEnrollID;
								
				SET @CountRecords = ISNULL(@CountRecords, 0) + @@ROWCOUNT;
			END;
		
		RETURN 0;
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
GRANT EXECUTE ON  [Batch].[CalculateEntityEnrollment] TO [Processor]
GO
