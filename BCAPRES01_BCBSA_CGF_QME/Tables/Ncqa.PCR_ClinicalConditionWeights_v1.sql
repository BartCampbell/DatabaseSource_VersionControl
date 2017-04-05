CREATE TABLE [Ncqa].[PCR_ClinicalConditionWeights_v1]
(
[ClinCond] [smallint] NOT NULL,
[Descr] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[EvalTypeID] [tinyint] NOT NULL,
[FromAge] [tinyint] NOT NULL CONSTRAINT [DF_PCR_ClinicalConditionWeights_FromAge] DEFAULT ((0)),
[MeasureSetID] [int] NOT NULL,
[ProductLineID] [smallint] NOT NULL,
[ToAge] [tinyint] NOT NULL CONSTRAINT [DF_PCR_ClinicalConditionWeights_ToAge] DEFAULT ((255)),
[Weight] [decimal] (18, 12) NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [Ncqa].[PCR_ClinicalConditionWeights_v1] ADD CONSTRAINT [PK_PCR_ClinicalConditionWeights] PRIMARY KEY CLUSTERED  ([MeasureSetID], [EvalTypeID], [ClinCond], [ProductLineID], [FromAge], [ToAge]) ON [PRIMARY]
GO
