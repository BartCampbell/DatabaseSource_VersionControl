CREATE TABLE [dbo].[scheduler_clustered_jobs]
(
[id] [numeric] (19, 0) NOT NULL,
[job_id] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[next_run_time] [datetime] NULL,
[version] [numeric] (19, 0) NULL,
[job_runner_key] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[raw_parameters] [image] NULL,
[sched_type] [nchar] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cron_expression] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cron_time_zone] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[interval_first_run_time] [datetime] NULL,
[interval_millis] [numeric] (19, 0) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[scheduler_clustered_jobs] ADD CONSTRAINT [PK__schedule__3213E83F9FD982BC] PRIMARY KEY CLUSTERED  ([id]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[scheduler_clustered_jobs] ADD CONSTRAINT [UQ__schedule__6E32B6A46321C716] UNIQUE NONCLUSTERED  ([job_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [job_runner_key_idx] ON [dbo].[scheduler_clustered_jobs] ([job_runner_key]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [next_run_time_idx] ON [dbo].[scheduler_clustered_jobs] ([next_run_time]) ON [PRIMARY]
GO
