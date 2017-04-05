CREATE TABLE [Ncqa].[PCR_ProductLineWeights]
(
[BaseWeight] [decimal] (18, 12) NOT NULL,
[BitProductLines] [bigint] NOT NULL,
[EvalTypeID] [tinyint] NOT NULL,
[FromAge] [tinyint] NOT NULL,
[MeasureSetID] [int] NOT NULL,
[SurgeryWeight] [decimal] (18, 12) NOT NULL,
[ToAge] [tinyint] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [Ncqa].[PCR_ProductLineWeights] ADD CONSTRAINT [PK_Ncqa_PCR_ProductLineWeights] PRIMARY KEY CLUSTERED  ([MeasureSetID], [EvalTypeID], [BitProductLines], [FromAge], [ToAge]) ON [PRIMARY]
GO
