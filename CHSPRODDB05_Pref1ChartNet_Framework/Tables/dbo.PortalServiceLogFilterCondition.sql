CREATE TABLE [dbo].[PortalServiceLogFilterCondition]
(
[PortalServiceLogFilterConditionID] [uniqueidentifier] NOT NULL CONSTRAINT [DF_PortalServiceLogFilterCondition_ID] DEFAULT (newid()),
[PortalServiceLogFilterID] [uniqueidentifier] NOT NULL,
[JoinCondition] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Field] [varchar] (300) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[QueryAction] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Criteria] [varchar] (300) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SortNum] [smallint] NOT NULL CONSTRAINT [DF_PortalServiceLogFilterCondition_SortNum] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PortalServiceLogFilterCondition] ADD CONSTRAINT [PK_PortalServiceLogFilterCondition] PRIMARY KEY CLUSTERED  ([PortalServiceLogFilterConditionID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PortalServiceLogFilterCondition] WITH NOCHECK ADD CONSTRAINT [FK_PortalServiceLogFilterCondition_PortalServiceLogFilter] FOREIGN KEY ([PortalServiceLogFilterID]) REFERENCES [dbo].[PortalServiceLogFilter] ([PortalServiceLogFilterID])
GO
