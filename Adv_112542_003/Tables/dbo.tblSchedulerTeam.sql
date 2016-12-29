CREATE TABLE [dbo].[tblSchedulerTeam]
(
[SchedulerTeam_PK] [smallint] NOT NULL IDENTITY(1, 1),
[Team_Name] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Supervisor_User_PK] [smallint] NULL,
[Location_PK] [smallint] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblSchedulerTeam] ADD CONSTRAINT [PK_tblSchedulerTeam] PRIMARY KEY CLUSTERED  ([SchedulerTeam_PK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tblSchedulerTeam_Location] ON [dbo].[tblSchedulerTeam] ([Location_PK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tblSchedulerTeam_supervisor] ON [dbo].[tblSchedulerTeam] ([Supervisor_User_PK]) ON [PRIMARY]
GO
