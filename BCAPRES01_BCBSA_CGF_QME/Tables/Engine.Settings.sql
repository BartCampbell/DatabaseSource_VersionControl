CREATE TABLE [Engine].[Settings]
(
[EngineGuid] [uniqueidentifier] NOT NULL CONSTRAINT [DF_EngineSettings_EngineGuid] DEFAULT (newid()),
[EngineID] [tinyint] NOT NULL CONSTRAINT [DF_EngineSettings_EngineID] DEFAULT ((1)),
[EngineTypeID] [tinyint] NOT NULL,
[LastResetDate] [datetime] NULL,
[NoActivityTimeout] [int] NOT NULL CONSTRAINT [DF_Settings_NoActivityTimeout] DEFAULT ((1800)),
[SaveBatchData] [bit] NOT NULL CONSTRAINT [DF_Settings_SaveBatchData] DEFAULT ((0)),
[SourceDatabase] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TuneInterval] [int] NOT NULL CONSTRAINT [DF_Settings_TuneInterval] DEFAULT ((60)*(15))
) ON [PRIMARY]
GO
ALTER TABLE [Engine].[Settings] ADD CONSTRAINT [CK_EngineSettings_EngineID] CHECK (([EngineID]=(1)))
GO
ALTER TABLE [Engine].[Settings] ADD CONSTRAINT [PK_EngineSettings] PRIMARY KEY CLUSTERED  ([EngineID]) ON [PRIMARY]
GO
ALTER TABLE [Engine].[Settings] ADD CONSTRAINT [FK_EngineSettings_EngineTypes] FOREIGN KEY ([EngineTypeID]) REFERENCES [Engine].[Types] ([EngineTypeID])
GO
EXEC sp_addextendedproperty N'MS_Description', N'Only one row allowed in this table', 'SCHEMA', N'Engine', 'TABLE', N'Settings', 'CONSTRAINT', N'CK_EngineSettings_EngineID'
GO
