CREATE TABLE [Measure].[EventCriteriaCodes]
(
[Code] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CodeID] [int] NULL,
[CodeTypeID] [tinyint] NOT NULL,
[EventCritCodeGuid] [uniqueidentifier] NOT NULL CONSTRAINT [DF_EventCriteriaCodes_EventCritCodeGuid] DEFAULT (newid()),
[EventCritCodeID] [int] NOT NULL IDENTITY(1, 1),
[EventCritID] [int] NOT NULL,
[Value] [decimal] (18, 6) NULL
) ON [PRIMARY]
GO
ALTER TABLE [Measure].[EventCriteriaCodes] ADD CONSTRAINT [PK_EventCriteraCodes] PRIMARY KEY CLUSTERED  ([EventCritCodeID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_EventCriteriaCodes_CodeID] ON [Measure].[EventCriteriaCodes] ([CodeID]) INCLUDE ([Code], [CodeTypeID], [EventCritID], [Value]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_EventCriteriaCodes_EventCritCodeGuid] ON [Measure].[EventCriteriaCodes] ([EventCritCodeGuid]) ON [PRIMARY]
GO
