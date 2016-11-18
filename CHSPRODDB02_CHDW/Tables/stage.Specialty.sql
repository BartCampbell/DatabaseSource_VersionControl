CREATE TABLE [stage].[Specialty]
(
[SpecialtyCode] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderTypeDesc] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TaxonomyCode] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TaxonomyDesc] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CreateDate] [datetime] NULL CONSTRAINT [DF_Specialty_CreateDate] DEFAULT (getdate()),
[LastUpdate] [datetime] NULL CONSTRAINT [DF_Specialty_LastUpdate] DEFAULT (getdate())
) ON [PRIMARY]
GO
