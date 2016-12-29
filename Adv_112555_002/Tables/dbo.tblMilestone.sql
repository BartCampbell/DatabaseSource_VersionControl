CREATE TABLE [dbo].[tblMilestone]
(
[Milestone_PK] [int] NOT NULL IDENTITY(1, 1),
[Milestone_Goal] [int] NOT NULL,
[MilestoneType_PK] [int] NOT NULL,
[dt_from] [date] NULL,
[dt_to] [date] NULL,
[isActive] [int] NULL,
[Project_PK] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblMilestone] ADD CONSTRAINT [PK_tblMilestone] PRIMARY KEY CLUSTERED  ([Milestone_PK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
