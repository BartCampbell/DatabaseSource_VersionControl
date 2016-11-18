CREATE TABLE [dbo].[clusteredjob]
(
[ID] [numeric] (18, 0) NOT NULL,
[JOB_ID] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[JOB_RUNNER_KEY] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[SCHED_TYPE] [nchar] (1) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[INTERVAL_MILLIS] [numeric] (18, 0) NULL,
[FIRST_RUN] [numeric] (18, 0) NULL,
[CRON_EXPRESSION] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[TIME_ZONE] [nvarchar] (60) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[NEXT_RUN] [numeric] (18, 0) NULL,
[VERSION] [numeric] (18, 0) NULL,
[PARAMETERS] [image] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[clusteredjob] ADD CONSTRAINT [PK_clusteredjob] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [clusteredjob_jobid_idx] ON [dbo].[clusteredjob] ([JOB_ID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [clusteredjob_jrk_idx] ON [dbo].[clusteredjob] ([JOB_RUNNER_KEY]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [clusteredjob_nextrun_idx] ON [dbo].[clusteredjob] ([NEXT_RUN]) ON [PRIMARY]
GO
