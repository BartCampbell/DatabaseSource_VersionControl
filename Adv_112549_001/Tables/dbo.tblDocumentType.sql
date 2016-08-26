CREATE TABLE [dbo].[tblDocumentType]
(
[DocumentType_PK] [tinyint] NOT NULL,
[DocumentType] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastUpdated] [smalldatetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblDocumentType] ADD CONSTRAINT [PK_tblDocumentType] PRIMARY KEY CLUSTERED  ([DocumentType_PK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
