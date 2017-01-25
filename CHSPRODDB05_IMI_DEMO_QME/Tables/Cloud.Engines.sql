CREATE TABLE [Cloud].[Engines]
(
[CountActivity] [int] NOT NULL CONSTRAINT [DF_Engines_CountActivity] DEFAULT ((0)),
[CreatedDate] [datetime] NOT NULL CONSTRAINT [DF_Engines_CreatedDate] DEFAULT (getdate()),
[EngineGuid] [uniqueidentifier] NOT NULL,
[EngineID] [int] NOT NULL IDENTITY(1, 1),
[EngineTypeID] [tinyint] NOT NULL,
[ExpiredDate] [datetime] NULL,
[Host] [nvarchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Info] [xml] NULL,
[IsExpired] [bit] NOT NULL CONSTRAINT [DF_EngineRegistry_IsExpired] DEFAULT ((0)),
[IPAddress] [nvarchar] (48) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastActivityDate] [datetime] NOT NULL CONSTRAINT [DF_EngineRegistry_LastActivityDate] DEFAULT (getdate()),
[MachineName] AS ([Cloud].[GetEngineInfoMachineName]([info])) PERSISTED,
[SqlDatabaseName] AS ([Cloud].[GetEngineInfoSqlDatabaseName]([info])) PERSISTED,
[SqlServerName] AS ([Cloud].[GetEngineInfoSqlServerName]([info])) PERSISTED
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Cloud].[Engines] ADD CONSTRAINT [PK_Engines] PRIMARY KEY CLUSTERED  ([EngineID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Engines_EngineGuid] ON [Cloud].[Engines] ([EngineGuid]) ON [PRIMARY]
GO
EXEC sp_addextendedproperty N'MS_Description', N'', 'SCHEMA', N'Cloud', 'TABLE', N'Engines', 'COLUMN', N'SqlDatabaseName'
GO
