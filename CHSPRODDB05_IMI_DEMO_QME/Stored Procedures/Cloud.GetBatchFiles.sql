SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 7/1/2013
-- Description:	Returns one or more batch file records, based on the specified criteria.
-- =============================================
CREATE PROCEDURE [Cloud].[GetBatchFiles]
(
	@BatchFileGuid uniqueidentifier = NULL,
	@BatchFileID int = NULL,
	@BatchGuid uniqueidentifier = NULL,
	@BatchSourceGuid uniqueidentifier = NULL,
	@BatchID int = NULL,
	@FileFormatCtgyAbbrev varchar(16) = NULL,
	@FileFormatCtgyGuid uniqueidentifier = NULL,
	@FileFormatCtgyID tinyint = NULL
)
AS
BEGIN
	SET NOCOUNT ON;
	
	BEGIN TRY;
		
		SELECT	CBF.BatchFileGuid,
		        CBF.BatchFileID,
		        BB.BatchGuid,
		        CBF.BatchID,
		        BB.SourceGuid AS BatchSourceGuid,
		        CBF.ChkSha256,
		        CBF.CreatedDate,
		        CBF.CryptoIV,
		        CBF.CryptoKey,
		        CFF1.FileFormatGuid AS DataRunFileFormatGuid,
		        CFF1.FileFormatID AS  DataRunFileFormatID,
		        CFF2.FileFormatGuid AS DataRunReturnFileFormatGuid,
		        CFF2.FileFormatID AS  DataRunReturnFileFormatID,
		        CFF.FileFormatGuid,
		        CBF.FileFormatID,
		        CBF.[FileName],
		        MMS.MeasureSetGuid,
		        MMS.MeasureSetID,
		        BDO.OwnerGuid,
		        BDO.OwnerID,
		        CBF.SizeCompressed,
		        CBF.SizeUncompressed
		FROM	Batch.[Batches] AS BB WITH(NOLOCK)
				INNER JOIN Batch.DataRuns AS BDR WITH(NOLOCK)
						ON BB.DataRunID = BDR.DataRunID
				LEFT OUTER JOIN Cloud.FileFormats AS CFF1 WITH(NOLOCK)
						ON BDR.FileFormatID = CFF1.FileFormatID
				LEFT OUTER JOIN Cloud.FileFormats AS CFF2 WITH(NOLOCK)
						ON BDR.ReturnFileFormatID = CFF2.FileFormatID
				INNER JOIN Measure.MeasureSets AS MMS WITH(NOLOCK)
						ON BDR.MeasureSetID = MMS.MeasureSetID
				INNER JOIN Batch.DataSets AS BDS WITH(NOLOCK)
						ON BDR.DataSetID = BDS.DataSetID
				INNER JOIN Batch.DataOwners AS BDO WITH(NOLOCK)
						ON BDS.OwnerID = BDO.OwnerID
				INNER JOIN Cloud.[Batches] AS CB WITH(NOLOCK)
						ON BB.BatchID = CB.BatchID
				INNER JOIN Cloud.BatchFiles AS CBF WITH(NOLOCK)
						ON CB.BatchID = CBF.BatchID
				INNER JOIN Cloud.FileFormats AS CFF WITH(NOLOCK)
						ON CBF.FileFormatID = CFF.FileFormatID 
				INNER JOIN Cloud.FileFormatCategories AS CFFC WITH(NOLOCK)
						ON CFF.FileFormatCtgyID = CFFC.FileFormatCtgyID
		WHERE	((@BatchFileGuid IS NULL) OR (CBF.BatchFileGuid = @BatchFileGuid)) AND
				((@BatchFileID IS NULL) OR (CBF.BatchFileID = @BatchFileID)) AND
				((@BatchGuid IS NULL) OR (BB.BatchGuid = @BatchGuid)) AND
				((@BatchID IS NULL) OR (BB.BatchID = @BatchID)) AND
				((@BatchSourceGuid IS NULL) OR (BB.SourceGuid = @BatchSourceGuid)) AND
				((@FileFormatCtgyAbbrev IS NULL) OR (CFFC.Abbrev = @FileFormatCtgyAbbrev)) AND
				((@FileFormatCtgyGuid IS NULL) OR (CFFC.FileFormatCtgyGuid = @FileFormatCtgyGuid)) AND
				((@FileFormatCtgyID IS NULL) OR (CFFC.FileFormatCtgyID = @FileFormatCtgyID));
								
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
GRANT EXECUTE ON  [Cloud].[GetBatchFiles] TO [Controller]
GO
GRANT EXECUTE ON  [Cloud].[GetBatchFiles] TO [Processor]
GO
GRANT EXECUTE ON  [Cloud].[GetBatchFiles] TO [Submitter]
GO
