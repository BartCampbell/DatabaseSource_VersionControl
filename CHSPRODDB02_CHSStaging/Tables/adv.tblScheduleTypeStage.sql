CREATE TABLE [adv].[tblScheduleTypeStage]
(
[ScheduleType_PK] [tinyint] NOT NULL,
[ScheduleType] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Client] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL,
[CCI] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ScheduleTypeHashKey] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClientHashKey] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CSI] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [adv].[tblScheduleTypeStage] ADD CONSTRAINT [PK_tblScheduleType] PRIMARY KEY CLUSTERED  ([ScheduleType_PK]) ON [PRIMARY]
GO
