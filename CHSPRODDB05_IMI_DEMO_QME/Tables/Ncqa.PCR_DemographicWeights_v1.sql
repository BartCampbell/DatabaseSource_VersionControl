CREATE TABLE [Ncqa].[PCR_DemographicWeights_v1]
(
[FromAge] [tinyint] NOT NULL,
[Gender] [tinyint] NOT NULL,
[MeasureSetID] [smallint] NOT NULL,
[ProductLineID] [smallint] NOT NULL,
[ToAge] [tinyint] NOT NULL,
[Weight] [decimal] (18, 12) NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [Ncqa].[PCR_DemographicWeights_v1] ADD CONSTRAINT [PK_PCR_DemographicWeights] PRIMARY KEY CLUSTERED  ([MeasureSetID], [ProductLineID], [FromAge], [ToAge], [Gender]) ON [PRIMARY]
GO
