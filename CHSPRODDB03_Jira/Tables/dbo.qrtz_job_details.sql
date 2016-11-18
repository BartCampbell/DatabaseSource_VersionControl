CREATE TABLE [dbo].[qrtz_job_details]
(
[ID] [numeric] (18, 0) NOT NULL,
[JOB_NAME] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[JOB_GROUP] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[CLASS_NAME] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[IS_DURABLE] [nvarchar] (60) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[IS_STATEFUL] [nvarchar] (60) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[REQUESTS_RECOVERY] [nvarchar] (60) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[JOB_DATA] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[qrtz_job_details] ADD CONSTRAINT [PK_qrtz_job_details] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
