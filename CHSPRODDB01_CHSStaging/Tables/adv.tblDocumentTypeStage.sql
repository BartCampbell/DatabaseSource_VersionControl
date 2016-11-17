CREATE TABLE [adv].[tblDocumentTypeStage]
(
[DocumentType_PK] [tinyint] NOT NULL,
[DocumentType] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastUpdated] [smalldatetime] NULL,
[Client] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordSource] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL,
[CCI] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DocumentTypeHashKey] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClientHashKey] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CDI] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [adv].[tblDocumentTypeStage] ADD CONSTRAINT [PK_tblDocumentType] PRIMARY KEY CLUSTERED  ([DocumentType_PK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
