CREATE TABLE [dbo].[scheduler_run_details]
(
[id] [numeric] (19, 0) NOT NULL,
[job_id] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[start_time] [datetime] NULL,
[duration] [numeric] (19, 0) NULL,
[outcome] [nchar] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[message] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[scheduler_run_details] ADD CONSTRAINT [PK__schedule__3213E83FF11B03C5] PRIMARY KEY CLUSTERED  ([id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [job_id_idx] ON [dbo].[scheduler_run_details] ([job_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [start_time_idx] ON [dbo].[scheduler_run_details] ([start_time]) ON [PRIMARY]
GO
