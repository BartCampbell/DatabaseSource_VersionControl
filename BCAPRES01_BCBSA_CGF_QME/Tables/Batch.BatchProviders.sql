CREATE TABLE [Batch].[BatchProviders]
(
[BatchID] [int] NOT NULL,
[DSProviderID] [bigint] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [Batch].[BatchProviders] ADD CONSTRAINT [PK_BatchProviders] PRIMARY KEY CLUSTERED  ([BatchID], [DSProviderID]) ON [PRIMARY]
GO
