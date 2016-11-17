CREATE TABLE [dbo].[L_ScannedDataDocumentType]
(
[L_ScannedDataDocumentType_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[H_ScannedData_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[H_DocumentType_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordEndDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[L_ScannedDataDocumentType] ADD CONSTRAINT [PK_L_ScannedDataDocumentType] PRIMARY KEY CLUSTERED  ([L_ScannedDataDocumentType_RK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[L_ScannedDataDocumentType] ADD CONSTRAINT [FK_H_DocumentType_RK3] FOREIGN KEY ([H_DocumentType_RK]) REFERENCES [dbo].[H_DocumentType] ([H_DocumentType_RK]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[L_ScannedDataDocumentType] ADD CONSTRAINT [FK_H_ScannedData_RK6] FOREIGN KEY ([H_ScannedData_RK]) REFERENCES [dbo].[H_ScannedData] ([H_ScannedData_RK]) ON DELETE CASCADE ON UPDATE CASCADE
GO
