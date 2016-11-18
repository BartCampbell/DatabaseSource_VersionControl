CREATE TABLE [dim].[Specialty]
(
[SpecialtyID] [int] NOT NULL IDENTITY(1, 1),
[SpecialtyCode] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderTypeDesc] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TaxonomyCode] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TaxonomyDesc] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dim].[Specialty] ADD CONSTRAINT [PK_SpecialtyID] PRIMARY KEY CLUSTERED  ([SpecialtyID]) ON [PRIMARY]
GO
