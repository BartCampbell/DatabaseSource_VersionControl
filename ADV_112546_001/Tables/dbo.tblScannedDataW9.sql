CREATE TABLE [dbo].[tblScannedDataW9]
(
[ScannedDataW9_PK] [bigint] NOT NULL IDENTITY(1, 1),
[ProviderOffice_PK] [bigint] NULL,
[FileName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[User_PK] [smallint] NULL,
[dtInsert] [smalldatetime] NULL,
[is_deleted] [bit] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblScannedDataW9] ADD CONSTRAINT [PK_tblScannedDataW9] PRIMARY KEY CLUSTERED  ([ScannedDataW9_PK]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
