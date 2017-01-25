CREATE TABLE [Internal].[Entities]
(
[BatchID] [int] NOT NULL,
[BeginDate] [datetime] NOT NULL,
[BeginOrigDate] [datetime] NOT NULL,
[BitProductLines] [bigint] NOT NULL CONSTRAINT [DF_Entities_BitProductLines] DEFAULT ((0)),
[DataRunID] [int] NOT NULL,
[DataSetID] [int] NOT NULL,
[DataSourceID] [int] NOT NULL,
[Days] [int] NULL,
[DSEntityID] [bigint] NOT NULL IDENTITY(1, 1),
[DSMemberID] [bigint] NOT NULL,
[DSProviderID] [bigint] NULL,
[EndDate] [datetime] NULL,
[EndOrigDate] [datetime] NULL,
[EnrollGroupID] [int] NULL,
[EntityBaseID] [bigint] NULL,
[EntityCritID] [int] NOT NULL,
[EntityID] [int] NOT NULL,
[EntityInfo] [xml] NULL,
[IsSupplemental] [bit] NOT NULL CONSTRAINT [DF_Entities_IsSupplemental] DEFAULT ((0)),
[Iteration] [int] NULL,
[LastSegBeginDate] [datetime] NULL,
[LastSegEndDate] [datetime] NULL,
[Qty] [decimal] (12, 6) NULL,
[SourceID] [bigint] NULL,
[SourceLinkID] [bigint] NULL,
[SpId] [int] NOT NULL CONSTRAINT [DF_Entities_SpId] DEFAULT (@@spid)
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Internal].[Entities] ADD CONSTRAINT [PK_Entities] PRIMARY KEY CLUSTERED  ([DSEntityID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Temp_Entities] ON [Internal].[Entities] ([DSMemberID], [EndDate], [BeginDate], [EntityID], [DSProviderID], [SpId]) INCLUDE ([DSEntityID]) ON [PRIMARY]
GO
