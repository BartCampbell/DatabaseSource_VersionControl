CREATE TABLE [dbo].[AO_950DC3_TC_EVENTS]
(
[ALL_DAY] [bit] NULL,
[CREATED] [bigint] NULL,
[DESCRIPTION] [ntext] COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[END] [bigint] NULL,
[ID] [int] NOT NULL IDENTITY(1, 1),
[LAST_MODIFIED] [bigint] NULL,
[LOCATION] [ntext] COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[ORGANISER] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[RECURRENCE_ID_TIMESTAMP] [bigint] NULL,
[RECURRENCE_RULE] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[REMINDER_SETTING_ID] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[SEQUENCE] [int] NULL,
[START] [bigint] NULL,
[SUB_CALENDAR_ID] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[SUMMARY] [ntext] COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[URL] [ntext] COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[UTC_END] [bigint] NULL,
[UTC_START] [bigint] NULL,
[VEVENT_UID] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[AO_950DC3_TC_EVENTS] ADD CONSTRAINT [pk_AO_950DC3_TC_EVENTS_ID] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[AO_950DC3_TC_EVENTS] ADD CONSTRAINT [fk_ao_950dc3_tc_events_reminder_setting_id] FOREIGN KEY ([REMINDER_SETTING_ID]) REFERENCES [dbo].[AO_950DC3_TC_REMINDER_SETTINGS] ([ID])
GO
ALTER TABLE [dbo].[AO_950DC3_TC_EVENTS] ADD CONSTRAINT [fk_ao_950dc3_tc_events_sub_calendar_id] FOREIGN KEY ([SUB_CALENDAR_ID]) REFERENCES [dbo].[AO_950DC3_TC_SUBCALS] ([ID])
GO
