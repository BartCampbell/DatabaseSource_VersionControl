CREATE TABLE [Ncqa].[PCR_ClinicalConditionWeights]
(
[BitProductLines] [bigint] NOT NULL,
[ClinCond] [smallint] NOT NULL,
[Descr] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[EvalTypeID] [tinyint] NOT NULL,
[FromAge] [tinyint] NOT NULL,
[MeasureSetID] [int] NOT NULL,
[ToAge] [tinyint] NOT NULL,
[Weight] [decimal] (18, 12) NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [Ncqa].[PCR_ClinicalConditionWeights] ADD CONSTRAINT [PK_Ncqa_PCR_ClinicalConditionWeights] PRIMARY KEY CLUSTERED  ([MeasureSetID], [EvalTypeID], [ClinCond], [BitProductLines], [FromAge], [ToAge]) ON [PRIMARY]
GO
