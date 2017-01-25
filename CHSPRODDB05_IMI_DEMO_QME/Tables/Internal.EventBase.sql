CREATE TABLE [Internal].[EventBase]
(
[Allow] [bit] NOT NULL,
[BatchID] [int] NOT NULL,
[BeginDate] [datetime] NOT NULL,
[BitClaimAttribs] [bigint] NOT NULL CONSTRAINT [DF_EventBase_BitClaimAttribs] DEFAULT ((0)),
[BitClaimSrcTypes] [bigint] NOT NULL CONSTRAINT [DF_EventBase_BitClaimSrcTypes] DEFAULT ((0)),
[BitSpecialties] [bigint] NOT NULL CONSTRAINT [DF_EventBase_BitSpecialties] DEFAULT ((0)),
[ClaimTypeID] [tinyint] NOT NULL,
[Code] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CodeID] [int] NULL,
[CodeTypeID] [tinyint] NULL,
[CountAllowed] [int] NULL,
[CountCriteria] [int] NULL,
[CountDenied] [int] NULL,
[DataRunID] [int] NOT NULL,
[DataSetID] [int] NOT NULL,
[DataSourceID] [int] NOT NULL,
[Days] [smallint] NULL,
[DSClaimCodeID] [bigint] NULL,
[DSClaimID] [bigint] NULL,
[DSClaimLineID] [bigint] NULL,
[DSMemberID] [bigint] NOT NULL,
[DSProviderID] [bigint] NULL,
[EndDate] [datetime] NULL,
[EventBaseID] [bigint] NOT NULL,
[EventCritID] [int] NOT NULL,
[EventID] [int] NOT NULL,
[EventTypeID] [tinyint] NOT NULL,
[HasCodeReqs] [bit] NULL,
[HasDateReqs] [bit] NULL,
[HasEnrollReqs] [bit] NULL,
[HasMemberReqs] [bit] NULL,
[HasProviderReqs] [bit] NULL,
[IsPaid] [bit] NOT NULL CONSTRAINT [DF_EventBase_IsPaid] DEFAULT ((0)),
[IsSupplemental] [bit] NOT NULL,
[OptionNbr] [tinyint] NOT NULL,
[RankOrder] [smallint] NOT NULL,
[RowID] [bigint] NOT NULL IDENTITY(1, 1),
[SpId] [int] NOT NULL CONSTRAINT [DF_EventBase_SpId] DEFAULT (@@spid),
[Value] [decimal] (18, 6) NULL
) ON [PRIMARY]
GO
ALTER TABLE [Internal].[EventBase] ADD CONSTRAINT [PK_Internal_EventBase] PRIMARY KEY CLUSTERED  ([SpId], [EventBaseID], [RankOrder]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Internal_EventBase_EventTypeID] ON [Internal].[EventBase] ([SpId], [EventTypeID]) INCLUDE ([BeginDate], [DSClaimID], [DSClaimLineID], [DSMemberID], [DSProviderID], [EndDate]) ON [PRIMARY]
GO
