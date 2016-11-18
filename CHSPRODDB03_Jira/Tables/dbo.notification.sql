CREATE TABLE [dbo].[notification]
(
[ID] [numeric] (18, 0) NOT NULL,
[SCHEME] [numeric] (18, 0) NULL,
[EVENT] [nvarchar] (60) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[EVENT_TYPE_ID] [numeric] (18, 0) NULL,
[TEMPLATE_ID] [numeric] (18, 0) NULL,
[notif_type] [nvarchar] (60) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[notif_parameter] [nvarchar] (60) COLLATE SQL_Latin1_General_CP437_CI_AI NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[notification] ADD CONSTRAINT [PK_notification] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ntfctn_scheme] ON [dbo].[notification] ([SCHEME]) ON [PRIMARY]
GO
