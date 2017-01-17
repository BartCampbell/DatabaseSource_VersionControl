CREATE TABLE [dbo].[H_DocumentType]
(
[H_DocumentType_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DocumentType_BK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClientDocumentTypeID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL CONSTRAINT [DF__H_Documen__LoadD__28ED12D1] DEFAULT (getdate()),
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[H_DocumentType] ADD CONSTRAINT [PK_H_DocumentType] PRIMARY KEY CLUSTERED  ([H_DocumentType_RK]) ON [PRIMARY]
GO
