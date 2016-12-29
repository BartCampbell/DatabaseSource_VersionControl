CREATE TABLE [dbo].[tblClient]
(
[Client_PK] [smallint] NOT NULL IDENTITY(1, 1),
[Client_Name] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblClient] ADD CONSTRAINT [PK_tblClient] PRIMARY KEY CLUSTERED  ([Client_PK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
