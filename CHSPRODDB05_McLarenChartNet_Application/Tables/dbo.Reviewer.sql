CREATE TABLE [dbo].[Reviewer]
(
[ReviewerID] [int] NOT NULL IDENTITY(1, 1),
[ReviewerName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ReviewerGroup] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FirstName] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastName] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UserName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Reviewer] ADD CONSTRAINT [PK_Reviewer] PRIMARY KEY CLUSTERED  ([ReviewerID]) ON [PRIMARY]
GO
