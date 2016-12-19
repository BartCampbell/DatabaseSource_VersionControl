CREATE TABLE [dbo].[tblScheduleType]
(
[ScheduleType_PK] [tinyint] NOT NULL,
[ScheduleType] [varchar] (50) COLLATE SQL_Latin1_General_CP437_CI_AI NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblScheduleType] ADD CONSTRAINT [PK_tblScheduleType] PRIMARY KEY CLUSTERED  ([ScheduleType_PK]) ON [PRIMARY]
GO
