CREATE TABLE [dbo].[notificationinstance]
(
[ID] [numeric] (18, 0) NOT NULL,
[notificationtype] [nvarchar] (60) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[SOURCE] [numeric] (18, 0) NULL,
[emailaddress] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[MESSAGEID] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[notificationinstance] ADD CONSTRAINT [PK_notificationinstance] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [notif_messageid] ON [dbo].[notificationinstance] ([MESSAGEID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [notif_source] ON [dbo].[notificationinstance] ([SOURCE]) ON [PRIMARY]
GO
