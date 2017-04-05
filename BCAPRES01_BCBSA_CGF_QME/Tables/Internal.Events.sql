CREATE TABLE [Internal].[Events]
(
[BatchID] [int] NOT NULL,
[BeginDate] [datetime] NOT NULL,
[BeginOrigDate] [datetime] NOT NULL,
[ClaimTypeID] [tinyint] NULL,
[CodeID] [int] NOT NULL,
[CountClaims] [int] NOT NULL,
[CountCodes] [int] NOT NULL,
[CountLines] [int] NOT NULL,
[CountProviders] [int] NOT NULL,
[DataRunID] [int] NOT NULL,
[DataSetID] [int] NOT NULL,
[DataSourceID] [int] NOT NULL,
[Days] [smallint] NULL,
[DispenseID] [smallint] NULL,
[DSClaimID] [bigint] NOT NULL,
[DSClaimLineID] [bigint] NOT NULL,
[DSEventID] [bigint] NOT NULL IDENTITY(1, 1),
[DSMemberID] [bigint] NOT NULL,
[DSProviderID] [bigint] NULL,
[EndDate] [datetime] NULL,
[EndOrigDate] [datetime] NULL,
[EventBaseID] [bigint] NOT NULL,
[EventCritID] [int] NULL,
[EventID] [int] NOT NULL,
[EventInfo] [xml] NULL,
[EventMergeInfo] [xml] NULL,
[EventXferInfo] [xml] NULL,
[EventValueInfo] [xml] NULL,
[IsPaid] [bit] NOT NULL CONSTRAINT [DF_Events_IsPaid] DEFAULT ((0)),
[IsSupplemental] [bit] NOT NULL,
[IsXfer] [bit] NOT NULL CONSTRAINT [DF_Events_IsTransfer] DEFAULT ((0)),
[SpId] [int] NOT NULL CONSTRAINT [DF_Events_SpId] DEFAULT (@@spid),
[Value] [decimal] (18, 6) NULL,
[XferID] [bigint] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Internal].[Events] ADD CONSTRAINT [PK_Internal_Events] PRIMARY KEY CLUSTERED  ([DSEventID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Internal_Events] ON [Internal].[Events] ([SpId], [EventID], [DSMemberID], [BeginDate], [EndDate], [EndOrigDate], [EventCritID], [DSProviderID], [DSEventID]) INCLUDE ([BeginOrigDate], [IsSupplemental]) ON [PRIMARY]
GO
