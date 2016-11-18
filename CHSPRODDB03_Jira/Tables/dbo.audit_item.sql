CREATE TABLE [dbo].[audit_item]
(
[ID] [numeric] (18, 0) NOT NULL,
[LOG_ID] [numeric] (18, 0) NULL,
[OBJECT_TYPE] [nvarchar] (60) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[OBJECT_ID] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[OBJECT_NAME] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[OBJECT_PARENT_ID] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[OBJECT_PARENT_NAME] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[audit_item] ADD CONSTRAINT [PK_audit_item] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_audit_item_log_id2] ON [dbo].[audit_item] ([LOG_ID]) ON [PRIMARY]
GO
