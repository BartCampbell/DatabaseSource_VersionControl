CREATE TABLE [dbo].[MeasureComponentEvidence]
(
[MeasureEvidenceID] [int] NOT NULL IDENTITY(1, 1),
[MeasureComponentID] [int] NOT NULL,
[ListKey] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DisplayText] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SortOrder] [int] NOT NULL CONSTRAINT [DF_MeasureComponentEvidence_SortOrder] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MeasureComponentEvidence] ADD CONSTRAINT [PK_MeasureComponentEvidence] PRIMARY KEY CLUSTERED  ([MeasureEvidenceID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MeasureComponentEvidence] WITH NOCHECK ADD CONSTRAINT [FK_MeasureComponentEvidence_MeasureComponent] FOREIGN KEY ([MeasureComponentID]) REFERENCES [dbo].[MeasureComponent] ([MeasureComponentID])
GO
