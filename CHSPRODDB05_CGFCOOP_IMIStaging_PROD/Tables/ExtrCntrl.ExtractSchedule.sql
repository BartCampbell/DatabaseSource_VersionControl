CREATE TABLE [ExtrCntrl].[ExtractSchedule]
(
[ExtractScheduleID] [int] NOT NULL IDENTITY(1, 1),
[ExtractMasterID] [int] NULL,
[ExtractTiming] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ExtractExecutionTime] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastRun] [datetime] NULL,
[NextRun] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [ExtrCntrl].[ExtractSchedule] ADD CONSTRAINT [pk_ExtractSchedule] PRIMARY KEY CLUSTERED  ([ExtractScheduleID]) ON [PRIMARY]
GO
