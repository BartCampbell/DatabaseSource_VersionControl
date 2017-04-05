CREATE TABLE [Measure].[QuantityComparers]
(
[Abbrev] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Descr] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[QtyComparerGuid] [uniqueidentifier] NOT NULL CONSTRAINT [DF_QuantityComparers_QtyComparerGuid] DEFAULT (newid()),
[QtyComparerID] [tinyint] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [Measure].[QuantityComparers] ADD CONSTRAINT [PK_QuantityComparers] PRIMARY KEY CLUSTERED  ([QtyComparerID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_QuantityComparers_Abbrev] ON [Measure].[QuantityComparers] ([Abbrev]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_QuantityComparers_QtyComparerGuid] ON [Measure].[QuantityComparers] ([QtyComparerGuid]) ON [PRIMARY]
GO
