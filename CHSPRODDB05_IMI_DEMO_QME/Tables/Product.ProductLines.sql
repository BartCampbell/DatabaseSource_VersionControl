CREATE TABLE [Product].[ProductLines]
(
[Abbrev] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[BitSeed] [tinyint] NULL,
[BitValue] AS (CONVERT([bigint],power(CONVERT([bigint],(2),(0)),isnull(CONVERT([smallint],[BitSeed],(0)),(-1))),(0))) PERSISTED,
[Descr] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ProductLineGuid] [uniqueidentifier] NOT NULL CONSTRAINT [DF_ProductLines_ProductLineGuid] DEFAULT (newid()),
[ProductLineID] [smallint] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [Product].[ProductLines] ADD CONSTRAINT [CK_ProductLines_BitSeed] CHECK (([BitSeed] IS NULL OR [BitSeed]>=(0) AND [BitSeed]<=(62)))
GO
ALTER TABLE [Product].[ProductLines] ADD CONSTRAINT [PK_ProductLines] PRIMARY KEY CLUSTERED  ([ProductLineID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_ProductLines_Abbrev] ON [Product].[ProductLines] ([Abbrev]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_ProductLines_BitSeed] ON [Product].[ProductLines] ([BitSeed]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_ProductLines_ProductLineGuid] ON [Product].[ProductLines] ([ProductLineGuid]) ON [PRIMARY]
GO
