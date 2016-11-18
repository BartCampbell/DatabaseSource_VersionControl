CREATE TABLE [stage].[Provider]
(
[CentauriProviderID] [int] NOT NULL,
[LastName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FirstName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MiddleName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Prefix] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Suffix] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NPI] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TIN] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TINName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
