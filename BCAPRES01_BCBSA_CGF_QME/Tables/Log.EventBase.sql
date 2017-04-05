CREATE TABLE [Log].[EventBase]
(
[Allow] [bit] NOT NULL,
[BatchID] [int] NOT NULL,
[BeginDate] [datetime] NOT NULL,
[ClaimTypeID] [tinyint] NOT NULL,
[Code] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CodeID] [int] NULL,
[CodeTypeID] [tinyint] NULL,
[CountAllowed] [int] NULL,
[CountCriteria] [int] NULL,
[CountDenied] [int] NULL,
[DataRunID] [int] NOT NULL,
[DataSetID] [int] NOT NULL,
[DataSourceID] [int] NULL,
[Days] [int] NULL,
[DSClaimCodeID] [bigint] NULL,
[DSClaimID] [bigint] NULL,
[DSClaimLineID] [bigint] NULL,
[DSMemberID] [bigint] NOT NULL,
[DSProviderID] [bigint] NULL,
[EndDate] [datetime] NULL,
[EventBaseID] [bigint] NULL,
[EventCritID] [int] NOT NULL,
[EventID] [int] NOT NULL,
[EventTypeID] [tinyint] NOT NULL,
[HasDateReqs] [bit] NULL,
[HasEnrollReqs] [bit] NULL,
[HasMemberReqs] [bit] NULL,
[HasProviderReqs] [bit] NULL,
[IsPaid] [bit] NOT NULL,
[IsSupplemental] [bit] NOT NULL CONSTRAINT [DF_EventBase_IsSupplemental] DEFAULT ((0)),
[LogID] [bigint] NOT NULL IDENTITY(1, 1),
[LogTime] [datetime] NOT NULL CONSTRAINT [DF_Log_EventBase_LogTime] DEFAULT (getdate()),
[LogUser] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Log_EventBase_LogUser] DEFAULT (suser_sname()),
[OptionNbr] [tinyint] NOT NULL,
[OwnerID] [int] NOT NULL,
[RankOrder] [smallint] NOT NULL,
[RowID] [bigint] NOT NULL,
[Value] [decimal] (18, 6) NULL
) ON [PRIMARY]
GO
ALTER TABLE [Log].[EventBase] ADD CONSTRAINT [PK_Log_EventBase] PRIMARY KEY CLUSTERED  ([LogID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Log_EventBase_BatchID] ON [Log].[EventBase] ([BatchID], [DataRunID], [DataSetID], [DSMemberID], [LogID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Log_EventBase_DSMemberID] ON [Log].[EventBase] ([DSMemberID], [DataRunID], [BatchID], [DataSetID], [OwnerID]) ON [PRIMARY]
GO
