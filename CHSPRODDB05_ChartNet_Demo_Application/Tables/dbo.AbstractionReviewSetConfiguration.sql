CREATE TABLE [dbo].[AbstractionReviewSetConfiguration]
(
[AbstractionReviewSetConfigID] [int] NOT NULL IDENTITY(1, 1),
[AbstractionReviewSetID] [int] NOT NULL,
[ProductLine] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Product] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MeasureComponentID] [int] NOT NULL,
[AbstractorID] [int] NOT NULL,
[SelectionPercentage] [decimal] (8, 6) NOT NULL,
[PursuitEventsAvailable] [int] NOT NULL CONSTRAINT [DF_AbstractionReviewSetConfiguration_PursuitsAvailable] DEFAULT ((0)),
[PursuitEventsSelected] [int] NOT NULL CONSTRAINT [DF_AbstractionReviewSetConfiguration_PursuitsSelected] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[AbstractionReviewSetConfiguration] ADD CONSTRAINT [PK_AbstractionReviewSetConfiguration] PRIMARY KEY CLUSTERED  ([AbstractionReviewSetConfigID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[AbstractionReviewSetConfiguration] ADD CONSTRAINT [FK_AbstractionReviewSetConfiguration_AbstractionReviewSet] FOREIGN KEY ([AbstractionReviewSetID]) REFERENCES [dbo].[AbstractionReviewSet] ([AbstractionReviewSetID])
GO
ALTER TABLE [dbo].[AbstractionReviewSetConfiguration] ADD CONSTRAINT [FK_AbstractionReviewSetConfiguration_Abstractor] FOREIGN KEY ([AbstractorID]) REFERENCES [dbo].[Abstractor] ([AbstractorID])
GO
ALTER TABLE [dbo].[AbstractionReviewSetConfiguration] WITH NOCHECK ADD CONSTRAINT [FK_AbstractionReviewSetConfiguration_MeasureComponent] FOREIGN KEY ([MeasureComponentID]) REFERENCES [dbo].[MeasureComponent] ([MeasureComponentID])
GO
