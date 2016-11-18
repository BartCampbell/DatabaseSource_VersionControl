CREATE TABLE [dbo].[qrtz_triggers]
(
[ID] [numeric] (18, 0) NOT NULL,
[TRIGGER_NAME] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[TRIGGER_GROUP] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[JOB] [numeric] (18, 0) NULL,
[NEXT_FIRE] [datetime] NULL,
[TRIGGER_STATE] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[TRIGGER_TYPE] [nvarchar] (60) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[START_TIME] [datetime] NULL,
[END_TIME] [datetime] NULL,
[CALENDAR_NAME] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[MISFIRE_INSTR] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[qrtz_triggers] ADD CONSTRAINT [PK_qrtz_triggers] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
