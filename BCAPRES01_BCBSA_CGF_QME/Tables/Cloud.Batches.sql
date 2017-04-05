CREATE TABLE [Cloud].[Batches]
(
[BatchID] [int] NOT NULL,
[EngineID] [int] NOT NULL,
[Identifier] AS (CONVERT([varchar](16),[dbo].[ConvertIntToHex]([EngineID],(0))+[dbo].[ConvertIntToHex]([BatchID],(0)),(0))) PERSISTED,
[IsCancelled] [bit] NOT NULL CONSTRAINT [DF_Batches_IsCancelled] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [Cloud].[Batches] ADD CONSTRAINT [PK_Batches_1] PRIMARY KEY CLUSTERED  ([BatchID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Cloud_Batches] ON [Cloud].[Batches] ([Identifier]) ON [PRIMARY]
GO
