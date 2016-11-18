CREATE TABLE [dbo].[tempattachmentsmonitor]
(
[TEMPORARY_ATTACHMENT_ID] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NOT NULL,
[FORM_TOKEN] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[FILE_NAME] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[CONTENT_TYPE] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[FILE_SIZE] [numeric] (18, 0) NULL,
[CREATED_TIME] [numeric] (18, 0) NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tempattachmentsmonitor] ADD CONSTRAINT [PK_tempattachmentsmonitor] PRIMARY KEY CLUSTERED  ([TEMPORARY_ATTACHMENT_ID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_tam_by_created_time] ON [dbo].[tempattachmentsmonitor] ([CREATED_TIME]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_tam_by_form_token] ON [dbo].[tempattachmentsmonitor] ([FORM_TOKEN]) ON [PRIMARY]
GO
