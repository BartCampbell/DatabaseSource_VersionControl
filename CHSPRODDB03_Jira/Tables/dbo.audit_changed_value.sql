CREATE TABLE [dbo].[audit_changed_value]
(
[ID] [numeric] (18, 0) NOT NULL,
[LOG_ID] [numeric] (18, 0) NULL,
[NAME] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[DELTA_FROM] [ntext] COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[DELTA_TO] [ntext] COLLATE SQL_Latin1_General_CP437_CI_AI NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[audit_changed_value] ADD CONSTRAINT [PK_audit_changed_value] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_changed_value_log_id] ON [dbo].[audit_changed_value] ([LOG_ID]) ON [PRIMARY]
GO
