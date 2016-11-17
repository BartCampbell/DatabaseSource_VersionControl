CREATE TABLE [dbo].[LS_ScannedDataDocumentType]
(
[LS_ScannedDataDocumentType_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LoadDate] [datetime] NULL,
[L_ScannedDataDocumentType_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[H_ScannedData_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[H_DocumentType_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Active] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HashDiff] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordEndDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LS_ScannedDataDocumentType] ADD CONSTRAINT [PK_LS_ScannedDataDocumentType] PRIMARY KEY CLUSTERED  ([LS_ScannedDataDocumentType_RK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [NonClusteredIndex-20161004-143501] ON [dbo].[LS_ScannedDataDocumentType] ([HashDiff]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LS_ScannedDataDocumentType] ADD CONSTRAINT [FK_L_ScannedDataDocumentType_RK1] FOREIGN KEY ([L_ScannedDataDocumentType_RK]) REFERENCES [dbo].[L_ScannedDataDocumentType] ([L_ScannedDataDocumentType_RK]) ON DELETE CASCADE ON UPDATE CASCADE
GO
