CREATE TABLE [Batch].[BatchItems]
(
[BatchID] [int] NOT NULL,
[BatchItemID] [bigint] NOT NULL IDENTITY(1, 1),
[DSMemberID] [bigint] NOT NULL,
[IsResult] [bit] NOT NULL CONSTRAINT [DF_BatchItems_IsResult] DEFAULT ((0)),
[MeasureID] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [Batch].[BatchItems] ADD CONSTRAINT [PK_BatchItems] PRIMARY KEY CLUSTERED  ([BatchItemID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_BatchItems_BatchID] ON [Batch].[BatchItems] ([BatchID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_BatchItems_Item] ON [Batch].[BatchItems] ([DSMemberID], [MeasureID], [BatchID]) ON [PRIMARY]
GO
