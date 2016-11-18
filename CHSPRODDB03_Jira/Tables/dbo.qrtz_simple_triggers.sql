CREATE TABLE [dbo].[qrtz_simple_triggers]
(
[ID] [numeric] (18, 0) NOT NULL,
[trigger_id] [numeric] (18, 0) NULL,
[REPEAT_COUNT] [int] NULL,
[REPEAT_INTERVAL] [numeric] (18, 0) NULL,
[TIMES_TRIGGERED] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[qrtz_simple_triggers] ADD CONSTRAINT [PK_qrtz_simple_triggers] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
