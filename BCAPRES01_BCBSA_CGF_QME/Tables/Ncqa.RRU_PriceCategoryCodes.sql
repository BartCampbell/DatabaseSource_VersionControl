CREATE TABLE [Ncqa].[RRU_PriceCategoryCodes]
(
[Code] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CodeID] [int] NULL,
[CodeTypeID] [tinyint] NOT NULL,
[MeasureSetID] [int] NOT NULL,
[Modifier] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Price1] [decimal] (16, 4) NOT NULL CONSTRAINT [DF_RRU_PriceCategoryCodes_Price1] DEFAULT ((0)),
[Price2] [decimal] (16, 4) NOT NULL CONSTRAINT [DF_RRU_PriceCategoryCodes_Price2] DEFAULT ((0)),
[PriceCtgyCodeGuid] [uniqueidentifier] NOT NULL CONSTRAINT [DF_RRU_PriceCategoryCodes_PriceCtgyCodeGuid] DEFAULT (newid()),
[PriceCtgyCodeID] [int] NOT NULL IDENTITY(1, 1),
[PriceCtgyID] [tinyint] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [Ncqa].[RRU_PriceCategoryCodes] ADD CONSTRAINT [PK_Ncqa_RRU_PriceCategoryCodes] PRIMARY KEY CLUSTERED  ([PriceCtgyCodeID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Ncqa_RRU_PriceCategoryCodes] ON [Ncqa].[RRU_PriceCategoryCodes] ([MeasureSetID], [PriceCtgyID], [Code], [CodeTypeID], [Modifier]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Ncqa_RRU_PriceCategoryCodes_PriceCtgyCodeGuid] ON [Ncqa].[RRU_PriceCategoryCodes] ([PriceCtgyCodeGuid]) ON [PRIMARY]
GO
