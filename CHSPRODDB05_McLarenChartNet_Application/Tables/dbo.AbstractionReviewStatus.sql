CREATE TABLE [dbo].[AbstractionReviewStatus]
(
[AbstractionReviewStatusID] [int] NOT NULL,
[Description] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[IsCanceled] [bit] NOT NULL CONSTRAINT [DF_AbstractionReviewStatus_IsCanceled] DEFAULT ((0)),
[IsCompleted] [bit] NOT NULL CONSTRAINT [DF_AbstractionReviewStatus_IsCompleted] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[AbstractionReviewStatus] ADD CONSTRAINT [PK_AbstractionReviewStatus] PRIMARY KEY CLUSTERED  ([AbstractionReviewStatusID]) ON [PRIMARY]
GO
