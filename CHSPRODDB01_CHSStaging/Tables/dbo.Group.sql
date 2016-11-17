CREATE TABLE [dbo].[Group]
(
[GroupID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[GroupName] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Group] ADD CONSTRAINT [PK_Group] PRIMARY KEY CLUSTERED  ([GroupID]) ON [PRIMARY]
GO
