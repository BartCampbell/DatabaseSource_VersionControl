CREATE TABLE [Ncqa].[RRU_LosGroups]
(
[Abbrev] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FromDays] [smallint] NOT NULL,
[LosGroupGuid] [uniqueidentifier] NOT NULL CONSTRAINT [DF_RRU_LosGroups_LosGroupGuid] DEFAULT (newid()),
[LosGroupID] [tinyint] NOT NULL,
[ToDays] [smallint] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [Ncqa].[RRU_LosGroups] ADD CONSTRAINT [PK_Ncqa_RRU_LosGroups] PRIMARY KEY CLUSTERED  ([LosGroupID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Ncqa_RRU_LosGroups_Abbrev] ON [Ncqa].[RRU_LosGroups] ([Abbrev]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Ncqa_RRU_LosGroups_Days] ON [Ncqa].[RRU_LosGroups] ([FromDays], [ToDays]) INCLUDE ([Abbrev], [LosGroupID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Ncqa_RRU_LosGroups_LosGroupGuid] ON [Ncqa].[RRU_LosGroups] ([LosGroupGuid]) ON [PRIMARY]
GO
