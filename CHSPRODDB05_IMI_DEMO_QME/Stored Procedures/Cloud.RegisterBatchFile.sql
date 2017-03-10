SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 9/14/2012
-- Description:	Registers the specified batch file prior to transmission.
-- =============================================
CREATE PROCEDURE [Cloud].[RegisterBatchFile]
(
	@BatchGuid uniqueidentifier = NULL OUTPUT,
	@BatchFileGuid uniqueidentifier = NULL OUTPUT,
	@BatchFileID int = NULL OUTPUT,
	@BatchID int = NULL OUTPUT,
	@BatchSourceGuid uniqueidentifier = NULL,
	@ChkSha256 varchar(64),
	@CryptoIV varchar(256),
	@CryptoKey varchar(256),
	@DataRunFileFormatGuid uniqueidentifier = NULL OUTPUT,
	@DataRunFileFormatID int = NULL OUTPUT,
	@DataRunReturnFileFormatGuid uniqueidentifier = NULL OUTPUT,
	@DataRunReturnFileFormatID int = NULL OUTPUT,
	@FileFormatGuid uniqueidentifier = NULL OUTPUT,
	@FileFormatID int = NULL OUTPUT,
	@FileName varchar(128) = NULL OUTPUT,
	@MeasureSetGuid uniqueidentifier = NULL OUTPUT,
	@MeasureSetID int = NULL OUTPUT,
	@OwnerGuid uniqueidentifier = NULL OUTPUT,
	@OwnerID int = NULL OUTPUT,
	@SizeCompressed bigint,
	@SizeUncompressed bigint	
)
AS
BEGIN
	SET NOCOUNT ON;
	
	BEGIN TRY;
		
		--i) Validate the batch...
		IF @BatchGuid IS NULL AND @BatchID IS NULL AND @BatchSourceGuid IS NULL
			RAISERROR('The batch was not specified.', 16, 1);

		SELECT TOP 1 
				@BatchGuid = BB.BatchGuid, 
				@BatchID = BB.BatchID,
				@BatchSourceGuid = BB.SourceGuid,
				@DataRunFileFormatGuid = CFF1.FileFormatGuid,
				@DataRunFileFormatID = CFF2.FileFormatID,
				@DataRunReturnFileFormatGuid = CFF2.FileFormatGuid,
				@DataRunReturnFileFormatID = CFF2.FileFormatID,
				@MeasureSetGuid = MMS.MeasureSetGuid,
				@MeasureSetID = MMS.MeasureSetID,
				@OwnerGuid = BDO.OwnerGuid,
				@OwnerID = BDO.OwnerID
		FROM	Batch.[Batches] AS BB
				INNER JOIN Batch.DataRuns AS BDR
						ON BB.DataRunID = BDR.DataRunID
				LEFT OUTER JOIN Cloud.FileFormats AS CFF1
						ON BDR.FileFormatID = CFF1.FileFormatID
				LEFT OUTER JOIN Cloud.FileFormats AS CFF2
						ON BDR.ReturnFileFormatID = CFF2.FileFormatID
				INNER JOIN Measure.MeasureSets AS MMS
						ON BDR.MeasureSetID = MMS.MeasureSetID
				INNER JOIN Batch.DataSets AS BDS
						ON BDR.DataSetID = BDS.DataSetID
				INNER JOIN Batch.DataOwners AS BDO
						ON BDS.OwnerID = BDO.OwnerID
		WHERE	((@BatchGuid IS NULL) OR (BB.BatchGuid = @BatchGuid)) AND
				((@BatchID IS NULL) OR (BB.BatchID = @BatchID)) AND
				((@BatchSourceGuid IS NULL) OR (BB.SourceGuid = @BatchSourceGuid));

		IF @BatchGuid IS NULL
			RAISERROR('The specified batch is invalid.', 16, 1);
		
		--ii) Validate the file format...
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
								
		IF LEN(@ChkSha256) < 44
			RAISERROR('The specified file check sum is invalid.', 16, 1);
			
		SET @BatchFileGuid = NEWID();
		
		WITH Random AS 
		(
			SELECT ROUND(((2 - 1) * RAND(CHECKSUM(NEWID())) + 1), 0)  AS Random
		),
		RandomString AS
		(
			SELECT	dbo.Concatenate(
						REPLACE( --REPLACE used as a safety net, but should never be used
							CASE R.Random
								WHEN 1 THEN CHAR(ROUND(((90 - 65) * RAND(CHECKSUM(NEWID())) + 65), 0))
								WHEN 2 THEN CHAR(ROUND(((57 - 48) * RAND(CHECKSUM(NEWID())) + 48), 0))
								ELSE '*'
								END, 
							'*', '0')
						, '') AS Random
			FROM	Random AS R
					INNER JOIN dbo.Tally AS T
							ON T.N BETWEEN 1 AND 6
		)
		SELECT	@FileName = CB.Identifier + '-' + RS.Random + '-' + CONVERT(varchar(16), dbo.ConvertIntToHex(CFF.FileFormatID, 0)) + '.' + CFFT.FileExtension
		FROM	Cloud.[Batches] AS CB
				INNER JOIN Cloud.FileFormats AS CFF
						ON CFF.FileFormatID = @FileFormatID
				INNER JOIN Cloud.FileFormatTypes AS CFFT
						ON CFF.FileFormatTypeID = CFFT.FileFormatTypeID
				CROSS JOIN RandomString AS RS
		WHERE	(CB.BatchID = @BatchID);
			
		INSERT INTO Cloud.BatchFiles
				(BatchFileGuid,
				BatchID,
				ChkSha256,
				CreatedDate,
				CryptoKey,
				CryptoIV,
				FileFormatID,
				[FileName],
				SizeCompressed,
				SizeUncompressed)
		VALUES  (@BatchFileGuid,
				@BatchID,
				@ChkSha256,
				GETDATE(),
				@CryptoKey,
				@CryptoIV,
				@FileFormatID,
				@FileName,
				@SizeCompressed,
				@SizeUncompressed);
				
		SET @BatchFileID = SCOPE_IDENTITY();
			
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
GRANT EXECUTE ON  [Cloud].[RegisterBatchFile] TO [Controller]
GO
GRANT VIEW DEFINITION ON  [Cloud].[RegisterBatchFile] TO [db_executer]
GO
GRANT EXECUTE ON  [Cloud].[RegisterBatchFile] TO [db_executer]
GO
GRANT EXECUTE ON  [Cloud].[RegisterBatchFile] TO [Processor]
GO
GRANT EXECUTE ON  [Cloud].[RegisterBatchFile] TO [Submitter]
GO
