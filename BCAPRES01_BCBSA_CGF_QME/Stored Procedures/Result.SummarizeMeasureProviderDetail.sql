SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 5/10/2011
-- Description:	Summarizes the results from the measure detail by providers and medical groups.
-- =============================================
CREATE PROCEDURE [Result].[SummarizeMeasureProviderDetail]
(
	@DataRunID int,
	@BatchID int = NULL
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

	DECLARE @DataSetID int;
	DECLARE @MbrMonthID int;
	DECLARE @MeasureSetID int;
	DECLARE @OwnerID int;
	DECLARE @SeedDate datetime;
	
	BEGIN TRY;
		
		SET @LogBeginTime = GETDATE();
		SET @LogObjectName = 'SummarizeMeasureProviderDetail'; 
		SET @LogObjectSchema = 'Result'; 
		
		--Added to determine @LogEntryXrefGuid value---------------------------
		SELECT @LogEntryXrefGuid = [Log].GetEntryXrefGuid (@LogObjectSchema, @LogObjectName);
		-----------------------------------------------------------------------
		
		BEGIN TRY;				
			DECLARE @CountRecords bigint;
			
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
			
			--Determines the current state of ANSI_WARNINGS and sets it to "OFF" if necessary (Prevents NULL aggregate messages during the INSERT statement)...
			DECLARE @Ansi_Warnings bit;
			SET @Ansi_Warnings = CASE WHEN (@@OPTIONS & 8) = 8 THEN 1 ELSE 0 END;

			IF @Ansi_Warnings = 1
				SET ANSI_WARNINGS OFF;
			
			--Purges existing summary data, if any, and copies new summary data...
			DELETE FROM Result.MeasureProviderSummary WHERE (DataRunID = @DataRunID);

			IF NOT EXISTS (SELECT TOP 1 1 FROM Result.MeasureProviderSummary)
				TRUNCATE TABLE Result.MeasureProviderSummary;
				
			INSERT INTO Result.MeasureProviderSummary
					(/*Age,*/
					AgeBandID,
					AgeBandSegID,
					/*ClinCondID,*/
					CountEvents,
					CountMembers,
					CountRecords,
					DataRunID,
					DataSetID,
					[Days],
					DSProviderID,
					/*EnrollGroupID,*/
					Gender,/**/
					IsDenominator,
					IsExclusion,
					IsIndicator,
					IsNegative,
					IsNumerator,
					IsNumeratorAdmin,
					IsNumeratorMedRcd,
					IsSupplementalDenominator,
					IsSupplementalExclusion,
					IsSupplementalIndicator,
					IsSupplementalNumerator,
					MeasureID,
					MeasureXrefID,
					MedGrpID,
					MetricID,
					MetricXrefID,
					PayerID,
					PopulationID,
					ProductLineID,
					Qty,
					Qty2,
					Qty3,
					Qty4,
					ResultTypeID,
					[Weight])
			SELECT	/*RMD.Age,*/
					RMD.AgeBandID,
					RMD.AgeBandSegID,
					/*RMD.ClinCondID,*/
					COUNT(DISTINCT CAST(RMD.DSMemberID AS varchar) + '_' + CONVERT(varchar, RMD.KeyDate, 112)) AS CountEvents,
					COUNT(DISTINCT RMD.DSMemberID) AS CountMembers,
					COUNT(DISTINCT RMD.ResultRowID) AS CountRecords,
					RMD.DataRunID,
					RMD.DataSetID,
					SUM(CONVERT(bigint, RMD.[Days])) AS [Days],
					RDSMPK.DSProviderID,
					/*RMD.EnrollGroupID,*/
					RMD.Gender,/**/
					SUM(CONVERT(bigint, RMD.IsDenominator)) AS IsDenominator,
					SUM(CONVERT(bigint, RMD.IsExclusion)) AS IsExclusion,
					SUM(CONVERT(bigint, RMD.IsIndicator)) AS IsIndicator,
					SUM(CONVERT(bigint, CASE WHEN IsDenominator = 1 THEN CASE RMD.IsNumerator WHEN 1 THEN 0 WHEN 0 THEN 1 END WHEN IsExclusion = 1 THEN 0 END)) AS IsNegative,
					SUM(CONVERT(bigint, CASE WHEN IsDenominator = 1 THEN RMD.IsNumerator ELSE 0 END)) AS IsNumerator,
					SUM(CONVERT(bigint, CASE WHEN IsDenominator = 1 AND RMD.IsNumerator = 1 AND ISNULL(RMD.IsSupplementalNumerator, 0) = 0 THEN RMD.IsNumeratorAdmin ELSE 0 END)) AS IsNumeratorAdmin,
					SUM(CONVERT(bigint, CASE WHEN IsDenominator = 1 AND RMD.IsNumerator = 1 AND RMD.IsNumeratorAdmin = 0 THEN RMD.IsNumeratorMedRcd ELSE 0 END)) AS IsNumeratorMedRcd,
					SUM(CONVERT(bigint, CASE WHEN RMD.IsSupplementalDenominator = 1 THEN RMD.IsDenominator ELSE 0 END)) AS IsSupplementalDenominator,
					SUM(CONVERT(bigint, CASE WHEN RMD.IsSupplementalExclusion = 1 THEN RMD.IsExclusion ELSE 0 END)) AS IsSupplementalExclusion,
					SUM(CONVERT(bigint, CASE WHEN RMD.IsSupplementalIndicator = 1 THEN RMD.IsIndicator ELSE 0 END)) AS IsSupplementalIndicator,
					SUM(CONVERT(bigint, CASE WHEN IsDenominator = 1 AND RMD.IsNumerator = 1 AND RMD.IsSupplementalNumerator = 1 AND RMD.IsNumeratorAdmin = 1 THEN 1 ELSE 0 END)) AS IsSupplementalNumerator,
					RMD.MeasureID,
					RMD.MeasureXrefID,
					RDSMPK.MedGrpID,
					RMD.MetricID,
					RMD.MetricXrefID,
					RMD.PayerID,
					RMD.PopulationID,
					RMD.ProductLineID,
					SUM(CONVERT(bigint, RMD.Qty)) AS Qty,
					SUM(CONVERT(bigint, RMD.Qty2)) AS Qty2,
					SUM(CONVERT(bigint, RMD.Qty3)) AS Qty3,
					SUM(CONVERT(bigint, RMD.Qty4)) AS Qty4,
					RMD.ResultTypeID,
					AVG(RMD.[Weight]) AS [Weight]
			FROM	Result.MeasureDetail_Classic AS RMD
					LEFT OUTER JOIN Result.DataSetMemberProviderKey AS RDSMPK
							ON RMD.DataRunID = RDSMPK.DataRunID AND
								RMD.DataSetID = RDSMPK.DataSetID AND
								RMD.DSMemberID = RDSMPK.DSMemberID
			WHERE	(RMD.DataRunID = @DataRunID)
			GROUP BY /*RMD.Age,*/
					RMD.AgeBandID,
					RMD.AgeBandSegID,
					/*RMD.ClinCondID,*/
					RMD.DataRunID,
					RMD.DataSetID,
					RDSMPK.DSProviderID,
					/*RMD.EnrollGroupID,*/
					RMD.Gender,/**/
					RMD.MeasureID,
					RMD.MeasureXrefID,
					RDSMPK.MedGrpID,
					RMD.MetricID,
					RMD.MetricXrefID,
					RMD.PayerID,
					RMD.PopulationID,
					RMD.ProductLineID,
					RMD.ResultTypeID
			--SAME ORDER AS IX_MeasureSummary, CAUSING THE SAME ROW ORDER FOR THIS INDEX AND THE CLUSTERED
			ORDER BY DataSetID, DataRunID, ProductLineID, PopulationID, 
					PayerID, /*EnrollGroupID,*/ ResultTypeID, MeasureID,  MetricID,
					/*ClinCondID,*/ MedGrpID, DSProviderID, AgeBandID, AgeBandSegID, Gender/*, Age*/

			SET @CountRecords = ISNULL(@CountRecords, 0) + @@ROWCOUNT;
			
			--Returns ANSI_WARNINGS back to "ON", if it was originally "ON"...
			IF @Ansi_Warnings = 1
				SET ANSI_WARNINGS ON;
						
			SET @LogDescr = 'Summarizing measure detail by provider completed successfully.'; 
			SET @LogEndTime = GETDATE();
			
			EXEC @Result = Log.RecordEntry		@BeginTime = @LogBeginTime,
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
			SET @LogDescr = 'Summarizing measure detail by provider failed!';
			
			EXEC @Result = Log.RecordEntry		@BeginTime = @LogBeginTime,
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
GRANT EXECUTE ON  [Result].[SummarizeMeasureProviderDetail] TO [Processor]
GO
