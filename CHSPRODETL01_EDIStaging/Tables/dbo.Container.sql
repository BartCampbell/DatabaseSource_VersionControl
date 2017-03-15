CREATE TABLE [dbo].[Container]
(
[Id] [int] NOT NULL IDENTITY(1, 1),
[SchemaName] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Type] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Container] ADD CONSTRAINT [PK_Container_dbo] PRIMARY KEY CLUSTERED  ([Id]) ON [PRIMARY]
GO
