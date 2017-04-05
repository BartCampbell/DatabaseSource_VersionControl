CREATE TABLE [Log].[Entities]
(
[BatchID] [int] NOT NULL,
[BeginDate] [datetime] NOT NULL,
[BeginOrigDate] [datetime] NULL,
[BitProductLines] [bigint] NOT NULL CONSTRAINT [DF_Entities_BitProductLines] DEFAULT ((0)),
[DataRunID] [int] NOT NULL,
[DataSetID] [int] NOT NULL,
[DataSourceID] [int] NULL,
[Days] [int] NULL,
[DSEntityID] [bigint] NOT NULL,
[DSMemberID] [bigint] NOT NULL,
[DSProviderID] [bigint] NULL,
[EndDate] [datetime] NULL,
[EndOrigDate] [datetime] NULL,
[EnrollGroupID] [int] NULL,
[EntityBaseID] [bigint] NULL,
[EntityCritID] [int] NULL,
[EntityID] [int] NOT NULL,
[EntityInfo] [xml] NULL,
[IsSupplemental] [bit] NOT NULL CONSTRAINT [DF_Entities_IsSupplemental] DEFAULT ((0)),
[Iteration] [int] NULL,
[LastSegBeginDate] [datetime] NULL,
[LastSegEndDate] [datetime] NULL,
[LogID] [bigint] NOT NULL IDENTITY(1, 1),
[LogTime] [datetime] NOT NULL CONSTRAINT [DF_Log_Entities_LogTime] DEFAULT (getdate()),
[LogUser] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Log_Entities_LogUser] DEFAULT (suser_sname()),
[OwnerID] [int] NOT NULL,
[Qty] [decimal] (12, 6) NULL,
[SourceID] [bigint] NULL,
[SourceLinkID] [bigint] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Log].[Entities] ADD CONSTRAINT [PK_Log_Entities] PRIMARY KEY CLUSTERED  ([LogID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Log_Entities_BatchID] ON [Log].[Entities] ([BatchID], [DataRunID], [DataSetID], [DSMemberID], [LogID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Log_Entities_DSMemberID] ON [Log].[Entities] ([DSMemberID], [DataRunID], [BatchID], [DataSetID], [OwnerID]) ON [PRIMARY]
GO
