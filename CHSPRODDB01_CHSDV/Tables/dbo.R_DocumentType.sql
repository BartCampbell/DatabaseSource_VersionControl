CREATE TABLE [dbo].[R_DocumentType]
(
[CentauriDocumentTypeID] [int] NOT NULL IDENTITY(101, 1),
[ClientID] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClientDocumentTypeID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [date] NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DocumentTypeHashKey] AS (upper(CONVERT([char](32),hashbytes('MD5',upper(rtrim(ltrim(coalesce([CentauriDocumentTypeID],''))))),(2))))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[R_DocumentType] ADD CONSTRAINT [PK_R_DocumentType] PRIMARY KEY CLUSTERED  ([CentauriDocumentTypeID]) ON [PRIMARY]
GO
