CREATE TABLE [Ncqa].[PCR_ProductLineWeights_v1]
(
[BaseWeight] [decimal] (18, 12) NOT NULL,
[FromAge] [tinyint] NOT NULL CONSTRAINT [DF_PCR_ProductLineWeights_FromAge] DEFAULT ((0)),
[MeasureSetID] [int] NOT NULL,
[ProductLineID] [smallint] NOT NULL,
[SurgeryWeight] [decimal] (18, 12) NOT NULL,
[ToAge] [tinyint] NOT NULL CONSTRAINT [DF_PCR_ProductLineWeights_ToAge] DEFAULT ((255))
) ON [PRIMARY]
GO
ALTER TABLE [Ncqa].[PCR_ProductLineWeights_v1] ADD CONSTRAINT [PK_PCR_ProductLineWeights] PRIMARY KEY CLUSTERED  ([MeasureSetID], [ProductLineID], [FromAge], [ToAge]) ON [PRIMARY]
GO
