CREATE TABLE [Measure].[EventOptions]
(
[Allow] [bit] NOT NULL CONSTRAINT [DF_EventOptions_Allow] DEFAULT ((1)),
[EventCritID] [int] NOT NULL,
[EventID] [int] NOT NULL,
[EventOptGuid] [uniqueidentifier] NOT NULL CONSTRAINT [DF_EventOptions_EventOptGuid] DEFAULT (newid()),
[EventOptID] [int] NOT NULL IDENTITY(1, 1),
[IsEnabled] [bit] NOT NULL CONSTRAINT [DF_EventOptions_IsEnabled] DEFAULT ((1)),
[OptionNbr] [tinyint] NOT NULL,
[RankOrder] [smallint] NULL,
[Require1stRank] [bit] NOT NULL CONSTRAINT [DF_EventOptions_RequireTopRank] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [Measure].[EventOptions] ADD CONSTRAINT [CK_EventOptions_Require1stRank] CHECK ((([Measure].[GetEventOptionRequire1stRankCount]([EventID],[OptionNbr],[EventOptID])<=(0) AND [Require1stRank]=(1) AND [Allow]=(1)) OR [Require1stRank]=(0)))
GO
ALTER TABLE [Measure].[EventOptions] ADD CONSTRAINT [PK_EventOptions] PRIMARY KEY CLUSTERED  ([EventOptID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_EventOptions_EventCritID] ON [Measure].[EventOptions] ([EventCritID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_EventOptions] ON [Measure].[EventOptions] ([EventCritID], [EventID], [OptionNbr]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_EventOptions_EventID] ON [Measure].[EventOptions] ([EventID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_EventOptions_EventOptGuid] ON [Measure].[EventOptions] ([EventOptGuid]) ON [PRIMARY]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Only one Criteria record per Event Option is may require to be the 1st ranked Criteria.', 'SCHEMA', N'Measure', 'TABLE', N'EventOptions', 'CONSTRAINT', N'CK_EventOptions_Require1stRank'
GO
