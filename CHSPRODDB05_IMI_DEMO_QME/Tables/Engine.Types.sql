CREATE TABLE [Engine].[Types]
(
[AllowClaimUpdates] [bit] NOT NULL CONSTRAINT [DF_EngineTypes_AllowClaimUpdates] DEFAULT ((0)),
[AllowExpire] [bit] NOT NULL CONSTRAINT [DF_Types_AllowExpire] DEFAULT ((0)),
[AllowFinalizePurgeInternal] [bit] NOT NULL CONSTRAINT [DF_EngineTypes_AllowFinalizePurge] DEFAULT ((1)),
[AllowFinalizePurgeLog] [bit] NOT NULL CONSTRAINT [DF_EngineTypes_AllowFinalizePurgeLog] DEFAULT ((0)),
[AllowFinalizePurgeResult] [bit] NOT NULL CONSTRAINT [DF_Types_AllowFinalizePurgeResult] DEFAULT ((0)),
[AllowTruncate] [bit] NOT NULL CONSTRAINT [DF_EngineTypes_AllowTruncate] DEFAULT ((0)),
[Descr] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[EngineTypeGuid] [uniqueidentifier] NOT NULL CONSTRAINT [DF_EngineTypes_EngineTypeGuid] DEFAULT (newid()),
[EngineTypeID] [tinyint] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [Engine].[Types] ADD CONSTRAINT [PK_EngineTypes] PRIMARY KEY CLUSTERED  ([EngineTypeID]) ON [PRIMARY]
GO
