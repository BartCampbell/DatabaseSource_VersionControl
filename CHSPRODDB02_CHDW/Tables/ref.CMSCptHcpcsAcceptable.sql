CREATE TABLE [ref].[CMSCptHcpcsAcceptable]
(
[CptHcpcsCode] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CptHcpcsDesc] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Included] [bit] NULL,
[CMSCptHcpcsAcceptableID] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [ref].[CMSCptHcpcsAcceptable] ADD CONSTRAINT [PK_CMSCptHcpcsAcceptable] PRIMARY KEY CLUSTERED  ([CMSCptHcpcsAcceptableID]) ON [PRIMARY]
GO
