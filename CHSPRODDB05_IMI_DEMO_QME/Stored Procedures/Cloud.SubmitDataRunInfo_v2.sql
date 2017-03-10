SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 9/12/2012
-- Description:	Receives and inserts data set, data run, and batch information.
-- =============================================
CREATE PROCEDURE [Cloud].[SubmitDataRunInfo_v2]
(
	@Data xml,
	@EngineGuid uniqueidentifier
)
AS
BEGIN
	SET NOCOUNT ON;
	
	BEGIN TRY;
	
		IF @EngineGuid IS NULL
			RAISERROR('The engine identifier was not specified.', 16, 1);
			
		DECLARE @EngineID int;
		SELECT @EngineID = EngineID FROM Cloud.Engines WHERE (EngineGuid = @EngineGuid);
		
		IF @EngineID IS NULL
			RAISERROR('The specified engine identifier is invalid or expired.', 16, 1);
		
		IF @Data IS NULL OR @Data.exist('dataset/*') = 0 OR @Data.exist('dataset/run/*') = 0 
			RAISERROR ('The supplied xml data is invalid.', 16, 1);
		
		IF OBJECT_ID('tempdb..#DataSets') IS NOT NULL
			DROP TABLE #DataSets;

		SELECT	dataset.value('@countclaimcodes', 'int') AS CountClaimCodes,
				dataset.value('@countclaimlines', 'int') AS CountClaimLines,
				dataset.value('@countenrollment', 'int') AS CountEnrollment,
				dataset.value('@countmemberattributes', 'int') AS CountMemberAttribs,
				dataset.value('@countmembers', 'int') AS CountMembers,
				dataset.value('@countproviders', 'int') AS CountProviders,
				dataset.value('@createdby', 'nvarchar(128)') AS CreatedBy,
				dataset.value('@createddate', 'datetime') AS CreatedDate,
				CONVERT(uniqueidentifier, NULL) AS DataSetGuid,
				CONVERT(int, NULL) AS DataSetID,
				dataset.value('@owner', 'uniqueidentifier') AS OwnerGuid,
				dataset.value('@id', 'uniqueidentifier') AS SourceGuid
		INTO	#DataSets
		FROM	@Data.nodes('/dataset') AS ds(dataset);
				
		IF OBJECT_ID('tempdb..#DataRuns') IS NOT NULL
			DROP TABLE #DataRuns;
				
		SELECT	datarun.value('@batchsize', 'int') AS [BatchSize] ,
				datarun.value('@beginseeddate', 'datetime') AS BeginInitSeedDate,
				datarun.value('@begintime', 'datetime') AS BeginTime,
				dbo.ConvertBitFromYN(datarun.value('@calculatemembermonths', 'char(1)')) AS CalculateMbrMonths ,
				datarun.value('@countbatches', 'int') AS CountBatches,
				datarun.value('@createdby', 'nvarchar(128)') AS CreatedBy,
				datarun.value('@createddate', 'datetime') AS CreatedDate,
				CONVERT(uniqueidentifier, NULL) AS DataRunGuid,
				CONVERT(int, NULL) AS DataRunID,
				datarun.value('@defaultbenefit', 'uniqueidentifier') AS DefaultBenefitGuid,
				datarun.value('@endseeddate', 'datetime') AS EndInitSeedDate,
				datarun.value('@endtime', 'datetime') AS EndTime,
				datarun.value('@fileformat', 'uniqueidentifier') AS FileFormatGuid,
				datarun.value('@measureset', 'uniqueidentifier') AS MeasureSetGuid,
				datarun.value('@membermonths', 'uniqueidentifier') AS MbrMonthGuid,
				datarun.value('@returnfileformat', 'uniqueidentifier') AS ReturnFileFormatGuid,
				datarun.value('@seeddate', 'datetime') AS SeedDate,
				dataset.value('@id', 'uniqueidentifier') AS DataSetSourceGuid,
				datarun.value('@id', 'uniqueidentifier') AS SourceGuid
		INTO	#DataRuns
		FROM	@Data.nodes('/dataset') AS ds(dataset)
				CROSS APPLY ds.dataset.nodes('./run') AS dr(datarun)
				
		IF OBJECT_ID('tempdb..#Batches') IS NOT NULL
			DROP TABLE #Batches;
				
		SELECT	CONVERT(uniqueidentifier, NULL) AS BatchGuid,
				CONVERT(int, NULL) AS BatchID,
				batch.value('@countclaimcodes', 'int') AS CountClaimCodes,
				batch.value('@countclaimlines', 'int') AS CountClaimLines,
				batch.value('@countenrollment', 'int') AS CountEnrollment,
				batch.value('@countitems', 'int') AS CountItems,
				batch.value('@countmeasures', 'int') AS CountMeasures,
				batch.value('@countmembers', 'int') AS CountMembers,
				batch.value('@countproviders', 'int') AS CountProviders,
				datarun.value('@id', 'uniqueidentifier') AS DataRunSourceGuid,
				batch.value('@id', 'uniqueidentifier') AS SourceGuid
		INTO	#Batches
		FROM	@Data.nodes('/dataset/run') AS dr(datarun)
				CROSS APPLY dr.datarun.nodes('./batch') AS b(batch)

		BEGIN TRANSACTION TDataRunSubmittal;

		INSERT INTO Batch.DataSets
				(CountClaimCodes,
				CountClaimLines,
				CountClaims,
				CountEnrollment,
				CountMemberAttribs,
				CountMembers,
				CountProviders,
				CreatedBy,
				CreatedDate,
				DataSetGuid,
				EngineGuid,
				OwnerID,
				SourceGuid)
		SELECT	DS.CountClaimCodes,
				DS.CountClaimLines,
				0 AS CountClaims,
				DS.CountEnrollment,
				DS.CountMemberAttribs,
				DS.CountMembers,
				DS.CountProviders,
				DS.CreatedBy,
				DS.CreatedDate,
				NEWID() AS DataSetGuid,
				@EngineGuid,
				BDO.OwnerID,
				DS.SourceGuid
		FROM	#DataSets AS DS
				INNER JOIN Batch.DataOwners AS BDO
						ON DS.OwnerGuid = BDO.OwnerGuid;
						
		UPDATE	DS
		SET		DataSetGuid = BDS.DataSetGuid,
				DataSetID = BDS.DataSetID
		FROM	#DataSets AS DS
				INNER JOIN Batch.DataSets AS BDS
						ON DS.SourceGUid = BDS.SourceGuid;

		INSERT INTO Batch.DataRuns
				([BatchSize],
				BeginInitSeedDate,
				BeginTime,
				CalculateMbrMonths,
				CountBatches,
				CreatedBy,
				CreatedDate,
				DataRunGuid,
				DataSetID,
				DefaultBenefitID,
				EndInitSeedDate,
				EndTime,
				FileFormatID,
				MeasureSetID,
				MbrMonthID,
				ReturnFileFormatID,
				SeedDate,
				SourceGuid)
		SELECT	DR.[BatchSize],
				DR.BeginInitSeedDate,
				DR.BeginTime,
				DR.CalculateMbrMonths,
				DR.CountBatches,
				DR.CreatedBy,
				DR.CreatedDate,
				NEWID() AS DataRunGuid,
				DS.DataSetID,
				PB.BenefitID AS DefaultBenefitID,
				DR.EndInitSeedDate,
				DR.EndTime,
				CFF1.FileFormatID,
				MMS.MeasureSetID,
				MMM.MbrMonthID,
				CFF2.FileFormatID AS ReturnFileFormatID,
				DR.SeedDate,
				DR.SourceGuid
		FROM	#DataRuns AS DR
				INNER JOIN #DataSets AS DS
						ON DR.DataSetSourceGuid = DS.SourceGuid
				INNER JOIN Measure.MeasureSets AS MMS
						ON DR.MeasureSetGuid = MMS.MeasureSetGuid
				INNER JOIN Measure.MemberMonths AS MMM
						ON DR.MbrMonthGuid = MMM.MbrMonthGuid
				INNER JOIN Product.Benefits AS PB
						ON DR.DefaultBenefitGuid = PB.BenefitGuid
				LEFT OUTER JOIN Cloud.FileFormats AS CFF1
						ON DR.FileFormatGuid = CFF1.FileFormatGuid
				LEFT OUTER JOIN Cloud.FileFormats AS CFF2
						ON DR.ReturnFileFormatGuid = CFF2.FileFormatGuid;

		UPDATE	DR
		SET		DataRunGuid = BDR.DataRunGuid,
				DataRunID = BDR.DataRunID
		FROM	#DataRuns AS DR
				INNER JOIN Batch.DataRuns AS BDR
						ON DR.SourceGuid = BDR.SourceGuid;

		DECLARE @BatchStatusQ smallint; --Registering
		DECLARE @BatchStatusR smallint; --Registered
		SET @BatchStatusQ = Batch.ConvertBatchStatusIDFromAbbrev('Q');
		SET @BatchStatusR = Batch.ConvertBatchStatusIDFromAbbrev('R');

		INSERT INTO Batch.[Batches]
				(BatchGuid,
				BatchStatusID,
				CountClaimCodes,
				CountClaimLines,
				CountEnrollment,
				CountItems,
				CountMeasures,
				CountMembers,
				CountProviders,
				DataRunID,
				DataSetID,
				SourceGuid)
		SELECT	NEWID() AS BatchGuid,
				@BatchStatusQ AS BatchStatusID,
				B.CountClaimCodes,
				B.CountClaimLines,
				B.CountEnrollment,
				B.CountItems,
				B.CountMeasures,
				B.CountMembers,
				B.CountProviders,
				BDR.DataRunID,
				BDR.DataSetID,
				B.SourceGuid
		FROM	#Batches AS B
				INNER JOIN Batch.DataRuns AS BDR
						ON B.DataRunSourceGuid = BDR.SourceGuid;
						
		UPDATE	B
		SET		BatchGuid = BB.BatchGuid,
				BatchID = BB.BatchID
		FROM	#Batches AS B
				INNER JOIN Batch.[Batches] AS BB
						ON B.SourceGuid = BB.SourceGuid;
						
		INSERT INTO Cloud.[Batches]
				(BatchID,
				EngineID,
				IsCancelled)
		SELECT	BatchID,
				@EngineID AS EngineID,
				0 AS IsCancelled
		FROM	#Batches;
		
		UPDATE	BB
		SET		BatchStatusID = @BatchStatusR
		FROM	Batch.[Batches] AS BB
				INNER JOIN #Batches AS B
						ON BB.SourceGuid = B.SourceGuid AND
							BB.BatchID = B.BatchID;
		
		COMMIT TRANSACTION TDataRunSubmittal;		
		
		EXEC Cloud.UpdateEngineActivity @EngineGuid = @EngineGuid;
		
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
											@EngineGuid = @EngineGuid,
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
GO
GRANT VIEW DEFINITION ON  [Cloud].[SubmitDataRunInfo_v2] TO [db_executer]
GO
GRANT EXECUTE ON  [Cloud].[SubmitDataRunInfo_v2] TO [db_executer]
GO
GRANT EXECUTE ON  [Cloud].[SubmitDataRunInfo_v2] TO [Processor]
GO
GRANT EXECUTE ON  [Cloud].[SubmitDataRunInfo_v2] TO [Submitter]
GO
GO

GO

GO
