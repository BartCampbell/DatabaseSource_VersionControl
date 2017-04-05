CREATE TABLE [Cloud].[FileObjects]
(
[CreatedBy] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_FileObjects_CreatedBy] DEFAULT (suser_sname()),
[CreatedDate] [datetime] NOT NULL CONSTRAINT [DF_FileObjects_CreatedDate] DEFAULT (getdate()),
[CreatedSpId] [int] NOT NULL CONSTRAINT [DF_FileObjects_CreatedSpId] DEFAULT (@@spid),
[FileFormatID] [int] NOT NULL,
[FileObjectGuid] [uniqueidentifier] NOT NULL CONSTRAINT [DF_FileObjects_FileObjectGuid] DEFAULT (newid()),
[FileObjectID] [int] NOT NULL IDENTITY(1, 1),
[info] [varchar] (512) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[InSourceName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[InSourceSchema] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsEnabled] [bit] NOT NULL CONSTRAINT [DF_FileObjects_IsEnabled] DEFAULT ((1)),
[MaxRecords] [int] NULL,
[ObjectName] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[OutSourceName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[OutSourceSchema] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Kriz, Mike
-- Create date: 5/9/2012
-- Description:	Adds the child fields associated with the new file object(s) to the FileFields table.
-- =============================================
CREATE TRIGGER [Cloud].[FileObjects_AddChildFields_I]
   ON [Cloud].[FileObjects]
   AFTER INSERT
AS 
BEGIN

	SET NOCOUNT ON;
	
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
	)
	INSERT INTO Cloud.FileFields
	        (FieldName,
			FileObjectID,
			FileTranslatorID,
			IsShown,
			SourceColumn)
    SELECT	LOWER(C.COLUMN_NAME) AS FieldName,
			NFO.FileObjectID,
			DT.FileTranslatorID,
			CASE WHEN DNSF.ColumnName IS NOT NULL THEN 0 ELSE 1 END AS IsShown,
			C.COLUMN_NAME AS SourceColumn
    FROM	Cloud.FileObjects AS NFO
			INNER JOIN INFORMATION_SCHEMA.COLUMNS AS C
					ON NFO.OutSourceName = C.TABLE_NAME AND
						NFO.OutSourceSchema = C.TABLE_SCHEMA
			LEFT OUTER JOIN DefaultNotShownFields AS DNSF
					ON C.COLUMN_NAME = DNSF.ColumnName 
			LEFT OUTER JOIN DefaultTranslators AS DT
					ON C.COLUMN_NAME = DT.ColumnName
	WHERE	(NFO.FileFormatID IN 
								(
									SELECT	FileFormatID 
									FROM	Cloud.FileFormats 
									WHERE	AllowAutoFields = 1
								)) AND
			(NFO.FileObjectID NOT IN
								(
									SELECT DISTINCT
											FileObjectID 
									FROM	Cloud.FileFields
								))
	ORDER BY C.COLUMN_NAME;

END
GO
ALTER TABLE [Cloud].[FileObjects] ADD CONSTRAINT [PK_FileObjects] PRIMARY KEY CLUSTERED  ([FileObjectID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_FileObjects_FileObjectGuid] ON [Cloud].[FileObjects] ([FileObjectGuid]) ON [PRIMARY]
GO
