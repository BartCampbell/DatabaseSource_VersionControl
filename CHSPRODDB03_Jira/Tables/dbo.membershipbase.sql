CREATE TABLE [dbo].[membershipbase]
(
[ID] [numeric] (18, 0) NOT NULL,
[USER_NAME] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[GROUP_NAME] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[membershipbase] ADD CONSTRAINT [PK_membershipbase] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [mshipbase_group] ON [dbo].[membershipbase] ([GROUP_NAME]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [mshipbase_user] ON [dbo].[membershipbase] ([USER_NAME]) ON [PRIMARY]
GO
