CREATE TABLE [dbo].[deadletter]
(
[ID] [numeric] (18, 0) NOT NULL,
[MESSAGE_ID] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[LAST_SEEN] [numeric] (18, 0) NULL,
[MAIL_SERVER_ID] [numeric] (18, 0) NULL,
[FOLDER_NAME] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[deadletter] ADD CONSTRAINT [PK_deadletter] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [deadletter_lastSeen] ON [dbo].[deadletter] ([LAST_SEEN]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [deadletter_msg_server_folder] ON [dbo].[deadletter] ([MESSAGE_ID], [MAIL_SERVER_ID], [FOLDER_NAME]) ON [PRIMARY]
GO
