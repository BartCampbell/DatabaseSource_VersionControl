CREATE TABLE [Measure].[EventCriteriaValueTypes]
(
[Abbrev] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Descr] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ValueTypeGuid] [uniqueidentifier] NOT NULL CONSTRAINT [DF_EventCriteriaValueTypes_ValueTypeGuid] DEFAULT (newid()),
[ValueTypeID] [tinyint] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [Measure].[EventCriteriaValueTypes] ADD CONSTRAINT [PK_EventCriteriaValueTypes] PRIMARY KEY CLUSTERED  ([ValueTypeID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_EventCriteriaValueTypes_Abbrev] ON [Measure].[EventCriteriaValueTypes] ([Abbrev]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_EventCriteriaValueTypes_ValueTypeGuid] ON [Measure].[EventCriteriaValueTypes] ([ValueTypeGuid]) ON [PRIMARY]
GO
