CREATE TABLE [Internal].[EntityKey]
(
[BatchID] [int] NOT NULL,
[DataRunID] [int] NOT NULL,
[DataSetID] [int] NOT NULL,
[EntityID] [int] NOT NULL,
[SpId] [int] NOT NULL CONSTRAINT [DF_EntityKey_SpId] DEFAULT (@@spid)
) ON [PRIMARY]
GO
ALTER TABLE [Internal].[EntityKey] ADD CONSTRAINT [PK_Internal_EntityKey] PRIMARY KEY CLUSTERED  ([SpId], [EntityID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Internal_EntityKey] ON [Internal].[EntityKey] ([BatchID], [EntityID]) ON [PRIMARY]
GO
