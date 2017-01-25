CREATE TABLE [Ncqa].[MRR_MeasureGroups]
(
[Descr] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MeasureGroup] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MeasureGroupType] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [Ncqa].[MRR_MeasureGroups] ADD CONSTRAINT [PK_MRR_MeasureGroups] PRIMARY KEY CLUSTERED  ([MeasureGroup]) ON [PRIMARY]
GO
