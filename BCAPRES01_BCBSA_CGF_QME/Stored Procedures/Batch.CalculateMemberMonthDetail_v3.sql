SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 11/19/2013
-- Description:	Calculates the detailed member month results. (v3)
-- =============================================
CREATE PROCEDURE [Batch].[CalculateMemberMonthDetail_v3]
(
	@ApplyHospiceProductLineFilter bit = 0,
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
	DECLARE @CalculateMbrMonths bit;
	DECLARE @DataRunID int;
	DECLARE @DataSetID int;
	DECLARE @EndInitSeedDate datetime;
	DECLARE @IsLogged bit;
	DECLARE @MeasureSetID int;
	DECLARE @MbrMonthID int;
	DECLARE @OwnerID int;
	DECLARE @SeedDate datetime;
	
	BEGIN TRY;
		
		SET @LogBeginTime = GETDATE();
		SET @LogObjectName = 'CalculateMemberMonthDetail'; 
		SET @LogObjectSchema = 'Batch'; 
		
		--Added to determine @LogEntryXrefGuid value---------------------------
		SELECT @LogEntryXrefGuid = [Log].GetEntryXrefGuid (@LogObjectSchema, @LogObjectName);
		-----------------------------------------------------------------------
				
		BEGIN TRY;
				
			IF @BatchID IS NULL
				RAISERROR(' - Calculating detailed member month results for the batch failed!  No batch was specified.', 16, 1);
				
			DECLARE @CountRecords int;
			
			SELECT	@BeginInitSeedDate = DR.BeginInitSeedDate,
					@CalculateMbrMonths = DR.CalculateMbrMonths,
					@DataRunID = DR.DataRunID,
					@DataSetID = DS.DataSetID,
					@EndInitSeedDate = DR.EndInitSeedDate,
					@IsLogged = DR.IsLogged,
					@MeasureSetID = DR.MeasureSetID,
					@MbrMonthID = DR.MbrMonthID,
					@OwnerID = DS.OwnerID,
					@SeedDate = DR.SeedDate
			FROM	Batch.[Batches] AS B 
					INNER JOIN Batch.DataRuns AS DR
							ON B.DataRunID = DR.DataRunID
					INNER JOIN Batch.DataSets AS DS 
							ON B.DataSetID = DS.DataSetID 
			WHERE	(B.BatchID = @BatchID);
			
			
			IF ISNULL(@CalculateMbrMonths, 1) = 1
				BEGIN
					--Create a valid enrollment key for calculating member months...
					SELECT	SUM(DISTINCT PPL.BitValue) AS BitProductLines,
							PEK.EnrollGroupID, 
							PEK.PayerID, 
							PEK.PopulationID 
					INTO	#Payers
					FROM	Product.PayerProductLines AS PPPL
							INNER JOIN Product.ProductLines AS PPL
									ON PPPL.ProductLineID = PPL.ProductLineID
							INNER JOIN Member.EnrollmentPopulationProductLines AS MNPPL
									ON PPPL.ProductLineID = MNPPL.ProductLineID
							INNER JOIN Member.EnrollmentPopulations AS MNP
									ON MNPPL.PopulationID = MNP.PopulationID AND
										MNP.OwnerID = @OwnerID
							INNER JOIN Proxy.EnrollmentKey AS PEK
									ON PPPL.PayerID = PEK.PayerID AND
										MNP.PopulationID = PEK.PopulationID AND
										MNPPL.PopulationID = PEK.PopulationID 
					GROUP BY PEK.EnrollGroupID, PEK.PayerID, PEK.PopulationID;

					CREATE UNIQUE CLUSTERED INDEX IX_#Payers ON #Payers (EnrollGroupID);

					--Create a key of the dates to check for member months...
					SELECT	DATEADD(dd, CAST(MMMD.[Day] AS int) - 1, DATEADD(mm, CAST(MMMD.[Month] AS int) - 1, DATEADD(yy, DATEDIFF(yy, 0, @EndInitSeedDate), 0))) AS EvalDate,
							MbrMonthDefID,
							[Month]
					INTO	#MemberMonthDates
					FROM	Measure.MemberMonthDefinitions AS MMMD
					WHERE	MbrMonthID = @MbrMonthID

					CREATE UNIQUE CLUSTERED INDEX IX_#MemberMonthDates ON #MemberMonthDates (EvalDate);

					DECLARE @BitHospice bigint;
					SELECT @BitHospice = BitValue FROM Product.Benefits WHERE Abbrev = 'Hosp';

					--Create a temp table containing the preliminary member month data...
					SELECT	/*Member.GetAgeAsOf(M.DOB, t.EvalDate) AS Age,
							Member.GetAgeInMonths(M.DOB, t.EvalDate) AS AgeMonths, */
							
							/*** COPIED FROM Member.GetAgeAsOf TO INCREASE PERFORMANCE BY 30+% **********************************************/
							MAX(CAST(DATEDIFF(year, M.DOB, t.EvalDate) - 
								CASE 
									WHEN (MONTH(M.DOB) > MONTH(t.EvalDate)) OR ((DAY(M.DOB) > DAY(t.EvalDate)) AND (MONTH(M.DOB) = MONTH(t.EvalDate)))
									THEN 1 
									ELSE 0 END AS smallint)) AS Age,
							
							/*** COPIED FROM Member.GetAgeInMonths TO INCREASE PERFORMANCE BY 30+% **********************************************/		
							MAX(CAST(DATEDIFF(month, M.DOB, t.EvalDate) - 
								CASE WHEN ((DAY(M.DOB) > DAY(t.EvalDate)) AND (MONTH(M.DOB) = MONTH(t.EvalDate)))
									THEN 1 
									ELSE 0 END AS smallint)) AS AgeMonths,
							dbo.BitwiseOr(MN.BitBenefits) AS BitBenefits,
							MN.DSMemberID, 
							t.EvalDate,
							MN.EnrollGroupID, 
							M.Gender, 
							IDENTITY(bigint, 1, 1) AS ID,
							t.MbrMonthDefID, 
							t.[Month]
					INTO	#Months
					FROM	Proxy.Enrollment AS MN
							INNER JOIN Proxy.Members AS M
									ON MN.DSMemberID = M.DSMemberID
							INNER JOIN #MemberMonthDates AS t
									ON t.EvalDate BETWEEN MN.BeginDate AND MN.EndDate
					GROUP BY MN.DSMemberID, 
							t.EvalDate,
							MN.EnrollGroupID, 
							M.Gender, 
							t.MbrMonthDefID, 
							t.[Month];
									
					CREATE UNIQUE CLUSTERED INDEX IX_#Months ON #Months (ID);
					CREATE NONCLUSTERED INDEX IX_#Months_EnrollGroupID ON #Months (EnrollGroupID);
							
					--Purge existing member month data, if any, and copy new data to final table...
					DELETE FROM Result.MemberMonthDetail WHERE DataRunID = @DataRunID AND BatchID = @BatchID;
					
					--Convert each single benefit into its full set of bit-wise values, based on benefit relationships (parents and children)
					-------------------------------------------------------------------------------------------------------------------------
					SELECT DISTINCT
							PB.BitValue, PB.BitValue AS ChildValue
					INTO	#ProductBenefitsBitWised
					FROM	Product.Benefits AS PB
					WHERE	(1 = 2) --Added Always-False WHERE Statement to reduce rows in next step's aggregation
					UNION
					SELECT DISTINCT
							PB1.BitValue, PB2.BitValue AS ChildValue
					FROM	Product.BenefitRelationships AS PBR
							INNER JOIN Product.Benefits AS PB1
									ON PBR.BenefitID = PB1.BenefitID
							INNER JOIN Product.Benefits AS PB2
									ON PBR.ChildID = PB2.BenefitID;
					
					CREATE UNIQUE CLUSTERED INDEX IX_#ProductBenefitsBitWised ON #ProductBenefitsBitWised (BitValue, ChildValue);
					
					SELECT	dbo.BitwiseOr(t.BitValue) AS BitBenefits,
							ID
					INTO	#BenefitsWithParents
					FROM	#Months AS M
							INNER JOIN #ProductBenefitsBitWised AS t
									ON M.BitBenefits & t.ChildValue > 0
					GROUP BY ID;
									
					CREATE UNIQUE CLUSTERED INDEX IX_#BenefitsWithParents ON #BenefitsWithParents (ID);
					
					UPDATE	M
					SET		BitBenefits = M.BitBenefits | BWP.BitBenefits
					FROM	#Months AS M
							INNER JOIN #BenefitsWithParents AS BWP
									ON M.ID = BWP.ID;
										
					-------------------------------------------------------------------------------------------------------------------------
					
					IF NOT EXISTS(SELECT TOP 1 1 FROM Result.MemberMonthDetail)
						TRUNCATE TABLE Result.MemberMonthDetail;
							
					DECLARE @BitMedicare bigint;
					SELECT @BitMedicare = BitValue FROM Product.ProductLines WHERE Abbrev = 'R';

					INSERT INTO Result.MemberMonthDetail
							(Age, AgeMonths, BatchID, 
							BitBenefits, BitProductLines,
							CountMonths, DataRunID, DataSetID,
							DSMemberID, EnrollGroupID, Gender,
							PayerID, PopulationID)
					SELECT	t.Age, 
							MAX(t.AgeMonths) AS AgeMonths,
							@BatchID AS BatchID, 
							t.BitBenefits,
							CASE WHEN @BitHospice & t.BitBenefits > 0 AND @ApplyHospiceProductLineFilter = 1 THEN P.BitProductLines ^ @BitMedicare ELSE P.BitProductLines END AS BitProductLines,
							COUNT(DISTINCT t.MbrMonthDefID) AS CountMonths,
							@DataRunID AS DataRunID, 
							@DataSetID AS DataSetID,
							t.DSMemberID, 
							t.EnrollGroupID, 
							t.Gender, 
							P.PayerID, 
							P.PopulationID
					FROM	#Months AS t
							INNER JOIN #Payers AS P
									ON t.EnrollGroupID = P.EnrollGroupID
					WHERE	Age BETWEEN 0 AND 255 AND
							(
								(t.BitBenefits & @BitHospice = 0) OR
								(P.BitProductLines ^ @BitMedicare > 0)
							)
					GROUP BY t.Age,
							t.BitBenefits,
							P.BitProductLines,
							t.DSMemberID, 
							t.EnrollGroupID, 
							t.Gender, 
							P.PayerID, 
							P.PopulationID;

					SET @CountRecords = ISNULL(@CountRecords, 0) + @@ROWCOUNT;
					
					SET @LogDescr = ' - Calculating detailed member month results for BATCH ' + ISNULL(CAST(@BatchID AS varchar), '?') + ' succeeded.'; 
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
				END;

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
			SET @LogDescr = ' - Calculating detailed member month results for BATCH ' + ISNULL(CAST(@BatchID AS varchar), '?') + ' failed!'; --{FAILURE LOG DESCRIPTION HERE}
			
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
GRANT EXECUTE ON  [Batch].[CalculateMemberMonthDetail_v3] TO [Processor]
GO
