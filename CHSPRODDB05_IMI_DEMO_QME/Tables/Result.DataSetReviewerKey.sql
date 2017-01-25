CREATE TABLE [Result].[DataSetReviewerKey]
(
[DataRunID] [int] NOT NULL,
[DataSetID] [int] NOT NULL,
[DisplayName] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FirstName] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastName] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ReviewerID] [int] NOT NULL,
[UserName] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [Result].[DataSetReviewerKey] ADD CONSTRAINT [PK_DataSetReviewerKey] PRIMARY KEY CLUSTERED  ([DataRunID], [ReviewerID]) ON [PRIMARY]
GO
