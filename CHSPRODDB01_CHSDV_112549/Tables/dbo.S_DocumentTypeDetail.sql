CREATE TABLE [dbo].[S_DocumentTypeDetail]
(
[S_DocumentTypeDetail_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LoadDate] [datetime] NULL,
[H_DocumentType_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DocumentType] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastUpdated] [smalldatetime] NULL,
[HashDiff] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordEndDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[S_DocumentTypeDetail] ADD CONSTRAINT [PK_S_DocumentTypeDetail] PRIMARY KEY CLUSTERED  ([S_DocumentTypeDetail_RK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[S_DocumentTypeDetail] ADD CONSTRAINT [FK_H_DocumentType_RK] FOREIGN KEY ([H_DocumentType_RK]) REFERENCES [dbo].[H_DocumentType] ([H_DocumentType_RK]) ON DELETE CASCADE ON UPDATE CASCADE
GO
