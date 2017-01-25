CREATE TABLE [Ncqa].[RRU_DemographicWeights]
(
[FromAge] [tinyint] NOT NULL CONSTRAINT [DF__RRU_Demog__FromA__77600AA8] DEFAULT ((0)),
[Gender] [tinyint] NOT NULL,
[MeasureSetID] [smallint] NOT NULL,
[ToAge] [tinyint] NOT NULL CONSTRAINT [DF__RRU_Demog__ToAge__78542EE1] DEFAULT ((255)),
[Weight] [decimal] (18, 12) NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [Ncqa].[RRU_DemographicWeights] ADD CONSTRAINT [PK_Ncqa_RRU_DemographicWeights] PRIMARY KEY CLUSTERED  ([MeasureSetID], [FromAge], [ToAge], [Gender]) ON [PRIMARY]
GO
