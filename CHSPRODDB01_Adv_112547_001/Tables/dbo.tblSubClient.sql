CREATE TABLE [dbo].[tblSubClient]
(
[SubClient_PK] [smallint] NOT NULL IDENTITY(1, 1),
[Client_PK] [smallint] NOT NULL,
[SubClient_Name] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblSubClient] ADD CONSTRAINT [PK_tblSubClient] PRIMARY KEY CLUSTERED  ([SubClient_PK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tblSubClient] ON [dbo].[tblSubClient] ([Client_PK]) ON [PRIMARY]
GO
