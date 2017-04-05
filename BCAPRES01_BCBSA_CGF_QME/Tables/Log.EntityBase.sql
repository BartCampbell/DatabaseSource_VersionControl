CREATE TABLE [Log].[EntityBase]
(
[Allow] [bit] NOT NULL,
[BatchID] [int] NOT NULL,
[BeginDate] [datetime] NOT NULL,
[BeginOrigDate] [datetime] NULL,
[DateComparerID] [smallint] NULL,
[DateComparerInfo] [int] NULL,
[DateComparerLink] [int] NULL,
[DataRunID] [int] NOT NULL,
[DataSetID] [int] NOT NULL,
[DataSourceID] [int] NULL,
[Days] [int] NULL,
[DSMemberID] [bigint] NOT NULL,
[DSProviderID] [bigint] NULL,
[EndDate] [datetime] NULL,
[EndOrigDate] [datetime] NULL,
[EntityBaseID] [bigint] NULL,
[EntityBeginDate] [datetime] NULL,
[EntityCritID] [int] NOT NULL,
[EntityEndDate] [datetime] NULL,
[EntityID] [int] NOT NULL,
[IsForIndex] [bit] NULL,
[IsSupplemental] [bit] NOT NULL CONSTRAINT [DF_EntityBase_IsSupplemental] DEFAULT ((0)),
[Iteration] [tinyint] NOT NULL,
[LogID] [bigint] NOT NULL IDENTITY(1, 1),
[LogTime] [datetime] NOT NULL CONSTRAINT [DF_EntityBase_LogTime] DEFAULT (getdate()),
[LogUser] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_EntityBase_LogUser] DEFAULT (suser_sname()),
[OptionNbr] [tinyint] NOT NULL,
[OwnerID] [int] NOT NULL,
[Qty] [decimal] (12, 6) NOT NULL,
[QtyMax] [decimal] (12, 6) NULL,
[QtyMin] [decimal] (12, 6) NULL,
[QtyNoSupplemental] [decimal] (12, 6) NULL,
[RankOrder] [tinyint] NOT NULL,
[RowID] [bigint] NULL,
[SourceID] [bigint] NULL,
[SourceLinkID] [bigint] NULL
) ON [PRIMARY]
GO
ALTER TABLE [Log].[EntityBase] ADD CONSTRAINT [PK_Log_EntityBase] PRIMARY KEY CLUSTERED  ([LogID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Log_EntityBase_BatchID] ON [Log].[EntityBase] ([BatchID], [DataRunID], [DataSetID], [DSMemberID], [LogID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Log_EntityBase_DSMemberID] ON [Log].[EntityBase] ([DSMemberID], [DataRunID], [BatchID], [DataSetID], [OwnerID]) ON [PRIMARY]
GO
