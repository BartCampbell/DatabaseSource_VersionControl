CREATE TABLE [dbo].[avatar]
(
[ID] [numeric] (18, 0) NOT NULL,
[filename] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[contenttype] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[avatartype] [nvarchar] (60) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[owner] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[systemavatar] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[avatar] ADD CONSTRAINT [PK_avatar] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [avatar_index] ON [dbo].[avatar] ([avatartype], [owner]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [avatar_filename_index] ON [dbo].[avatar] ([filename], [avatartype], [systemavatar]) ON [PRIMARY]
GO
