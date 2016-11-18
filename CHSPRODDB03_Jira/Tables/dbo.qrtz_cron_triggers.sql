CREATE TABLE [dbo].[qrtz_cron_triggers]
(
[ID] [numeric] (18, 0) NOT NULL,
[trigger_id] [numeric] (18, 0) NULL,
[cronExperssion] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[qrtz_cron_triggers] ADD CONSTRAINT [PK_qrtz_cron_triggers] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
