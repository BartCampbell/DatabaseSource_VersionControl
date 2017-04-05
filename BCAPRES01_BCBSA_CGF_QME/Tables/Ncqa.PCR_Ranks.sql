CREATE TABLE [Ncqa].[PCR_Ranks]
(
[ClinCond] [smallint] NULL,
[Descr] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[HClinCond] [smallint] NOT NULL,
[MeasureSetID] [int] NOT NULL,
[RankGrpID] [smallint] NOT NULL,
[RankID] [int] NOT NULL IDENTITY(1, 1),
[RankOrder] [nchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [Ncqa].[PCR_Ranks] ADD CONSTRAINT [PK_PCR_Ranks] PRIMARY KEY CLUSTERED  ([RankID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_PCR_Ranks] ON [Ncqa].[PCR_Ranks] ([MeasureSetID], [ClinCond], [RankGrpID]) INCLUDE ([HClinCond], [RankOrder]) ON [PRIMARY]
GO
