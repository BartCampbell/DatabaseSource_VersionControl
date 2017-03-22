CREATE TABLE [dbo].[tblCompletionStatus]
(
[CompletionStatus_PK] [tinyint] NOT NULL,
[CompletionStatus] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idxCompletionStatus] ON [dbo].[tblCompletionStatus] ([CompletionStatus_PK]) ON [PRIMARY]
GO
