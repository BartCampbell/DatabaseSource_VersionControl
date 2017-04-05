CREATE TABLE [Measure].[EventCriteria]
(
[AfterDOBDays] [smallint] NOT NULL CONSTRAINT [DF_EventCriteria_AfterDOBDays] DEFAULT ((0)),
[AfterDOBMonths] [smallint] NOT NULL CONSTRAINT [DF_EventCriteria_AfterDOBMonths] DEFAULT ((0)),
[AllowLab] [bit] NOT NULL CONSTRAINT [DF_EventCriteria_AllowLab] DEFAULT ((0)),
[AllowMerge] [bit] NOT NULL CONSTRAINT [DF_EventCriteria_AllowMerge] DEFAULT ((1)),
[AllowSum] [bit] NOT NULL CONSTRAINT [DF_EventCriteria_AllowSum] DEFAULT ((1)),
[AllowSupplemental] [bit] NOT NULL CONSTRAINT [DF_EventCriteria_AllowSupplemental] DEFAULT ((1)),
[ClaimTypeID] [tinyint] NOT NULL,
[DefaultDays] [int] NULL,
[DefaultValue] [decimal] (18, 6) NULL,
[Descr] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[EventCritGuid] [uniqueidentifier] NOT NULL CONSTRAINT [DF_EventCriteria_EventCritGuid] DEFAULT (newid()),
[EventCritID] [int] NOT NULL IDENTITY(1, 1),
[ExpireDate] [datetime] NULL,
[MeasureSetID] [int] NOT NULL,
[Reference1] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Reference2] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Reference3] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Reference4] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RequireOnly] [bit] NOT NULL CONSTRAINT [DF_EventCriteria_RequireOnly] DEFAULT ((0)),
[RequirePrimary] [bit] NOT NULL CONSTRAINT [DF_EventCriteria_RequirePrimary] DEFAULT ((0)),
[ValueTypeID] [tinyint] NULL
) ON [PRIMARY]
GO
ALTER TABLE [Measure].[EventCriteria] ADD CONSTRAINT [PK_EventCriteria] PRIMARY KEY CLUSTERED  ([EventCritID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_EventCriteria_ClaimTypeID] ON [Measure].[EventCriteria] ([ClaimTypeID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_EventCriteria_EventCritGuid] ON [Measure].[EventCriteria] ([EventCritGuid]) ON [PRIMARY]
GO
