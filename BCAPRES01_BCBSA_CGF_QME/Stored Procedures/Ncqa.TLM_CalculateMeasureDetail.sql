SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 2/2/2017
-- Description:	Calculates the detailed results of the TLM measure, as required HEDIS 2017+.
-- =============================================
CREATE PROCEDURE [Ncqa].[TLM_CalculateMeasureDetail]
(
	@BatchID int = NULL,
	@CountRecords bigint = NULL OUTPUT
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
		
		SET @LogBeginTime = GETDATE();
		SET @LogObjectName = 'TLM_CalculateMeasureDetail'; 
		SET @LogObjectSchema = 'Ncqa'; 
		
		--Added to determine @LogEntryXrefGuid value---------------------------
		SELECT @LogEntryXrefGuid = [Log].GetEntryXrefGuid (@LogObjectSchema, @LogObjectName);
		-----------------------------------------------------------------------
				
		BEGIN TRY;
			--1) Create a key of the measure/metric associated with TLM...
			SELECT TOP 1
					MM.MeasureID, 
					MM.MeasureXrefID,
					MX.MetricID,
					MX.MetricXrefID
			INTO	#MetricKey
			FROM	Measure.Metrics AS MX
					INNER JOIN Measure.Measures AS MM
							ON MM.MeasureID = MX.MeasureID
			WHERE	(MX.Abbrev = 'TLM') AND 
					(MM.MeasureSetID = @MeasureSetID);


			--2) Create a product line priority conversion key as specified in the TLM specification, under the "Calculation" section...
			WITH ProductLineConversionBase(FromAbbrev, ToAbbrev, BasePriority) AS
			(
				SELECT	'C', 'C', 2
				UNION
				SELECT	'D', 'D', 10
				UNION
				SELECT	'R', 'R', 1
				UNION
				SELECT	'S', 'R', 1
				UNION
				SELECT	'H', 'D', 10
				UNION
				SELECT	'M', 'M', 3
				UNION
				SELECT	'Q', 'R', 1
			)
			SELECT	t.BasePriority,
					PPLF.BitValue AS FromBitProductLine,
					PPLT.ProductLineID,
					PPLT.BitValue AS ToBitProductLine
			INTO	#ProductLineConversion
			FROM	ProductLineConversionBase AS t
					INNER JOIN Product.ProductLines AS PPLF
							ON PPLF.Abbrev = t.FromAbbrev
					INNER JOIN Product.ProductLines AS PPLT
							ON PPLT.Abbrev = t.ToAbbrev;

			CREATE UNIQUE CLUSTERED INDEX IX_#ProductLineConversion ON #ProductLineConversion (FromBitProductLine);
		

			--3) Identify members enrolled as of 12/31 (@EndInitSeedDate) and prioritize under which segment/LOB the member will be reported...
			WITH PopulationProductLines AS
			(
				SELECT	SUM(DISTINCT PPL.BitValue) AS BitProductLines,
						MNPPL.PopulationID
				FROM	Member.EnrollmentPopulationProductLines AS MNPPL
						INNER JOIN Product.ProductLines AS PPL
								ON PPL.ProductLineID = MNPPL.ProductLineID
				GROUP BY MNPPL.PopulationID
			)
			SELECT	PLC.BasePriority,
					MN.BeginDate,
                    PLC.BitProductLines,
					MN.BitProductLines AS PayerBitProductLines,
					t.BitProductLines AS PopulationBitProductLines,
					MM.CustomerMemberID,
                    MN.DataSetID,
					MN.DataSourceID,
					MM.DOB,
                    MN.DSMemberID,
                    MN.EndDate,
                    MN.EnrollGroupID,
                    MN.EnrollItemID,
					MM.Gender,
					IDENTITY(bigint, 1, 1) AS ID,
					MM.IhdsMemberID,
					MNG.PayerID,
					PP.ProductTypeID,
					MNG.PopulationID,
                    MN.[Priority],
					PLC.ProductLineID,
					ROW_NUMBER() OVER (PARTITION BY MN.DSMemberID ORDER BY MN.[Priority], PLC.BasePriority, MN.BitProductLines, MNG.PopulationID, MN.EnrollGroupID) AS TLM_Priority
			INTO	#Membership
			FROM	Member.Members AS MM
					INNER JOIN Member.Enrollment AS MN
							ON MN.DataSetID = MM.DataSetID AND
								MN.DSMemberID = MM.DSMemberID
					INNER JOIN Member.EnrollmentGroups AS MNG
							ON MNG.EnrollGroupID = MN.EnrollGroupID
					INNER JOIN Product.Payers AS PP
							ON PP.PayerID = MNG.PayerID
					INNER JOIN PopulationProductLines AS t
							ON t.PopulationID = MNG.PopulationID
					CROSS APPLY (
									SELECT TOP 1
											tPLC.BasePriority,
											/*(MN.BitProductLines & t.BitProductLines) ^ tPLC.FromBitProductLine | */tPLC.ToBitProductLine AS BitProductLines,
											tPLC.ProductLineID
									FROM	#ProductLineConversion AS tPLC
									WHERE	tPLC.FromBitProductLine & (MN.BitProductLines & t.BitProductLines) > 0
									ORDER BY tPLC.BasePriority, tPLC.ToBitProductLine
								) AS PLC
			WHERE	MN.DataSetID = @DataSetID AND
					(
						@EndInitSeedDate BETWEEN MN.BeginDate AND MN.EndDate OR
						MN.BeginDate < @EndInitSeedDate AND MN.EndDate IS NULL
					)
			ORDER BY DSMemberID, [Priority], BasePriority, MN.BitProductLines, MNG.PopulationID, MN.EnrollGroupID;

			/*SELECT * FROM #Membership ORDER BY ID;
			SELECT * FROM #Membership WHERE TLM_Priority = 1 ORDER BY ID;

			WITH NcqaPayerKeyBase AS
			(
				SELECT	'C' AS ProductLine, 'HMO' AS ProductType, 'HMO' AS Payer
				UNION
				SELECT	'C' AS ProductLine, 'POS' AS ProductType, 'POS' AS Payer
				UNION
				SELECT	'C' AS ProductLine, 'PPO' AS ProductType, 'PPO' AS Payer
				UNION
				SELECT	'C' AS ProductLine, 'EPO' AS ProductType, 'CEP' AS Payer
				UNION
				SELECT	'R' AS ProductLine, 'HMO' AS ProductType, 'MCR' AS Payer
				UNION
				SELECT	'R' AS ProductLine, 'POS' AS ProductType, 'MCS' AS Payer
				UNION
				SELECT	'R' AS ProductLine, 'PPO' AS ProductType, 'MP' AS Payer
				UNION
				SELECT	'D' AS ProductLine, 'HMO' AS ProductType, 'MCD' AS Payer
				UNION
				SELECT	'M' AS ProductLine, 'EPO' AS ProductType, 'MEP' AS Payer
				UNION
				SELECT	'M' AS ProductLine, 'HMO' AS ProductType, 'MMO' AS Payer
				UNION
				SELECT	'M' AS ProductLine, 'POS' AS ProductType, 'MOS' AS Payer
				UNION
				SELECT	'M' AS ProductLine, 'PPO' AS ProductType, 'MPO' AS Payer
				UNION
				SELECT	'C' AS ProductLine, 'FFS' AS ProductType, 'COF' AS Payer
				UNION
				SELECT	'R' AS ProductLine, 'FFS' AS ProductType, 'MRF' AS Payer
				UNION
				SELECT	'D' AS ProductLine, 'FFS' AS ProductType, 'MCF' AS Payer
			),
			NcqaPayerKey AS
			(
				SELECT	PPL.BitValue AS BitProductLines,
						t.Payer,
						PPT.ProductTypeID
				FROM	NcqaPayerKeyBase AS t
						INNER JOIN Product.ProductLines AS PPL
								ON PPL.Abbrev = t.ProductLine
						INNER JOIN Product.ProductTypes AS PPT
								ON PPT.Abbrev = t.ProductType
			)
			SELECT	COUNT(DISTINCT t.DSMemberID) AS CountRecords,
					K.Payer
			FROM	#Membership AS t
					INNER JOIN NcqaPayerKey AS K
							ON K.BitProductLines = t.BitProductLines AND
								K.ProductTypeID = t.ProductTypeID
			WHERE	(TLM_Priority = 1)
			GROUP BY K.Payer
			ORDER BY Payer;*/

			--4a) Delete any existing results...
			DELETE	RMD
			FROM	Result.MeasureDetail AS RMD
					INNER JOIN #MetricKey AS t
							ON t.MeasureID = RMD.MeasureID AND
								t.MetricID = RMD.MetricID
			WHERE	RMD.BatchID = @BatchID AND 
					RMD.DataRunID = @DataRunID AND 
					RMD.DataSetID = @DataSetID;
			
			--4b) Insert new TLM records, but only the records with the highest priority per member (TLM_Priority) to ensure "unduplicated membership"...
			INSERT INTO Result.MeasureDetail
					(Age,
					AgeMonths,
					BatchID,
					BeginDate,
					BitProductLines,
					DataRunID,
					DataSetID,
					DataSourceID,
					DSMemberID,
					EndDate,
					EnrollGroupID,
					Gender,
					IsDenominator,
					IsExclusion,
					IsHospice,
					IsIndicator,
					IsNumerator,
					IsNumeratorAdmin,
					IsNumeratorMedRcd,
					IsSupplementalDenominator,
					IsSupplementalExclusion,
					IsSupplementalIndicator,
					IsSupplementalNumerator,
					KeyDate,
					MeasureID,
					MeasureXrefID,
					MetricID,
					MetricXrefID,
					PayerID,
					PopulationID,
					ProductLineID,
					Qty,
					ResultRowGuid,
					ResultTypeID)		
			SELECT	Member.GetAgeAsOf(M.DOB, @EndInitSeedDate) AS Age,
					Member.GetAgeInMonths(M.DOB, @EndInitSeedDate) AS AgeMonths,
					@BatchID AS BatchID,
					@BeginInitSeedDate AS BeginDate,
					M.BitProductLines,
					@DataRunID AS DataRunID,
					@DataSetID AS DataSetID,
					M.DataSourceID,
					M.DSMemberID,
					@EndInitSeedDate AS EndDate,
					M.EnrollGroupID,
					M.Gender,
					1 AS IsDenominator,
					0 AS IsExclusion,
					0 AS IsHospice,
					0 AS IsIndicator,
					0 AS IsNumerator,
					0 AS IsNumeratorAdmin,
					0 AS IsNumeratorMedRcd,
					0 AS IsSupplementalDenominator,
					0 AS IsSupplementalExclusion,
					0 AS IsSupplementalIndicator,
					0 AS IsSupplementalNumerator,
					@EndInitSeedDate AS KeyDate,
					K.MeasureID,
					K.MeasureXrefID,
					K.MetricID,
					K.MetricXrefID,
					M.PayerID,
					M.PopulationID,
					M.ProductLineID,
					1 AS Qty,
					NEWID() AS ResultRowGuid,
					1 AS ResultTypeID
			FROM	#Membership AS M
					CROSS JOIN #MetricKey AS K
			WHERE	(M.TLM_Priority = 1)
			ORDER BY M.ID;

			SET @CountRecords = ISNULL(@CountRecords, 0) + @@ROWCOUNT;
			
			SET @LogDescr = ' - Calculating TLM measure results for BATCH ' + CAST(@BatchID AS varchar(32)) + ' succeeded.'; 
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


			--RETURN 0;
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
			SET @LogDescr = ' - Calculating TLM measure results for BATCH ' + CAST(@BatchID AS varchar(32)) + ' failed!'; 
			
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
			
		--RETURN @ErrNumber;
	END CATCH;
END
GO
