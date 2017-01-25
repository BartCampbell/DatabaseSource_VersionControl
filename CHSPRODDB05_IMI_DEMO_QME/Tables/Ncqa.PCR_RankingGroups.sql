CREATE TABLE [Ncqa].[PCR_RankingGroups]
(
[Descr] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MeasureSetID] [int] NOT NULL,
[RankGrpID] [smallint] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [Ncqa].[PCR_RankingGroups] ADD CONSTRAINT [PK_PCR_RankingGroups] PRIMARY KEY CLUSTERED  ([MeasureSetID], [RankGrpID]) ON [PRIMARY]
GO
