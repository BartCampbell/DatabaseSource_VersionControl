CREATE TABLE [Log].[Events]
(
[BatchID] [int] NOT NULL,
[BeginDate] [datetime] NOT NULL,
[BeginOrigDate] [datetime] NOT NULL,
[ClaimTypeID] [tinyint] NULL,
[CodeID] [int] NULL,
[CountClaims] [int] NOT NULL,
[CountCodes] [int] NOT NULL,
[CountLines] [int] NOT NULL,
[CountProviders] [int] NOT NULL,
[DataRunID] [int] NOT NULL,
[DataSetID] [int] NOT NULL,
[DataSourceID] [int] NULL,
[Days] [smallint] NULL,
[DispenseID] [smallint] NULL,
[DSClaimID] [bigint] NULL,
[DSClaimLineID] [bigint] NOT NULL,
[DSEventID] [bigint] NOT NULL,
[DSMemberID] [bigint] NOT NULL,
[DSProviderID] [bigint] NULL,
[EndDate] [datetime] NULL,
[EndOrigDate] [datetime] NULL,
[EventBaseID] [bigint] NULL,
[EventCritID] [int] NULL,
[EventID] [int] NOT NULL,
[EventInfo] [xml] NULL,
[IsPaid] [bit] NOT NULL,
[IsSupplemental] [bit] NOT NULL CONSTRAINT [DF_Events_IsSupplemental] DEFAULT ((0)),
[IsXfer] [bit] NOT NULL,
[LogID] [bigint] NOT NULL IDENTITY(1, 1),
[LogTime] [datetime] NOT NULL CONSTRAINT [DF_Log_Events_LogTime] DEFAULT (getdate()),
[LogUser] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Log_Events_LogUser] DEFAULT (suser_sname()),
[OwnerID] [int] NOT NULL,
[Value] [decimal] (18, 6) NULL,
[XferID] [bigint] NULL
) ON [EVT] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Log].[Events] ADD CONSTRAINT [PK_Log_Events] PRIMARY KEY CLUSTERED  ([LogID]) ON [EVT]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Log_Events_BatchID] ON [Log].[Events] ([BatchID], [DataRunID], [DataSetID], [DSMemberID], [LogID]) ON [IDX5]
GO
CREATE NONCLUSTERED INDEX [IX_Log_Events_DSMemberID] ON [Log].[Events] ([DSMemberID], [DataRunID], [BatchID], [DataSetID], [OwnerID]) ON [IDX5]
GO
