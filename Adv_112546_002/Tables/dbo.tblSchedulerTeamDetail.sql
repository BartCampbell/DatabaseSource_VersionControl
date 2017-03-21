CREATE TABLE [dbo].[tblSchedulerTeamDetail]
(
[SchedulerTeam_PK] [smallint] NOT NULL,
[Scheduler_User_PK] [smallint] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblSchedulerTeamDetail] ADD CONSTRAINT [PK_tblSchedulerTeamDetail] PRIMARY KEY CLUSTERED  ([SchedulerTeam_PK], [Scheduler_User_PK]) ON [PRIMARY]
GO
