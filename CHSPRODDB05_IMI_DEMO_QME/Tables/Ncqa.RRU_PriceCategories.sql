CREATE TABLE [Ncqa].[RRU_PriceCategories]
(
[Abbrev] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Descr] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ParentID] [tinyint] NULL,
[PriceCtgyGuid] [uniqueidentifier] NOT NULL CONSTRAINT [DF_RRU_PriceCategories_PriceCtgyGuid] DEFAULT (newid()),
[PriceCtgyID] [tinyint] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [Ncqa].[RRU_PriceCategories] ADD CONSTRAINT [PK_Ncqa_RRU_PriceCategories] PRIMARY KEY CLUSTERED  ([PriceCtgyID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Ncqa_RRU_PriceCategories_Abbrev] ON [Ncqa].[RRU_PriceCategories] ([Abbrev]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Ncqa_RRU_PriceCategories_PriceCtgyGuid] ON [Ncqa].[RRU_PriceCategories] ([PriceCtgyGuid]) ON [PRIMARY]
GO
