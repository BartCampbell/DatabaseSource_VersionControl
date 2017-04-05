CREATE TABLE [imiETL].[MEI_Provider]
(
[RowID] [int] NOT NULL IDENTITY(1, 1),
[SourceTable] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SourceDB] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SourceSchema] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SystemProviderID] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderFullName] [varchar] (300) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderLastName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderFirstName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderDOB] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderGender] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderSSN] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NPI] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderTaxID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MasterEntityID] [uniqueidentifier] NULL,
[DateCreated] [datetime] NULL CONSTRAINT [DF__MEI_Provi__DateC__0B5CAFEA] DEFAULT (getdate()),
[ProviderMatchLogic] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
