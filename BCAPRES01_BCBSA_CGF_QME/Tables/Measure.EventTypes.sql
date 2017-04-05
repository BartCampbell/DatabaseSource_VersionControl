CREATE TABLE [Measure].[EventTypes]
(
[Abbrev] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Descr] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[EventTypeGuid] [uniqueidentifier] NOT NULL CONSTRAINT [DF_EventTypes_EventTypeGuid] DEFAULT (newid()),
[EventTypeID] [tinyint] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [Measure].[EventTypes] ADD CONSTRAINT [PK_EventTypes] PRIMARY KEY CLUSTERED  ([EventTypeID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_EventTypes_Abbrev] ON [Measure].[EventTypes] ([Abbrev]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_EventTypes_EventTypeGuid] ON [Measure].[EventTypes] ([EventTypeGuid]) ON [PRIMARY]
GO
