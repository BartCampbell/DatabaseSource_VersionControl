CREATE TABLE [dbo].[Measure]
(
[MeasureID] [int] NOT NULL,
[HEDISMeasure] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[HEDISMeasureDescription] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Parameters] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Form] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ScoringProcedure] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ReadOnly] [bit] NULL CONSTRAINT [DF_Measure_ReadOnly] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Measure] ADD CONSTRAINT [PK_Measure] PRIMARY KEY CLUSTERED  ([MeasureID]) ON [PRIMARY]
GO
