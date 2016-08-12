CREATE TABLE [dbo].[tblPool]
(
[Pool_PK] [smallint] NOT NULL IDENTITY(1, 1),
[Pool_Name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsBucketRule] [bit] NULL,
[ProviderOfficeBucket_PK] [tinyint] NULL,
[IsFollowupRule] [bit] NULL,
[IsRemainingRule] [bit] NULL,
[RemainingCharts] [smallint] NULL,
[RemainingChartsMoreOrEqual] [bit] NULL,
[IsLastScheduledRule] [bit] NULL,
[DaysSinceLastScheduled] [tinyint] NULL,
[IsScheduledTypeRule] [bit] NULL,
[ScheduledType] [tinyint] NULL,
[IsZoneRule] [bit] NULL,
[Zone_PK] [tinyint] NULL,
[IsProjectRule] [bit] NULL,
[Projects] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProjectGroups] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SchedulerTeam_PK] [smallint] NULL,
[Pool_Priority] [tinyint] NULL,
[IsAutoRefreshPool] [bit] NULL,
[PriorityWithinPool] [tinyint] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblPool] ADD CONSTRAINT [PK_tblPool] PRIMARY KEY CLUSTERED  ([Pool_PK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tblPool_Bucket] ON [dbo].[tblPool] ([ProviderOfficeBucket_PK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tblPool_Team] ON [dbo].[tblPool] ([SchedulerTeam_PK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tblPool_Zone] ON [dbo].[tblPool] ([Zone_PK]) ON [PRIMARY]
GO
