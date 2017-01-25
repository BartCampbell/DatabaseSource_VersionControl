CREATE TABLE [dbo].[MasterForeignKeyLinks]
(
[ChildColumn] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[IsEnabled] [bit] NOT NULL CONSTRAINT [DF_MasterForeignKeyLinks_IsEnabled] DEFAULT ((1)),
[KeyName] AS ((((('FK_'+[SourceSchema])+'_')+[SourceTable])+'_')+[ChildColumn]),
[MasterForeignKeyID] [smallint] NOT NULL,
[MasterForeignKeyLinkGuid] [uniqueidentifier] NOT NULL CONSTRAINT [DF_MasterForeignKeyLinks_MasterForeignKeyLinkGuid] DEFAULT (newid()),
[MasterForeignKeyLinkID] [int] NOT NULL IDENTITY(1, 1),
[SourceSchema] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SourceTable] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MasterForeignKeyLinks] ADD CONSTRAINT [PK_MasterForeignKeyLinks] PRIMARY KEY CLUSTERED  ([MasterForeignKeyLinkID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MasterForeignKeyLinks] ADD CONSTRAINT [IX_MasterForeignKeyLinks] UNIQUE NONCLUSTERED  ([KeyName]) ON [PRIMARY]
GO
