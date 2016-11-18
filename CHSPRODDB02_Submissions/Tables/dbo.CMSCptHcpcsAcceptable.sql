CREATE TABLE [dbo].[CMSCptHcpcsAcceptable]
(
[CptHcpcsCode] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CptHcpcsDesc] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Included] [bit] NULL,
[CMSCptHcpcsAcceptableID] [int] NOT NULL IDENTITY(1, 1)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CMSCptHcpcsAcceptable] ADD CONSTRAINT [PK_CMSCptHcpcsAcceptable] PRIMARY KEY CLUSTERED  ([CMSCptHcpcsAcceptableID]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
