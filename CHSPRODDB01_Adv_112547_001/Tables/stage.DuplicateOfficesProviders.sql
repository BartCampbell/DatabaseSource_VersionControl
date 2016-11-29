CREATE TABLE [stage].[DuplicateOfficesProviders]
(
[DupeProviderOffice_PK] [bigint] NOT NULL,
[Address] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Provider_ID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BadProvider_PK] [bigint] NOT NULL,
[BadPhone] [varchar] (120) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BadFax] [varchar] (120) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ContactNumber] [varchar] (120) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FaxNumber] [varchar] (120) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderOffice_PK] [bigint] NOT NULL,
[Provider_PK] [bigint] NOT NULL,
[OnlyProviderAtOffice] [bit] NULL,
[AdvancePhone] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AdvanceFax] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
