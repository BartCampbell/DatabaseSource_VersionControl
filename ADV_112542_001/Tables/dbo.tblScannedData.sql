CREATE TABLE [dbo].[tblScannedData]
(
[ScannedData_PK] [bigint] NOT NULL IDENTITY(1, 1),
[Suspect_PK] [bigint] NULL,
[DocumentType_PK] [tinyint] NULL,
[FileName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[User_PK] [smallint] NULL,
[dtInsert] [smalldatetime] NULL,
[is_deleted] [bit] NULL CONSTRAINT [DF__tblScanne__is_de__59E54FE7] DEFAULT ((0)),
[CodedStatus] [tinyint] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblScannedData] ADD CONSTRAINT [PK_tblScannedData] PRIMARY KEY CLUSTERED  ([ScannedData_PK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tblScannedData_Suspect] ON [dbo].[tblScannedData] ([Suspect_PK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
