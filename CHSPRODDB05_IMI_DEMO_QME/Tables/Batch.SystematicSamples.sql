CREATE TABLE [Batch].[SystematicSamples]
(
[BitProductLines] [bigint] NOT NULL CONSTRAINT [DF_SystematicSamples_BitProductLines] DEFAULT ((0)),
[DataRunID] [int] NOT NULL,
[IsSysSampleAscending] [bit] NOT NULL,
[MeasureID] [int] NOT NULL,
[PayerID] [smallint] NULL,
[PopulationID] [int] NOT NULL,
[ProductClassID] [tinyint] NOT NULL,
[ProductLineID] [smallint] NOT NULL,
[SysSampleGuid] [uniqueidentifier] NOT NULL CONSTRAINT [DF_SystematicSamples_SysSampleGuid] DEFAULT (newid()),
[SysSampleID] [int] NOT NULL IDENTITY(1, 1),
[SysSampleRand] [decimal] (18, 6) NOT NULL,
[SysSampleRate] [decimal] (18, 6) NOT NULL,
[SysSampleSize] [smallint] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [Batch].[SystematicSamples] ADD CONSTRAINT [PK_SystematicSamples] PRIMARY KEY CLUSTERED  ([SysSampleID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_SystematicSamples] ON [Batch].[SystematicSamples] ([DataRunID], [PopulationID], [ProductClassID], [BitProductLines], [PayerID], [MeasureID], [ProductLineID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_SystematicSamples_SysSampleGuid] ON [Batch].[SystematicSamples] ([SysSampleGuid]) ON [PRIMARY]
GO
