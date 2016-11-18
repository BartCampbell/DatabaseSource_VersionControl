CREATE TABLE [dim].[DocumentType]
(
[DocumentTypeID] [int] NOT NULL IDENTITY(1, 1),
[CentauriDocumentTypeID] [int] NULL,
[DocumentType] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastUpdated] [smalldatetime] NULL,
[CreateDate] [datetime] NULL CONSTRAINT [DF_DocumentType_CreateDate] DEFAULT (getdate()),
[LastUpdate] [datetime] NULL CONSTRAINT [DF_DocumentType_LastUpdate] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dim].[DocumentType] ADD CONSTRAINT [PK_DocumentType] PRIMARY KEY CLUSTERED  ([DocumentTypeID]) ON [PRIMARY]
GO
