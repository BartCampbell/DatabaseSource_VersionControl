CREATE TABLE [dbo].[Revision]
(
[Id] [int] NOT NULL IDENTITY(0, 1),
[SchemaName] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Comments] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[RevisionDate] [datetime] NOT NULL,
[RevisedBy] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[Revision] ADD CONSTRAINT [PK_Revision_dbo] PRIMARY KEY CLUSTERED  ([Id]) ON [PRIMARY]
GO
