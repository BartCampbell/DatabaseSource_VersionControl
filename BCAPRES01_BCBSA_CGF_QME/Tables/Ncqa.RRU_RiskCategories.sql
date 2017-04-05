CREATE TABLE [Ncqa].[RRU_RiskCategories]
(
[Abbrev] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FromWeight] [decimal] (18, 4) NOT NULL,
[RiskCtgyGuid] [uniqueidentifier] NOT NULL CONSTRAINT [DF_RRU_RiskCategories_RiskCtgyGuid] DEFAULT (newid()),
[RiskCtgyID] [tinyint] NOT NULL,
[ToWeight] [decimal] (18, 4) NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [Ncqa].[RRU_RiskCategories] ADD CONSTRAINT [PK_Ncqa_RRU_RiskCategories] PRIMARY KEY CLUSTERED  ([RiskCtgyID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Ncqa_RRU_RiskCategories_Abbrev] ON [Ncqa].[RRU_RiskCategories] ([Abbrev]) ON [PRIMARY]
GO
