CREATE TABLE [dbo].[AbstractionReviewDetail]
(
[AbstractionReviewDetailID] [int] NOT NULL IDENTITY(1, 1),
[AbstractionReviewID] [int] NOT NULL,
[Field] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[IsCritical] [bit] NOT NULL,
[Description] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Deductions] [int] NOT NULL,
[IsFixed] [bit] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[AbstractionReviewDetail] ADD CONSTRAINT [PK_AbstractionReviewDetail] PRIMARY KEY CLUSTERED  ([AbstractionReviewDetailID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[AbstractionReviewDetail] ADD CONSTRAINT [FK_AbstractionReviewDetail_AbstractionReview] FOREIGN KEY ([AbstractionReviewID]) REFERENCES [dbo].[AbstractionReview] ([AbstractionReviewID])
GO
