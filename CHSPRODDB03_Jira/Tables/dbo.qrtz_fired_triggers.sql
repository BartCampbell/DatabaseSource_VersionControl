CREATE TABLE [dbo].[qrtz_fired_triggers]
(
[ID] [numeric] (18, 0) NULL,
[ENTRY_ID] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NOT NULL,
[trigger_id] [numeric] (18, 0) NULL,
[TRIGGER_LISTENER] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[FIRED_TIME] [datetime] NULL,
[TRIGGER_STATE] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[qrtz_fired_triggers] ADD CONSTRAINT [PK_qrtz_fired_triggers] PRIMARY KEY CLUSTERED  ([ENTRY_ID]) ON [PRIMARY]
GO
