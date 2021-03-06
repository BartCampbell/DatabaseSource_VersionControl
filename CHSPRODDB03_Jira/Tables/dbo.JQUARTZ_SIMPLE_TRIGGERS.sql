CREATE TABLE [dbo].[JQUARTZ_SIMPLE_TRIGGERS]
(
[SCHED_NAME] [varchar] (120) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[TRIGGER_NAME] [varchar] (200) COLLATE SQL_Latin1_General_CP437_CI_AI NOT NULL,
[TRIGGER_GROUP] [varchar] (200) COLLATE SQL_Latin1_General_CP437_CI_AI NOT NULL,
[REPEAT_COUNT] [bigint] NULL,
[REPEAT_INTERVAL] [bigint] NULL,
[TIMES_TRIGGERED] [bigint] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[JQUARTZ_SIMPLE_TRIGGERS] ADD CONSTRAINT [PK_JQUARTZ_SIMPLE_TRIGGERS] PRIMARY KEY CLUSTERED  ([TRIGGER_NAME], [TRIGGER_GROUP]) ON [PRIMARY]
GO
