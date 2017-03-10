SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 5/11/2012
-- Description:	Creates a copy of all objects and fields from the specified file format.
-- =============================================
CREATE PROCEDURE [Cloud].[DuplicateFileFormat]
(
	@CountRecords bigint = NULL OUTPUT,
	@FileFormatID int,
	@NewFileFormatID int = NULL OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON;
	
	BEGIN TRY;
		--i) Declare generic key table...
		DECLARE @Keys TABLE 
		(
			DestinationGuid uniqueidentifier NULL DEFAULT NEWID(),
			DestinationID bigint NULL,
			ID bigint IDENTITY(1,1) NOT NULL,
			SourceGuid uniqueidentifier NOT NULL,
			SourceID bigint NOT NULL,
			SourceObject nvarchar(128) NOT NULL,
			SourceSchema nvarchar(128) NOT NULL
		);
			
		--1) Populate keys for GUID matching...
		--1a) Add the file formats to the keys list...
		INSERT INTO @Keys
				(SourceGuid, SourceID, SourceObject, SourceSchema)
		SELECT	t.FileFormatGuid AS SourceGuid,
				t.FileFormatID AS SourceID,
				'FileFormats' AS SourceTable,
				'Cloud' AS SourceSchema
		FROM	Cloud.FileFormats AS T
		WHERE	(FileFormatID = @FileFormatID)
		ORDER BY SourceID;

		--1b) Add the child file objects to the keys list...
		INSERT INTO @Keys
				(SourceGuid, SourceID, SourceObject, SourceSchema)
		SELECT	t.FileObjectGuid AS SourceGuid,
				t.FileObjectID AS SourceID,
				'FileObjects' AS SourceTable,
				'Cloud' AS SourceSchema
		FROM	Cloud.FileObjects AS t
		WHERE	t.FileFormatID IN 
								(
									SELECT	SourceID 
									FROM	@Keys
									WHERE	(SourceSchema = 'Cloud') AND 
											(SourceObject = 'FileFormats')
								)
		ORDER BY SourceID;

		--1c) Add the child file fields to the keys list...
		INSERT INTO @Keys
				(SourceGuid, SourceID, SourceObject, SourceSchema)
		SELECT	t.FileFieldGuid AS SourceGuid,
				t.FileFieldID AS SourceID,
				'FileFields' AS SourceTable,
				'Cloud' AS SourceSchema
		FROM	Cloud.FileFields AS t
		WHERE	t.FileObjectID IN 
								(
									SELECT	SourceID 
									FROM	@Keys
									WHERE	(SourceSchema = 'Cloud') AND 
											(SourceObject = 'FileObjects')
								)
		ORDER BY SourceID;

		--2) Insert new "copied" records into their respective tables
		BEGIN TRANSACTION TFileFormats;

		--2a) Insert file formats...
		INSERT INTO Cloud.FileFormats
				(AllowAutoFields,
				Descr,
				FileFormatGuid,
				FileFormatTypeID)
		SELECT	0 AS AllowAutoFields,
				Descr,
				DestinationGuid AS FileFormatGuid,
				FileFormatTypeID
		FROM	Cloud.FileFormats AS t
				INNER JOIN @Keys AS k
						ON t.FileFormatGuid = k.SourceGuid AND
							t.FileFormatID = k.SourceID AND
							k.SourceObject = 'FileFormats' AND
							k.SourceSchema = 'Cloud'
		ORDER BY FileFormatID;
					
		SET @CountRecords = ISNULL(@CountRecords, 0) + @@ROWCOUNT;							
							
		UPDATE	k
		SET		DestinationID = t.FileFormatID
		FROM	Cloud.FileFormats AS t
				INNER JOIN @Keys AS k
						ON t.FileFormatGuid = k.DestinationGuid AND
							k.SourceObject = 'FileFormats' AND
							k.SourceSchema = 'Cloud';
		
		SELECT TOP 1 @NewFileFormatID = DestinationID FROM @Keys WHERE SourceObject = 'FileFormats' AND SourceSchema = 'Cloud';
						
		--2b) Insert file objects...
		INSERT INTO Cloud.FileObjects
				(FileFormatID,
				FileObjectGuid,
				InSourceName,
				InSourceSchema,
				IsEnabled,
				MaxRecords,
				ObjectName,
				OutSourceName,
				OutSourceSchema)
		SELECT	F.DestinationID AS FileFormatID,
				k.DestinationGuid AS FileObjectGuid,
				InSourceName,
				InSourceSchema,
				IsEnabled,
				MaxRecords,
				ObjectName,
				OutSourceName,
				OutSourceSchema
		FROM	Cloud.FileObjects AS t
				INNER JOIN @Keys AS k
						ON t.FileObjectGuid = k.SourceGuid AND
							t.FileObjectID = k.SourceID AND
							k.SourceObject = 'FileObjects' AND
							k.SourceSchema = 'Cloud'
				INNER JOIN @Keys AS F
						ON t.FileFormatID = F.SourceID AND
							F.SourceObject = 'FileFormats' AND
							F.SourceSchema = 'Cloud'
		ORDER BY FileFormatID, OutSourceSchema, OutSourceName;

		SET @CountRecords = ISNULL(@CountRecords, 0) + @@ROWCOUNT;

		UPDATE	k
		SET		DestinationID = t.FileObjectID
		FROM	Cloud.FileObjects AS t
				INNER JOIN @Keys AS k
						ON t.FileObjectGuid = k.DestinationGuid AND
							k.SourceObject = 'FileObjects' AND
							k.SourceSchema = 'Cloud';
					
		--2c) Insert file fields...		
		INSERT INTO Cloud.FileFields 
				(FieldName,
				FileFieldGuid,
				FileObjectID,
				FileTranslatorID,
				IsShown,
				SourceColumn)
		SELECT	FieldName,
				k.DestinationGuid AS FileFieldGuid,
				F.DestinationID AS FileObjectID,
				FileTranslatorID,
				IsShown,
				SourceColumn
		FROM	Cloud.FileFields AS t
				INNER JOIN @Keys AS k
						ON t.FileFieldGuid = k.SourceGuid AND
							t.FileFieldID = k.SourceID AND
							k.SourceObject = 'FileFields' AND
							k.SourceSchema = 'Cloud'
				INNER JOIN @Keys AS F
						ON t.FileObjectID = F.SourceID AND
							F.SourceObject = 'FileObjects' AND
							F.SourceSchema = 'Cloud'
		ORDER BY FileObjectID, SourceColumn;
							
		SET @CountRecords = ISNULL(@CountRecords, 0) + @@ROWCOUNT;
		
		UPDATE	k
		SET		DestinationID = t.FileFieldID
		FROM	Cloud.FileFields AS t
				INNER JOIN @Keys AS k
						ON t.FileFieldGuid = k.DestinationGuid AND
							k.SourceObject = 'FileFields' AND
							k.SourceSchema = 'Cloud';
							
		--2d) Set AllowAutoFields = 1 for copied file formats, allowing for new file objects to auto-generate 
		--	  child file fields by inferting them from the underlying object's schema (implemented by trigger)
		UPDATE	t
		SET		AllowAutoFields = 1
		FROM	Cloud.FileFormats AS t
				INNER JOIN @Keys AS k
						ON t.FileFormatGuid = k.DestinationGuid AND
							k.SourceObject = 'FileFormats' AND
							k.SourceSchema = 'Cloud';		
		
		--2e) Insert file relationships...
		INSERT INTO Cloud.FileRelationships
				(ChildFieldID,
				ParentFieldID)
		SELECT	c.DestinationID AS ChildFieldID,
				p.DestinationID AS ParentFieldID
		FROM	Cloud.FileRelationships AS NFR
				INNER JOIN @Keys AS c
						ON NFR.ChildFieldID = c.SourceID AND
							c.SourceObject = 'FileFields' AND
							c.SourceSchema = 'Cloud'
				INNER JOIN @Keys AS p
						ON NFR.ParentFieldID = p.SourceID AND
							p.SourceObject = 'FileFields' AND
							p.SourceSchema = 'Cloud'

		COMMIT TRANSACTION TFileFormats; 
								
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
GRANT VIEW DEFINITION ON  [Cloud].[DuplicateFileFormat] TO [db_executer]
GO
GRANT EXECUTE ON  [Cloud].[DuplicateFileFormat] TO [db_executer]
GO
GRANT EXECUTE ON  [Cloud].[DuplicateFileFormat] TO [Processor]
GO
GRANT EXECUTE ON  [Cloud].[DuplicateFileFormat] TO [Submitter]
GO
