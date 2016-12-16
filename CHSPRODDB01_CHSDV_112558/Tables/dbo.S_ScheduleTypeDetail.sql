CREATE TABLE [dbo].[S_ScheduleTypeDetail]
(
[S_ScheduleTypeDetail_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LoadDate] [datetime] NULL,
[H_ScheduleType_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ScheduleType] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HashDiff] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordEndDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[S_ScheduleTypeDetail] ADD CONSTRAINT [PK_S_ScheduleTypeDetail] PRIMARY KEY CLUSTERED  ([S_ScheduleTypeDetail_RK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [NonClusteredIndex-20161003-081835] ON [dbo].[S_ScheduleTypeDetail] ([HashDiff]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[S_ScheduleTypeDetail] ADD CONSTRAINT [FK_H_ScheduleType_RK] FOREIGN KEY ([H_ScheduleType_RK]) REFERENCES [dbo].[H_ScheduleType] ([H_ScheduleType_RK]) ON DELETE CASCADE ON UPDATE CASCADE
GO
