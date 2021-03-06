CREATE TABLE [dbo].[JQUARTZ_JOB_DETAILS]
(
[SCHED_NAME] [varchar] (120) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[JOB_NAME] [varchar] (200) COLLATE SQL_Latin1_General_CP437_CI_AI NOT NULL,
[JOB_GROUP] [varchar] (200) COLLATE SQL_Latin1_General_CP437_CI_AI NOT NULL,
[DESCRIPTION] [varchar] (250) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[JOB_CLASS_NAME] [varchar] (250) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[IS_DURABLE] [varchar] (1) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[IS_VOLATILE] [varchar] (1) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[IS_STATEFUL] [varchar] (1) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[IS_NONCONCURRENT] [varchar] (1) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[IS_UPDATE_DATA] [varchar] (1) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[REQUESTS_RECOVERY] [varchar] (1) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[JOB_DATA] [image] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[JQUARTZ_JOB_DETAILS] ADD CONSTRAINT [PK_JQUARTZ_JOB_DETAILS] PRIMARY KEY CLUSTERED  ([JOB_NAME], [JOB_GROUP]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_qrtz_j_grp] ON [dbo].[JQUARTZ_JOB_DETAILS] ([SCHED_NAME], [JOB_GROUP]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_qrtz_j_req_recovery] ON [dbo].[JQUARTZ_JOB_DETAILS] ([SCHED_NAME], [REQUESTS_RECOVERY]) ON [PRIMARY]
GO
