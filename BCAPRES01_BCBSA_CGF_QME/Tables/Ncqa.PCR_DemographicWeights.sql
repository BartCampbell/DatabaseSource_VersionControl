CREATE TABLE [Ncqa].[PCR_DemographicWeights]
(
[BitProductLines] [bigint] NOT NULL,
[EvalTypeID] [tinyint] NOT NULL,
[FromAge] [tinyint] NOT NULL,
[Gender] [tinyint] NOT NULL,
[MeasureSetID] [smallint] NOT NULL,
[ToAge] [tinyint] NOT NULL,
[Weight] [decimal] (18, 12) NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [Ncqa].[PCR_DemographicWeights] ADD CONSTRAINT [PK_Ncqa_PCR_DemographicWeights] PRIMARY KEY CLUSTERED  ([MeasureSetID], [EvalTypeID], [BitProductLines], [FromAge], [ToAge], [Gender]) ON [PRIMARY]
GO
