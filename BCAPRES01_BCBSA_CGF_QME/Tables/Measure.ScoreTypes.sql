CREATE TABLE [Measure].[ScoreTypes]
(
[Abbrev] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Descr] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ScoreTypeGuid] [uniqueidentifier] NOT NULL CONSTRAINT [DF_ScoreTypes_ScoreTypeGuid] DEFAULT (newid()),
[ScoreTypeID] [tinyint] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [Measure].[ScoreTypes] ADD CONSTRAINT [PK_ScoreTypes] PRIMARY KEY CLUSTERED  ([ScoreTypeID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_ScoreTypes_Abbrev] ON [Measure].[ScoreTypes] ([Abbrev]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_ScoreTypes_ScoreTypeGuid] ON [Measure].[ScoreTypes] ([ScoreTypeGuid]) ON [PRIMARY]
GO
