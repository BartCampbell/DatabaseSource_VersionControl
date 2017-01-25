SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 8/30/2011
-- Description:	Creates a new data run on the specified data set.
-- =============================================
CREATE PROCEDURE [Batch].[CreateDataRun]
(
	@BatchSize int = NULL,
	@BeginInitSeedDate datetime = NULL OUTPUT,
	@CalculateMbrMonths bit = 1,
	@CalculateXml bit = 1,
	@DataRunGuid uniqueidentifier = NULL OUTPUT,
	@DataRunID int = NULL OUTPUT,
	@DataSetID int,
	@DefaultBenefitID smallint = 1,
	@EndInitSeedDate datetime = NULL OUTPUT,
	@FileFormatID int = NULL,
	@HasSystematicSamples bit = 1 OUTPUT,
	@IsLogged bit = 1,
	@MeasureSetID int,
	@MbrMonthID smallint = 1,
	@ReturnFileFormatID int = NULL,
	@SeedDate datetime = NULL OUTPUT,
	@SourceGuid uniqueidentifier = NULL
)
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY;
		IF @DataSetID IS NOT NULL AND 
			EXISTS (SELECT 1 FROM Batch.DataSets WHERE DataSetID = @DataSetID) AND 
			@MeasureSetID IS NOT NULL AND
			EXISTS (SELECT 1 FROM Measure.MeasureSets WHERE MeasureSetID = @MeasureSetID)
			
			BEGIN;
				DECLARE @OwnerID int;
				SELECT @OwnerID = OwnerID FROM Batch.DataSets WHERE DataSetID = @DataSetID;
			
				IF @SeedDate IS NULL
					SELECT @SeedDate = DefaultSeedDate FROM Measure.MeasureSets WHERE MeasureSetID = @MeasureSetID
				
				IF @BeginInitSeedDate IS NULL
					SET @BeginInitSeedDate = DATEADD(dd, 1, DATEADD(yy, -1, @SeedDate))
					
				IF @EndInitSeedDate IS NULL
					SET @EndInitSeedDate = @SeedDate
					
				IF @DataRunGuid IS NULL
					SET @DataRunGuid = NEWID();
				
				BEGIN TRANSACTION TDataRun;
				
				INSERT INTO Batch.DataRuns 
						([BatchSize], 
						BeginInitSeedDate,
						BeginTime, 
						CalculateMbrMonths,
						CalculateXml,
						DataRunGuid, 
						DataSetID, 
						DefaultBenefitID,
						EndInitSeedDate,
						FileFormatID,
						IsLogged,
						MbrMonthID,
						MeasureSetID,
						ReturnFileFormatID,
						SeedDate,
						SourceGuid)
				VALUES
						(@BatchSize,
						@BeginInitSeedDate,
						GETDATE(), 
						@CalculateMbrMonths,
						ISNULL(@CalculateXml, 0),
						@DataRunGuid, 
						@DataSetID, 
						@DefaultBenefitID,
						@EndInitSeedDate,
						@FileFormatID,
						@IsLogged,
						@MbrMonthID,
						@MeasureSetID,
						@ReturnFileFormatID,
						@SeedDate,
						ISNULL(@SourceGuid, @DataRunGuid));
						
				SET @DataRunID = SCOPE_IDENTITY();
				
				--If the engine is not a processor, create the editable instructions for generating systematic samples for medical record review...
				--(EngineTypeGuid 2B2E7F78-7F8F-4ED2-8B89-C79EB53F3E3A is a processor.  Processors have no benefit from this step.)
				IF NOT EXISTS	(
									SELECT TOP 
											1 1 
									FROM	Engine.Settings AS ES WITH(NOLOCK)
											INNER JOIN Engine.[Types] AS ET WITH(NOLOCK)
													ON ES.EngineTypeID = ET.EngineTypeID 
									WHERE	(ET.EngineTypeGuid = '2B2E7F78-7F8F-4ED2-8B89-C79EB53F3E3A')
								)
					BEGIN;
						DECLARE @ForceAllIndividualPayers bit;
						SET @ForceAllIndividualPayers = 0;

						--Sets flag indicating whether or not to include the payer group by on all records.  New to HEDIS 2016+.  Related to removal of product class filtering for enrollment gaps.  
						SELECT	@ForceAllIndividualPayers = ISNULL(CONVERT(bit, MAX(CONVERT(tinyint, MEN.IgnoreClass))), 0)
						FROM	Measure.Entities AS ME
								INNER JOIN Measure.EntityEnrollment AS MEN
										ON MEN.EntityID = ME.EntityID
						WHERE	(ME.IsEnabled = 1) AND
								(MEN.IsEnabled = 1) AND
								(ME.MeasureSetID = @MeasureSetID);

						INSERT INTO Batch.SystematicSamples
								(BitProductLines,
								DataRunID,
								IsSysSampleAscending,
								MeasureID,
								PayerID,
								PopulationID,
								ProductClassID,
								ProductLineID,
								SysSampleRand,
								SysSampleRate,
								SysSampleSize)
						SELECT DISTINCT
								PPL.BitValue AS BitProductLines,                  
								@DataRunID AS DataRunID,
								MMS.IsSysSampleAscending,
								MM.MeasureID,
								CASE WHEN (PP.ProductLineID = 4 AND PPPL.ProductLineID = 4) OR (@ForceAllIndividualPayers = 1) THEN PP.PayerID END AS PayerID, --NCQA reports SNP Payers separately during certification
								MNP.PopulationID,
								PPT.ProductClassID,
								PPPL.ProductLineID,
								MM.SysSampleRand,
								MM.SysSampleRate,
								MM.SysSampleSize
						FROM	Member.EnrollmentPopulations AS MNP
								INNER JOIN Member.EnrollmentGroups AS MNG
										ON MNP.PopulationID = MNG.PopulationID
								INNER JOIN Member.EnrollmentPopulationProductLines AS MNPPL
										ON MNP.PopulationID = MNPPL.PopulationID
								INNER JOIN Product.Payers AS PP
										ON MNG.PayerID = PP.PayerID 
								INNER JOIN Product.ProductTypes AS PPT
										ON PP.ProductTypeID = PPT.ProductTypeID	
								INNER JOIN Product.PayerProductLines AS PPPL
										ON MNPPL.ProductLineID = PPPL.ProductLineID AND
											PP.PayerID = PPPL.PayerID 
								INNER JOIN Product.ProductLines AS PPL
										ON PPPL.ProductLineID = PPL.ProductLineID
								INNER JOIN Measure.MeasureProductLines AS MMPL
										ON PPPL.ProductLineID = MMPL.ProductLineID AND
											MNPPL.ProductLineID = MMPL.ProductLineID
								INNER JOIN Measure.Measures AS MM
										ON MMPL.MeasureID = MM.MeasureID AND
											MM.IsEnabled = 1 AND
											MM.IsHybrid = 1
								INNER JOIN Measure.MeasureSets AS MMS
										ON MM.MeasureSetID = MMS.MeasureSetID
						WHERE	((MNP.DataSetID IS NULL) OR (MNP.DataSetID = @DataSetID)) AND
								(MM.MeasureSetID = @MeasureSetID) AND
								(MMS.MeasureSetID = @MeasureSetID) AND
								(MNP.OwnerID = @OwnerID)
						ORDER BY PopulationID, ProductLineID, ProductClassID, MeasureID;
					END;

				COMMIT TRANSACTION TDataRun;
				
				RETURN 0;
			END;
		ELSE
			RAISERROR('Unable to create data run.  The specified parameters are invalid.', 16, 1);
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
END;

GO
GRANT EXECUTE ON  [Batch].[CreateDataRun] TO [Processor]
GO
