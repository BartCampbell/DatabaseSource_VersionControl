CREATE TABLE [dbo].[SubjectArea]
(
[SubjectAreaID] [uniqueidentifier] NOT NULL CONSTRAINT [DF_SubjectArea_SubjectAreaID] DEFAULT (newid()),
[Description] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[SubjectArea] ADD CONSTRAINT [SubjectArea_PK] PRIMARY KEY CLUSTERED  ([SubjectAreaID]) ON [PRIMARY]
GO
