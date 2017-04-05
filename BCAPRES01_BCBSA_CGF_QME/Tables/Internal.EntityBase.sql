CREATE TABLE [Internal].[EntityBase]
(
[Allow] [bit] NOT NULL,
[BatchID] [int] NOT NULL,
[BeginDate] [datetime] NOT NULL,
[BeginOrigDate] [datetime] NOT NULL,
[DataRunID] [int] NOT NULL,
[DataSetID] [int] NOT NULL,
[DataSourceID] [int] NOT NULL,
[DateComparerID] [smallint] NOT NULL,
[DateComparerInfo] [int] NOT NULL,
[DateComparerLink] [int] NULL,
[Days] [int] NULL,
[DSMemberID] [bigint] NOT NULL,
[DSProviderID] [bigint] NULL,
[EndDate] [datetime] NULL,
[EndOrigDate] [datetime] NULL,
[EntityBaseID] [bigint] NULL,
[EntityBeginDate] [datetime] NOT NULL,
[EntityCritID] [int] NOT NULL,
[EntityEndDate] [datetime] NOT NULL,
[EntityEnrollInfo] [xml] NULL,
[EntityID] [int] NOT NULL,
[EntityInfo] [xml] NULL,
[EntityLinkInfo] [xml] NULL,
[EntityQtyInfo] [xml] NULL,
[IsForIndex] [bit] NULL,
[IsSupplemental] [bit] NOT NULL CONSTRAINT [DF_EntityBase_IsSupplemental] DEFAULT ((0)),
[OptionNbr] [tinyint] NOT NULL,
[Qty] [decimal] (12, 6) NOT NULL,
[QtyMax] [decimal] (12, 6) NOT NULL,
[QtyMin] [decimal] (12, 6) NOT NULL,
[QtyNoSupplemental] [decimal] (12, 6) NOT NULL CONSTRAINT [DF_EntityBase_QtyNoSupplemental] DEFAULT ((0)),
[RankOrder] [tinyint] NOT NULL,
[RowID] [bigint] NOT NULL IDENTITY(1, 1),
[SourceID] [bigint] NULL,
[SourceLinkID] [bigint] NULL,
[SpId] [int] NOT NULL CONSTRAINT [DF_EntityBase_SpId] DEFAULT (@@spid)
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Internal].[EntityBase] ADD CONSTRAINT [PK_Internal_EntityBase] PRIMARY KEY CLUSTERED  ([RowID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Internal_EntityBase] ON [Internal].[EntityBase] ([EntityBaseID], [OptionNbr], [RankOrder], [SourceID], [SpId]) ON [PRIMARY]
GO
