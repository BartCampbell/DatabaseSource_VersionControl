CREATE TABLE [dbo].[AbstractionReview]
(
[AbstractionReviewID] [int] NOT NULL IDENTITY(1, 1),
[PursuitEventID] [int] NOT NULL,
[ReviewerID] [int] NULL,
[ReviewDate] [datetime] NOT NULL,
[ReviewPointsAvailable] [int] NOT NULL,
[MeasureComponentID] [int] NOT NULL,
[AbstractionReviewStatusID] [int] NOT NULL CONSTRAINT [DF_AbstractionReview_AbstractionReviewStatusID] DEFAULT ((1)),
[AbstractionReviewSetConfigID] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[AbstractionReview] ADD CONSTRAINT [PK_AbstractionReview] PRIMARY KEY CLUSTERED  ([AbstractionReviewID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[AbstractionReview] ADD CONSTRAINT [FK_AbstractionReview_AbstractionReviewSetConfiguration] FOREIGN KEY ([AbstractionReviewSetConfigID]) REFERENCES [dbo].[AbstractionReviewSetConfiguration] ([AbstractionReviewSetConfigID])
GO
ALTER TABLE [dbo].[AbstractionReview] ADD CONSTRAINT [FK_AbstractionReview_AbstractionReviewStatus] FOREIGN KEY ([AbstractionReviewStatusID]) REFERENCES [dbo].[AbstractionReviewStatus] ([AbstractionReviewStatusID])
GO
ALTER TABLE [dbo].[AbstractionReview] WITH NOCHECK ADD CONSTRAINT [FK_AbstractionReview_MeasureComponent] FOREIGN KEY ([MeasureComponentID]) REFERENCES [dbo].[MeasureComponent] ([MeasureComponentID])
GO
ALTER TABLE [dbo].[AbstractionReview] ADD CONSTRAINT [FK_AbstractionReview_PursuitEvent] FOREIGN KEY ([PursuitEventID]) REFERENCES [dbo].[PursuitEvent] ([PursuitEventID])
GO
ALTER TABLE [dbo].[AbstractionReview] ADD CONSTRAINT [FK_AbstractionReview_Reviewer] FOREIGN KEY ([ReviewerID]) REFERENCES [dbo].[Reviewer] ([ReviewerID])
GO
