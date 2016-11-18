CREATE TABLE [dbo].[JQUARTZ_TRIGGERS]
(
[SCHED_NAME] [varchar] (120) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[TRIGGER_NAME] [varchar] (200) COLLATE SQL_Latin1_General_CP437_CI_AI NOT NULL,
[TRIGGER_GROUP] [varchar] (200) COLLATE SQL_Latin1_General_CP437_CI_AI NOT NULL,
[JOB_NAME] [varchar] (200) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[JOB_GROUP] [varchar] (200) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[IS_VOLATILE] [varchar] (1) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[DESCRIPTION] [varchar] (250) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[NEXT_FIRE_TIME] [bigint] NULL,
[PREV_FIRE_TIME] [bigint] NULL,
[PRIORITY] [int] NULL,
[TRIGGER_STATE] [varchar] (16) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[TRIGGER_TYPE] [varchar] (8) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[START_TIME] [bigint] NULL,
[END_TIME] [bigint] NULL,
[CALENDAR_NAME] [varchar] (200) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[MISFIRE_INSTR] [smallint] NULL,
[JOB_DATA] [image] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[JQUARTZ_TRIGGERS] ADD CONSTRAINT [PK_JQUARTZ_TRIGGERS] PRIMARY KEY CLUSTERED  ([TRIGGER_NAME], [TRIGGER_GROUP]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_qrtz_t_c] ON [dbo].[JQUARTZ_TRIGGERS] ([SCHED_NAME], [CALENDAR_NAME]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_qrtz_t_jg] ON [dbo].[JQUARTZ_TRIGGERS] ([SCHED_NAME], [JOB_GROUP]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_qrtz_t_j] ON [dbo].[JQUARTZ_TRIGGERS] ([SCHED_NAME], [JOB_NAME], [JOB_GROUP]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_qrtz_t_nft_misfire] ON [dbo].[JQUARTZ_TRIGGERS] ([SCHED_NAME], [MISFIRE_INSTR], [NEXT_FIRE_TIME]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_qrtz_t_nft_st_misfire_grp] ON [dbo].[JQUARTZ_TRIGGERS] ([SCHED_NAME], [MISFIRE_INSTR], [NEXT_FIRE_TIME], [TRIGGER_GROUP], [TRIGGER_STATE]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_qrtz_t_nft_st_misfire] ON [dbo].[JQUARTZ_TRIGGERS] ([SCHED_NAME], [MISFIRE_INSTR], [NEXT_FIRE_TIME], [TRIGGER_STATE]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_qrtz_t_next_fire_time] ON [dbo].[JQUARTZ_TRIGGERS] ([SCHED_NAME], [NEXT_FIRE_TIME]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_qrtz_j_g] ON [dbo].[JQUARTZ_TRIGGERS] ([SCHED_NAME], [TRIGGER_GROUP]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_qrtz_t_n_g_state] ON [dbo].[JQUARTZ_TRIGGERS] ([SCHED_NAME], [TRIGGER_GROUP], [TRIGGER_STATE]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_qrtz_t_n_state] ON [dbo].[JQUARTZ_TRIGGERS] ([SCHED_NAME], [TRIGGER_NAME], [TRIGGER_GROUP], [TRIGGER_STATE]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_qrtz_j_state] ON [dbo].[JQUARTZ_TRIGGERS] ([SCHED_NAME], [TRIGGER_STATE]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_qrtz_t_nft_st] ON [dbo].[JQUARTZ_TRIGGERS] ([SCHED_NAME], [TRIGGER_STATE], [NEXT_FIRE_TIME]) ON [PRIMARY]
GO