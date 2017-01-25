CREATE TABLE [Product].[Benefits]
(
[Abbrev] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[BenefitGuid] [uniqueidentifier] NOT NULL CONSTRAINT [DF_Benefits_BenefitGuid] DEFAULT (newid()),
[BenefitID] [smallint] NOT NULL,
[BitSeed] [tinyint] NULL,
[BitValue] AS (CONVERT([bigint],power(CONVERT([bigint],(2),(0)),isnull(CONVERT([smallint],[BitSeed],(0)),(-1))),(0))) PERSISTED,
[Descr] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[IsParent] AS ([Product].[IsParentBenefit]([BenefitID]))
) ON [PRIMARY]
GO
ALTER TABLE [Product].[Benefits] ADD CONSTRAINT [CK_Benefits_BitSeed] CHECK ((([BitSeed]>=(0) AND [BitSeed]<=(62)) OR [BitSeed] IS NULL))
GO
ALTER TABLE [Product].[Benefits] ADD CONSTRAINT [PK_Benefits] PRIMARY KEY CLUSTERED  ([BenefitID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Benefits_Abbrev] ON [Product].[Benefits] ([Abbrev]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Benefits_BenefitGuid] ON [Product].[Benefits] ([BenefitGuid]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Benefits_BitSeed] ON [Product].[Benefits] ([BitSeed]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Benefits_Descr] ON [Product].[Benefits] ([Descr]) ON [PRIMARY]
GO
