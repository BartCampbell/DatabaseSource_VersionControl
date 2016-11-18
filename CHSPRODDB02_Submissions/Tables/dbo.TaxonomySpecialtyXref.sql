CREATE TABLE [dbo].[TaxonomySpecialtyXref]
(
[SpecialtyCode] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderTypeDesc] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TaxonomyCode] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TaxonomyDesc] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[XrefID] [int] NOT NULL IDENTITY(1, 1),
[EffectiveFrom] [datetime] NULL,
[EffectiveThru] [datetime] NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_TaxonomySpecialtyXref] ON [dbo].[TaxonomySpecialtyXref] ([XrefID]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
