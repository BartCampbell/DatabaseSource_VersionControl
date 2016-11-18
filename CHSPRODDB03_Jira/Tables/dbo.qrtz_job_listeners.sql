CREATE TABLE [dbo].[qrtz_job_listeners]
(
[ID] [numeric] (18, 0) NOT NULL,
[JOB] [numeric] (18, 0) NULL,
[JOB_LISTENER] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[qrtz_job_listeners] ADD CONSTRAINT [PK_qrtz_job_listeners] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
