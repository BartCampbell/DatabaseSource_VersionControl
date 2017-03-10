SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 9/10/2013
-- Description:	Compiles the provider reference key values for the specified Data Run.
-- =============================================
CREATE PROCEDURE [Result].[CompileDataSetProviderKey]
(
	@DataRunID int
)
AS
BEGIN
	SET NOCOUNT ON;
		
	DECLARE @LogBeginTime datetime;
	DECLARE @LogDescr varchar(256);
	DECLARE @LogEndTime datetime;
	DECLARE @LogObjectName nvarchar(128);
	DECLARE @LogObjectSchema nvarchar(128);
	
	DECLARE @Result int;

	DECLARE @BatchID int;
	DECLARE @DataSetID int;
	DECLARE @MbrMonthID int;
	DECLARE @MeasureSetID int;
	DECLARE @OwnerID int;
	DECLARE @SeedDate datetime;
	
	BEGIN TRY;
		
		SET @LogBeginTime = GETDATE();
		SET @LogObjectName = 'CompileDataSetProviderKey'; 
		SET @LogObjectSchema = 'Result'; 
		
		BEGIN TRY;				
			DECLARE @CountRecords int;
			
			SELECT TOP 1	
					--@DataRunID = B.DataRunID,
					@DataSetID = DS.DataSetID,
					@MbrMonthID = DR.MbrMonthID,
					@MeasureSetID = DR.MeasureSetID,
					@OwnerID = DS.OwnerID,
					@SeedDate = DR.SeedDate
			FROM	Batch.[Batches] AS B 
					INNER JOIN Batch.DataSets AS DS 
							ON B.DataSetID = DS.DataSetID 
					INNER JOIN Batch.DataRuns AS DR
							ON B.DataRunID = DR.DataRunID
			WHERE	(DR.DataRunID = @DataRunID) AND
					((@BatchID IS NULL) OR (B.BatchID = @BatchID));
			
			---------------------------------------------------------------------------
			
			DECLARE @AllowedCharsForNameFirst smallint;		
			DECLARE @AllowedCharsForNameLast smallint;
			DECLARE @ObscureCharacter char(1);
							
			SET @AllowedCharsForNameFirst = 1;
			SET @AllowedCharsForNameLast = 1;
			SET @ObscureCharacter = '#';

			DECLARE @LengthOfDSProviderID int;
			DECLARE @LengthOfIhdsProviderID int;

			SELECT @LengthOfDSProviderID = MAX(LEN(CAST(DSProviderID AS varchar(16)))) FROM Provider.Providers WHERE DataSetID = @DataSetID;
			SELECT @LengthOfIhdsProviderID = MAX(LEN(CAST(IhdsProviderID AS varchar(16)))) FROM Provider.Providers WHERE DataSetID = @DataSetID;

			DELETE FROM Result.DataSetProviderKey WHERE ((DataRunID = @DataRunID) AND (DataSetID = @DataSetID));

			SELECT DISTINCT
					DSProviderID
			INTO	#ValidProviders
			FROM	Result.DataSetMemberProviderKey AS t
			WHERE	t.DataRunID = @DataRunID AND
					t.DSProviderID IS NOT NULL
			UNION
			SELECT DISTINCT
					DSProviderID
			FROM	Result.DataSetMeasureProviderKey AS t
			WHERE	t.DataRunID = @DataRunID AND
					t.DSProviderID IS NOT NULL
			UNION
			SELECT DISTINCT
					DSProviderID
			FROM	Result.MeasureDetail AS t
			WHERE	t.DataRunID = @DataRunID AND
					t.DSProviderID IS NOT NULL
			UNION
			SELECT DISTINCT
					DSProviderID
			FROM	Result.MeasureEventDetail AS t
			WHERE	t.DataRunID = @DataRunID AND
					t.DSProviderID IS NOT NULL
			UNION 
			SELECT DISTINCT
					DSProviderID
			FROM	Result.MeasureProviderSummary AS t
			WHERE	t.DataRunID = @DataRunID AND
					t.DSProviderID IS NOT NULL;

			CREATE UNIQUE CLUSTERED INDEX IX_#ValidProviders ON #ValidProviders (DSProviderID);

			IF NOT EXISTS(SELECT TOP 1 1 FROM Result.DataSetProviderKey)
				TRUNCATE TABLE Result.DataSetProviderKey;

			INSERT INTO	Result.DataSetProviderKey
					(BitSpecialties,
					CustomerProviderID,
					DataRunID,
					DataSetID,
					DisplayID,
					DSProviderID,
					IhdsProviderID,
					ProviderName)
			SELECT DISTINCT
					P.BitSpecialties,
					DP.CustomerProviderID,
					@DataRunID AS DataRunID,
					@DataSetID AS DataSetID,
					REPLICATE('0', @LengthOfIhdsProviderID-LEN(CAST(P.IhdsProviderID AS varchar(12)))) + CAST(P.IhdsProviderID AS varchar(12)) + '-' + 
									CAST(CAST(@DataSetID AS varchar(6)) + '-' +
									REPLICATE('0', @LengthOfDSProviderID-LEN(CAST(P.DSProviderID AS varchar(12)))) + CAST(P.DSProviderID AS varchar(12)) AS varchar(32)) AS DisplayID,
					P.DSProviderID,  
					P.IhdsProviderID,
					ISNULL(DP.NameLast + ISNULL(CASE WHEN DP.NameLast IS NOT NULL THEN ', ' ELSE '' END + DP.NameFirst, ''), 'Unknown (' + CustomerProviderID + ')') AS ProviderName
			FROM	Provider.Providers AS P 
					INNER JOIN dbo.Provider AS DP
							ON P.IhdsProviderID = DP.ihds_prov_id AND
								P.DataSetID = @DataSetID
					INNER JOIN #ValidProviders AS t
							ON t.DSProviderID = P.DSProviderID
			ORDER BY DSProviderID

			SET @CountRecords = ISNULL(@CountRecords, 0) + @@ROWCOUNT;
						
			SET @LogDescr = 'Compiling of provider key values completed successfully.'; 
			SET @LogEndTime = GETDATE();
			
			EXEC @Result = [Log].RecordEntry	@BatchID = @BatchID,
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
			DECLARE @ErrorMessage nvarchar(MAX);
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
			SET @LogDescr = 'Compiling of provider key values failed!';
			
			EXEC @Result = [Log].RecordEntry	@BatchID = @BatchID,
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
GRANT VIEW DEFINITION ON  [Result].[CompileDataSetProviderKey] TO [db_executer]
GO
GRANT EXECUTE ON  [Result].[CompileDataSetProviderKey] TO [db_executer]
GO
GRANT EXECUTE ON  [Result].[CompileDataSetProviderKey] TO [Processor]
GO
