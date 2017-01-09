CREATE TABLE [dbo].[tblScannedDataInvoice]
(
[ScannedDataInvoice_PK] [bigint] NOT NULL IDENTITY(1, 1),
[ProviderOfficeInvoice_PK] [bigint] NULL,
[FileName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[User_PK] [smallint] NULL,
[dtInsert] [smalldatetime] NULL,
[is_deleted] [bit] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblScannedDataInvoice] ADD CONSTRAINT [PK_tblScannedDataInvoice] PRIMARY KEY CLUSTERED  ([ScannedDataInvoice_PK]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
