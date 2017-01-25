CREATE TABLE [Measure].[EventTransfers]
(
[AllowSupplemental] [bit] NOT NULL CONSTRAINT [DF_EventTransfers_AllowSupplemental] DEFAULT ((0)),
[BeginDays] [smallint] NOT NULL CONSTRAINT [DF_EventTransfers_BeginDays] DEFAULT ((0)),
[BeginMonths] [smallint] NOT NULL CONSTRAINT [DF_EventTransfers_BeginMonths] DEFAULT ((0)),
[EndDays] [smallint] NOT NULL CONSTRAINT [DF_EventTransfers_EndDays] DEFAULT ((1)),
[EndMonths] [smallint] NOT NULL CONSTRAINT [DF_EventTransfers_EndMonths] DEFAULT ((0)),
[EventXferGuid] [uniqueidentifier] NOT NULL CONSTRAINT [DF_EventTransfers_EventXferGuid] DEFAULT (newid()),
[EventXferID] [int] NOT NULL IDENTITY(1, 1),
[FromEventID] [int] NOT NULL,
[MatchOnEventCritID] [bit] NOT NULL CONSTRAINT [DF_EventTransfers_MatchOnEventCritID] DEFAULT ((0)),
[ToEventID] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [Measure].[EventTransfers] ADD CONSTRAINT [PK_EventTransfers] PRIMARY KEY CLUSTERED  ([EventXferID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_EventTransfers] ON [Measure].[EventTransfers] ([FromEventID], [ToEventID]) ON [PRIMARY]
GO
