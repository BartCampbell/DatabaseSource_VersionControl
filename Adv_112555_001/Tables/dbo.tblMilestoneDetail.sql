CREATE TABLE [dbo].[tblMilestoneDetail]
(
[Milestone_PK] [int] NOT NULL,
[dtGoal] [date] NULL,
[Goal] [int] NULL
) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [IDX_Milestone_PK] ON [dbo].[tblMilestoneDetail] ([Milestone_PK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
