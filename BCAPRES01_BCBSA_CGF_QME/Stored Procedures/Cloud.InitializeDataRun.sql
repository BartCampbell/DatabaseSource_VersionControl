SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 9/12/2012
-- Description:	Initializes a data set/run and its batches, returning the batch information when finished.
-- =============================================
CREATE PROCEDURE [Cloud].[InitializeDataRun]
(
	@BatchSize int = 1000,
	@BeginInitSeedDate datetime,
	@CalculateMbrMonths bit = 1,
	@CalculateXml bit = NULL,
	@DataRunGuid uniqueidentifier = NULL OUTPUT,
	@DataRunID int = NULL OUTPUT,
	@DataSetGuid uniqueidentifier = NULL OUTPUT,
	@DataSetID int = NULL OUTPUT,
	@DefaultBenefitGuid uniqueidentifier = NULL,
	@DefaultBenefitID smallint = NULL,
	@DefaultIhdsProviderId int = NULL,					--DEFAULT: Automatically selects a default provider
	@EndInitSeedDate datetime,
	@FileFormatGuid uniqueidentifier = NULL,
	@FileFormatID int = NULL,
	@HedisMeasureID varchar(10) = NULL,					--DEFAULT: No filtering for test decks (only use for NCQA Certification)
	@MbrMonthGuid uniqueidentifier = NULL,
	@MbrMonthID int = NULL,
	@MeasureSetGuid uniqueidentifier = NULL,
	@MeasureSetID int = NULL,
	@OwnerGuid uniqueidentifier = NULL,
	@OwnerID int = NULL,
	@ReturnFileFormatGuid uniqueidentifier = NULL,
	@ReturnFileFormatID int = NULL,
	@RollingMonths tinyint = 0,
	@RollingMonthsInterval tinyint = 1,
	@SetToReady bit = 1,
	@TargetDatabase nvarchar(128) = NULL,				--DEFAULT: Leave "target" database as is
	@Top int = 0										--DEFAULT: Return no sample rows
)
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @MeasureID int;
	
	BEGIN TRY;
		
		--i) Validate the file format...
		IF @FileFormatGuid IS NULL AND @FileFormatID IS NULL
			RAISERROR('The file format was not specified.', 16, 1);
		
		SELECT TOP 1
				@FileFormatGuid = FileFormatGuid,
				@FileFormatID = FileFormatID
		FROM	Cloud.FileFormats
		WHERE	((@FileFormatGuid IS NULL) OR (FileFormatGuid = @FileFormatGuid)) AND
				((@FileFormatID IS NULL) OR (FileFormatID = @FileFormatID));

		IF @FileFormatGuid IS NULL OR @FileFormatID IS NULL
			RAISERROR('The specified file format is invalid.', 16, 1);
		
		--ii) Validate the owner...
		IF @OwnerGuid IS NULL AND @OwnerID IS NULL
			RAISERROR('The owner was not specified.', 16, 1);
		
		SELECT TOP 1
				@OwnerGuid = OwnerGuid,
				@OwnerID = OwnerID
		FROM	Batch.DataOwners
		WHERE	((@OwnerGuid IS NULL) OR (OwnerGuid = @OwnerGuid)) AND
				((@OwnerID IS NULL) OR (OwnerID = @OwnerID));

		IF @OwnerGuid IS NULL OR @OwnerID IS NULL
			RAISERROR('The specified owner is invalid.', 16, 1);

		--iii) Validate the measure set...
		IF @MeasureSetGuid IS NULL AND @MeasureSetID IS NULL
			RAISERROR('The measure set was not specified.', 16, 1);
		
		SELECT TOP 1
				@MeasureSetGuid = MeasureSetGuid,
				@MeasureSetID = MeasureSetID
		FROM	Measure.MeasureSets
		WHERE	((@MeasureSetGuid IS NULL) OR (MeasureSetGuid = @MeasureSetGuid)) AND
				((@MeasureSetID IS NULL) OR (MeasureSetID = @MeasureSetID));

		IF @MeasureSetGuid IS NULL OR @MeasureSetID IS NULL
			RAISERROR('The specified measure set is invalid.', 16, 1);

		--iv) Validate the return file format...
		IF @ReturnFileFormatGuid IS NULL AND @ReturnFileFormatID IS NULL
			RAISERROR('The return file format was not specified.', 16, 1);
		
		SELECT TOP 1
				@CalculateXml = ISNULL(@CalculateXml, CalculateXml),
				@ReturnFileFormatGuid = FileFormatGuid,
				@ReturnFileFormatID = FileFormatID
		FROM	Cloud.FileFormats
		WHERE	((@ReturnFileFormatGuid IS NULL) OR (FileFormatGuid = @ReturnFileFormatGuid)) AND
				((@ReturnFileFormatID IS NULL) OR (FileFormatID = @ReturnFileFormatID));

		IF @ReturnFileFormatGuid IS NULL OR @ReturnFileFormatID IS NULL
			RAISERROR('The specified return file format is invalid.', 16, 1);

		IF @DefaultBenefitGuid IS NOT NULL OR @DefaultBenefitID IS NOT NULL
			SELECT TOP 1
					@DefaultBenefitGuid = BenefitGuid,
					@DefaultBenefitID = BenefitID
			FROM	Product.Benefits
			WHERE	((@DefaultBenefitGuid IS NULL) OR (BenefitGuid = @DefaultBenefitGuid)) AND
					((@DefaultBenefitID IS NULL) OR (BenefitID = @DefaultBenefitID));

		IF @DefaultBenefitGuid IS NULL OR @DefaultBenefitID IS NULL
			SELECT TOP 1
					@DefaultBenefitGuid = BenefitGuid,
					@DefaultBenefitID = BenefitID
			FROM	Product.Benefits
			WHERE	(BenefitID = 1);
		
		IF @DefaultBenefitGuid IS NULL OR @DefaultBenefitID IS NULL
			RAISERROR('The specified default benefit is invalid.', 16, 1);
			
		IF @MbrMonthGuid IS NOT NULL OR @MbrMonthID IS NOT NULL 
		SELECT TOP 1
				@MbrMonthGuid = MbrMonthGuid,
				@MbrMonthID = MbrMonthID
		FROM	Measure.MemberMonths
		WHERE	((@MbrMonthGuid IS NULL) OR (MbrMonthGuid = @MbrMonthGuid)) AND
				((@MbrMonthID IS NULL) OR (MbrMonthID = @MbrMonthID));

		IF @MbrMonthGuid IS NULL OR @MbrMonthID IS NULL 
			SELECT TOP 1
					@MbrMonthGuid = MbrMonthGuid,
					@MbrMonthID = MbrMonthID
			FROM	Measure.MemberMonths
			WHERE	(MbrMonthID = 1);
			
		IF @MbrMonthGuid IS NULL OR @MbrMonthID IS NULL
			RAISERROR('The specified member month configuration is invalid.', 16, 1);

		----------------------------------------------------------------------------------------------------------

		DECLARE @Result int;
		SET @Result = 0
      
		--1) Set the target STAGING database...
		IF ISNULL(@Result, 0) = 0 AND @TargetDatabase IS NOT NULL AND @DataSetID IS NULL
			EXEC @Result = Import.SetSourceDatabase	@DatabaseName = @TargetDatabase;

		--2) Import the data from STAGING into the engine format...
		IF ISNULL(@Result, 0) = 0 AND @DataSetID IS NULL
			EXEC @Result = Batch.ImportDataSet	@DataSetID = @DataSetID OUTPUT, 
												@DefaultIhdsProviderId = @DefaultIhdsProviderId, 
												@HedisMeasureID = @HedisMeasureID, 
												@OwnerID = @OwnerID, 
												@Top = @Top;

		--3) Create the data run from the imported data and batch it...
		DECLARE @ID tinyint;
		SET @ID = 0;
		
		DECLARE @BeginInitSeedDateIteration datetime;
		DECLARE @EndInitSeedDateIteration datetime;
		DECLARE @SeedDateIteration datetime;
		
		DECLARE @DataRunIDIteration int;
		DECLARE @DataRuns TABLE (DataRunID int NOT NULL);
		
		SET @RollingMonthsInterval = ISNULL(NULLIF(@RollingMonthsInterval, 0), 1);
		
		WHILE (1 = 1)
			BEGIN;			
				SET @BeginInitSeedDateIteration = DATEADD(dd, -1, DATEADD(mm, (-1 * @ID * @RollingMonthsInterval), DATEADD(dd, 1, @BeginInitSeedDate)));
				SET @EndInitSeedDateIteration = DATEADD(dd, -1, DATEADD(mm, (-1 * @ID * @RollingMonthsInterval), DATEADD(dd, 1, @EndInitSeedDate)));
				SET @SeedDateIteration = DATEADD(dd, -1, DATEADD(mm, (-1 * @ID * @RollingMonthsInterval), DATEADD(dd, 1, @EndInitSeedDate))); --@SeedDate
		
				IF ISNULL(@Result, 0) = 0
					EXEC @Result = Batch.CreateDataSetBatches	@BatchSize = @BatchSize, 
																@BeginInitSeedDate = @BeginInitSeedDateIteration,
																@CalculateMbrMonths = @CalculateMbrMonths, 
																@CalculateXml = @CalculateXml,
																@DataRunID = @DataRunIDIteration OUTPUT, 
																@DataSetID = @DataSetID, 
																@DefaultBenefitID = @DefaultBenefitID,
																@EndInitSeedDate = @EndInitSeedDateIteration,
																@FileFormatID = @FileFormatID,
																@IsReady = 0,
																@MeasureID = @MeasureID, 
																@MeasureSetID = @MeasureSetID, 
																@MbrMonthID = @MbrMonthID,
																@ReturnFileFormatID = @ReturnFileFormatID,
																@SeedDate = @SeedDateIteration;
								
				IF @DataRunID IS NULL AND @DataRunIDIteration IS NOT NULL
					SET @DataRunID = @DataRunIDIteration
								
				INSERT INTO @DataRuns SELECT @DataRunIDIteration;
							
				IF @ID >= ISNULL(@RollingMonths, 0) - 1
					BREAK;
				ELSE								
					SET @ID = @ID + 1;					
			END;
			
		IF @SetToReady = 1
			UPDATE	BDR
			SET		IsReady = 1
			FROM	Batch.DataRuns AS BDR
					INNER JOIN @DataRuns AS DR
							ON BDR.DataRunID = DR.DataRunID
			WHERE	(DataSetID = @DataSetID) AND
					(IsReady = 0);
							
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
											@PerformRollback = 1,
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
GRANT EXECUTE ON  [Cloud].[InitializeDataRun] TO [Processor]
GO
GRANT EXECUTE ON  [Cloud].[InitializeDataRun] TO [Submitter]
GO
