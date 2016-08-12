CREATE TABLE [dbo].[tblMemberSchedule]
(
[Schedule_PK] [int] NOT NULL IDENTITY(1, 1),
[Project_PK] [smallint] NOT NULL,
[Member_PK] [bigint] NOT NULL,
[Suspect_PK] [bigint] NOT NULL,
[Sch_Start] [smalldatetime] NULL,
[Sch_End] [smalldatetime] NULL,
[Sch_User_PK] [smallint] NULL,
[LastUpdated_User_PK] [smallint] NULL,
[LastUpdated_Date] [smalldatetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblMemberSchedule] ADD CONSTRAINT [PK_tblCAMS_Schedule] PRIMARY KEY CLUSTERED  ([Schedule_PK]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
