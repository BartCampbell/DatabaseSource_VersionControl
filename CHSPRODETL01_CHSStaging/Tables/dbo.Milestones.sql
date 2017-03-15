CREATE TABLE [dbo].[Milestones]
(
[RecID] [int] NOT NULL IDENTITY(1, 1),
[ClientID] [int] NULL,
[ProjectID] [int] NULL,
[ChaseCount] [int] NULL,
[MilestoneDate] [date] NULL,
[MilestonePerc] [decimal] (9, 3) NULL,
[LoadDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Milestones] ADD CONSTRAINT [UQ__Mileston__360414FE6B2886CB] UNIQUE NONCLUSTERED  ([RecID]) ON [PRIMARY]
GO
