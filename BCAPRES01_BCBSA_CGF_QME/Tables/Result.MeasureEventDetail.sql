CREATE TABLE [Result].[MeasureEventDetail]
(
[BatchID] [int] NOT NULL,
[BeginDate] [datetime] NOT NULL,
[ClaimNum] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClaimTypeID] [tinyint] NULL,
[Code] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CodeID] [int] NULL,
[CodeType] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DataRunID] [int] NOT NULL,
[DataSetID] [int] NOT NULL,
[DataSourceID] [int] NULL,
[Descr] [nvarchar] (2048) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DescrHtml] [nvarchar] (2048) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DSClaimLineID] [bigint] NULL,
[DSEntityID] [bigint] NOT NULL,
[DSEventID] [bigint] NULL,
[DSMemberID] [bigint] NOT NULL,
[DSProviderID] [bigint] NULL,
[EndDate] [datetime] NULL,
[EntityDescr] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[EntityID] [int] NOT NULL,
[EventBaseID] [bigint] NULL,
[EventDescr] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EventID] [int] NULL,
[Iteration] [tinyint] NOT NULL,
[IsSupplmental] [bit] NOT NULL CONSTRAINT [DF_MeasureEventDetail_IsSupplmental] DEFAULT ((0)),
[KeyDate] [datetime] NOT NULL,
[MapTypeID] [tinyint] NOT NULL,
[MeasureID] [int] NOT NULL,
[MeasureXrefID] [int] NULL,
[MetricID] [int] NOT NULL,
[MetricXrefID] [int] NULL,
[ResultDate] [datetime] NOT NULL CONSTRAINT [DF_MeasureEventDetail_ResultDate] DEFAULT (getdate()),
[ResultRowGuid] [uniqueidentifier] NOT NULL CONSTRAINT [DF_MeasureEventDetail_ResultRowGuid] DEFAULT (newid()),
[ResultRowID] [bigint] NOT NULL IDENTITY(1, 1),
[ResultTypeID] [tinyint] NOT NULL,
[ReviewDate] [datetime] NULL,
[ReviewerID] [int] NULL,
[ServDate] [datetime] NOT NULL
) ON [RES]
GO
ALTER TABLE [Result].[MeasureEventDetail] ADD CONSTRAINT [PK_MeasureEventDetail] PRIMARY KEY CLUSTERED  ([ResultRowID]) ON [RES]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_MeasureEventDetail_BatchID] ON [Result].[MeasureEventDetail] ([BatchID], [DataRunID], [DataSetID], [DSMemberID], [ResultRowGuid]) ON [IDX7]
GO
CREATE NONCLUSTERED INDEX [IX_MeasureEventDetail_DSMemberID] ON [Result].[MeasureEventDetail] ([DSMemberID], [MetricID], [KeyDate], [DataRunID]) ON [IDX7]
GO
