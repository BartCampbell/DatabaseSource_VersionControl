CREATE TABLE [Ncqa].[RRU_ADSCPrices]
(
[ADSCID] [smallint] NOT NULL,
[ADSCPriceGuid] [uniqueidentifier] NOT NULL CONSTRAINT [DF_RRU_ADSCPrices_ADSCPriceGuid] DEFAULT (newid()),
[ADSCPriceID] [int] NOT NULL IDENTITY(1, 1),
[IsAcute] [bit] NOT NULL,
[IsMajSurg] [bit] NOT NULL,
[LosGroupID] [tinyint] NOT NULL,
[MeasureSetID] [int] NOT NULL,
[Price] [decimal] (16, 4) NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [Ncqa].[RRU_ADSCPrices] ADD CONSTRAINT [PK_Ncqa_RRU_ADSCPrices] PRIMARY KEY CLUSTERED  ([ADSCPriceID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Ncqa_RRU_ADSCPrices_ADSCPriceGuid] ON [Ncqa].[RRU_ADSCPrices] ([ADSCPriceGuid]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Ncqa_RRU_ADSCPrices] ON [Ncqa].[RRU_ADSCPrices] ([MeasureSetID], [ADSCID], [LosGroupID], [IsAcute], [IsMajSurg]) ON [PRIMARY]
GO
