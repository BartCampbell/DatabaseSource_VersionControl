CREATE TABLE [stage].[DuplicateOffices]
(
[DupeProviderOffice_PK] [bigint] NOT NULL,
[Address] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BadPhone] [varchar] (120) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BadFax] [varchar] (120) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ContactNumber] [varchar] (120) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FaxNumber] [varchar] (120) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderOffice_PK] [bigint] NOT NULL
) ON [PRIMARY]
GO
