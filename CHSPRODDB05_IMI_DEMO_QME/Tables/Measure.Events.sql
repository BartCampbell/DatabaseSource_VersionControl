CREATE TABLE [Measure].[Events]
(
[AllowDaySum] [bit] NOT NULL CONSTRAINT [DF_Events_AllowDaySum] DEFAULT ((1)),
[AllowEndDate] [bit] NOT NULL CONSTRAINT [DF_Events_AllowEndDate] DEFAULT ((1)),
[BeginDays] [smallint] NULL,
[BeginMonths] [smallint] NULL,
[Descr] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DispenseQty] [smallint] NULL,
[EndDays] [smallint] NULL,
[EndMonths] [smallint] NULL,
[EventGuid] [uniqueidentifier] NOT NULL CONSTRAINT [DF_Events_EventGuid] DEFAULT (newid()),
[EventID] [int] NOT NULL IDENTITY(1, 1),
[EventTypeID] [tinyint] NOT NULL CONSTRAINT [DF_Events_EventTypeID] DEFAULT ((1)),
[Gender] [tinyint] NULL,
[IsClaimAttrib] AS ([Measure].[IsEventToClaimAttribute]([EventID])),
[IsEnabled] [bit] NOT NULL CONSTRAINT [DF_Events_IsEnabled] DEFAULT ((1)),
[IsMerged] [bit] NULL CONSTRAINT [DF_Events_IsMerged] DEFAULT ((0)),
[IsSummarized] [bit] NOT NULL CONSTRAINT [DF_Events_IsSummarized] DEFAULT ((1)),
[MeasureSetID] [int] NOT NULL,
[RequireEndDate] [bit] NOT NULL CONSTRAINT [DF_Events_RequireEndDate] DEFAULT ((0)),
[RequireEnrolled] [bit] NOT NULL CONSTRAINT [DF_Events_RequireEnrolled] DEFAULT ((0)),
[RequirePaid] [bit] NOT NULL CONSTRAINT [DF_Events_RequirePaid] DEFAULT ((0)),
[UniqueDescr] AS (CONVERT([varchar](164),left((replace(CONVERT([varchar](36),[EventGuid],(0)),'-','')+' - ')+[Descr],(164)),(0))) PERSISTED
) ON [PRIMARY]
GO
ALTER TABLE [Measure].[Events] ADD CONSTRAINT [CK_Events_BeginDaysAndMonths] CHECK (([BeginDays] IS NULL AND [BeginMonths] IS NULL OR [BeginDays] IS NOT NULL AND [BeginMonths] IS NOT NULL))
GO
ALTER TABLE [Measure].[Events] ADD CONSTRAINT [CK_Events_EndDaysAndMonths] CHECK (([EndDays] IS NULL AND [EndMonths] IS NULL OR [EndDays] IS NOT NULL AND [EndMonths] IS NOT NULL))
GO
ALTER TABLE [Measure].[Events] ADD CONSTRAINT [CK_Events_DispenseQty_or_IsMerged] CHECK (([IsMerged]=(0) OR [DispenseQty] IS NULL))
GO
ALTER TABLE [Measure].[Events] ADD CONSTRAINT [PK_Events] PRIMARY KEY CLUSTERED  ([EventID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Events_EventGuid] ON [Measure].[Events] ([EventGuid]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Events_MeasureSetID] ON [Measure].[Events] ([MeasureSetID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Events_UniqueDescr] ON [Measure].[Events] ([UniqueDescr]) ON [PRIMARY]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Cannot set a DispenseQty for a merged event.', 'SCHEMA', N'Measure', 'TABLE', N'Events', 'CONSTRAINT', N'CK_Events_DispenseQty_or_IsMerged'
GO
