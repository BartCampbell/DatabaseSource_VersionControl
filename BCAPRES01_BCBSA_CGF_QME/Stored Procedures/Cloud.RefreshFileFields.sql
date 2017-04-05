SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 5/11/2012
-- Description:	Refreshes the fields associated the specified file formats/objects by pulling in newly-added columns and ordering the columns alphabetically.
-- =============================================
CREATE PROCEDURE [Cloud].[RefreshFileFields]
(
	@AllowDefaultShownValue bit = 0,
	@CountRecords bigint = NULL OUTPUT,
	@FileFormatID int = NULL,
	@FileObjectID int = NULL
)
AS
BEGIN
	SET NOCOUNT ON;
	
	BEGIN TRY;
		
		SET @FileFormatID = NULL; --Protects against error of deleting all other file formats during refresh
		
		DECLARE @CreatedDate datetime;
		SET @CreatedDate = GETDATE();
		
		SELECT	NFF.*
		INTO	#FileFields
		FROM	Cloud.FileFields AS NFF
				INNER JOIN Cloud.FileObjects AS NFO
						ON NFF.FileObjectID = NFO.FileObjectID
		WHERE	((@FileFormatID IS NULL) OR (NFO.FileFormatID = @FileFormatID)) AND
				((@FileObjectID IS NULL) OR (NFO.FileObjectID = @FileObjectID));
		
		SELECT	C.FileFieldGuid AS ChildFieldGuid,
				NFR.ChildFieldID,
				P.FileFieldGuid AS ParentFieldGuid,
				NFR.ParentFieldID
		INTO	#FileRelationships
		FROM	Cloud.FileRelationships AS NFR
				INNER JOIN Cloud.FileFields AS P
						ON NFR.ParentFieldID = P.FileFieldID
				INNER JOIN Cloud.FileFields AS C
						ON NFR.ChildFieldID = C.FileFieldID
		
		BEGIN TRAN TFileFieldsRefresh;
		
		IF @FileFormatID IS NULL	
			BEGIN;
				TRUNCATE TABLE Cloud.FileFields;
				TRUNCATE TABLE Cloud.FileRelationships;
			END;
		ELSE
			BEGIN;
				DELETE CFF FROM Cloud.FileFields AS CFF INNER JOIN Cloud.FileObjects AS CFO ON CFF.FileObjectID = CFO.FileObjectID WHERE CFO.FileFormatID = @FileFormatID;
				DELETE FROM Cloud.FileRelationships WHERE (ParentFieldID NOT IN (SELECT FileFieldID FROM Cloud.FileFields)) OR (ChildFieldID NOT IN (SELECT FileFieldID FROM Cloud.FileFields));
			END;
		
		
		WITH DefaultNotShownFields AS 
		(
			SELECT CONVERT(nvarchar(128), 'BatchID') AS ColumnName
			UNION
			SELECT CONVERT(nvarchar(128), 'CodeID') AS ColumnName
			UNION
			SELECT CONVERT(nvarchar(128), 'DataRunID') AS ColumnName
			UNION
			SELECT CONVERT(nvarchar(128), 'DataSetID') AS ColumnName
			UNION
			SELECT CONVERT(nvarchar(128), 'DSClaimID') AS ColumnName
			UNION
			SELECT CONVERT(nvarchar(128), 'IhdsMemberID') AS ColumnName
			UNION
			SELECT CONVERT(nvarchar(128), 'LogID') AS ColumnName
			UNION
			SELECT CONVERT(nvarchar(128), 'LogTime') AS ColumnName
			UNION
			SELECT CONVERT(nvarchar(128), 'LogUser') AS ColumnName
			UNION
			SELECT CONVERT(nvarchar(128), 'MemberID') AS ColumnName
			UNION
			SELECT CONVERT(nvarchar(128), 'OwnerID') AS ColumnName
			UNION
			SELECT CONVERT(nvarchar(128), 'ResultRowID') AS ColumnName
			UNION
			SELECT CONVERT(nvarchar(128), 'SourceID') AS ColumnName
			UNION
			SELECT CONVERT(nvarchar(128), 'SpId') AS ColumnName
		),
		DefaultTranslatorsBase AS
		(
			SELECT DISTINCT
					C.DATA_TYPE AS ColumnDataType,
					NFF.SourceColumn AS ColumnName,
					NFF.FileTranslatorID
			FROM	Cloud.FileFields AS NFF
					INNER JOIN Cloud.FileObjects AS NFO
							ON NFF.FileObjectID = NFO.FileObjectID 
					INNER JOIN Cloud.FileTranslators AS NFT
							ON NFF.FileTranslatorID = NFT.FileTranslatorID
					INNER JOIN INFORMATION_SCHEMA.COLUMNS AS C
							ON NFO.OutSourceName = C.TABLE_NAME AND
								NFO.OutSourceSchema = C.TABLE_SCHEMA AND
								NFF.SourceColumn = C.COLUMN_NAME
					INNER JOIN INFORMATION_SCHEMA.ROUTINES AS R
							ON NFT.InFunctionName = R.ROUTINE_NAME AND
								NFT.InFunctionSchema = R.ROUTINE_SCHEMA AND
								C.DATA_TYPE = R.DATA_TYPE AND
								R.ROUTINE_TYPE = 'FUNCTION'
			WHERE	(NFF.FileTranslatorID IS NOT NULL)
		),
		DefaultTranslators AS
		(
			SELECT	ColumnName, 
					MIN(FileTranslatorID) AS FileTranslatorID
			FROM	DefaultTranslatorsBase
			GROUP BY ColumnName
			HAVING (COUNT(*) = 1)
		),
		FileObjectColumns AS
		(
			SELECT	LOWER(C.COLUMN_NAME) AS FieldName,
					NFO.FileObjectID,
					DT.FileTranslatorID,
					CASE WHEN DNSF.ColumnName IS NOT NULL OR ISNULL(@AllowDefaultShownValue, 0) = 0 THEN 0 ELSE 1 END AS IsShown,
					C.COLUMN_NAME AS SourceColumn
			FROM	Cloud.FileObjects AS NFO
					INNER JOIN INFORMATION_SCHEMA.COLUMNS AS C
							ON NFO.OutSourceName = C.TABLE_NAME AND
								NFO.OutSourceSchema = C.TABLE_SCHEMA
					LEFT OUTER JOIN DefaultNotShownFields AS DNSF
							ON C.COLUMN_NAME = DNSF.ColumnName 
					LEFT OUTER JOIN DefaultTranslators AS DT
							ON C.COLUMN_NAME = DT.ColumnName
			WHERE	((@FileFormatID IS NULL) OR (NFO.FileFormatID = @FileFormatID)) AND
					((@FileObjectID IS NULL) OR (NFO.FileObjectID = @FileObjectID))	
		)
		INSERT INTO Cloud.FileFields
				(CreatedBy,
				CreatedDate,
				CreatedSpId,
				FieldName,
				FileFieldGuid,
				FileObjectID,
				FileTranslatorID,
				IsShown,
				SourceColumn)
		SELECT	SUSER_NAME() AS CreatedBy,
				@CreatedDate AS CreatedDate,
				@@SPID AS CreatedSpId,
				FOC.FieldName,
				NEWID() AS FileFieldGuid,
				FOC.FileObjectID,
				FOC.FileTranslatorID,
				FOC.IsShown,
				FOC.SourceColumn
		FROM	FileObjectColumns AS FOC
				LEFT OUTER JOIN #FileFields AS FF
						ON FOC.FileObjectID = FF.FileObjectID AND
							FOC.SourceColumn = FF.SourceColumn
		WHERE	(FF.FileFieldID IS NULL)
		UNION ALL
		SELECT	FF.CreatedBy,
				FF.CreatedDate,
				FF.CreatedSpId,
				FF.FieldName,
				FF.FileFieldGuid,
				FF.FileObjectID,
				FF.FileTranslatorID,
				FF.IsShown,
				FF.SourceColumn
		FROM	#FileFields AS FF
		ORDER BY FileObjectID, SourceColumn;
		
		SET @CountRecords = ISNULL(@CountRecords, 0) + @@ROWCOUNT;
		
		INSERT INTO Cloud.FileRelationships
				(ChildFieldID,
				ParentFieldID)
		SELECT	C.FileFieldID AS ChildFieldID,
				P.FileFieldID AS ParentFieldID
		FROM	#FileRelationships AS t
				INNER JOIN Cloud.FileFields AS P
						ON t.ParentFieldGuid = P.FileFieldGuid
				INNER JOIN Cloud.FileFields AS C
						ON t.ChildFieldGuid = C.FileFieldGuid
		
		SET @CountRecords = ISNULL(@CountRecords, 0) + @@ROWCOUNT;
					
		COMMIT TRAN TFileFieldsRefresh;
								
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
GRANT EXECUTE ON  [Cloud].[RefreshFileFields] TO [Processor]
GO
GRANT EXECUTE ON  [Cloud].[RefreshFileFields] TO [Submitter]
GO
