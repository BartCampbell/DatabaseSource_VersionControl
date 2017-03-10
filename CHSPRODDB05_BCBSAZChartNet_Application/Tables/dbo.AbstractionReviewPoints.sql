CREATE TABLE [dbo].[AbstractionReviewPoints]
(
[MeasureComponentID] [int] NOT NULL,
[ReviewPointsAvailable] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[AbstractionReviewPoints] ADD CONSTRAINT [PK_AbstractionReviewPoints] PRIMARY KEY CLUSTERED  ([MeasureComponentID]) ON [PRIMARY]
GO
