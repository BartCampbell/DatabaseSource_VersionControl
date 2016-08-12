CREATE TABLE [stage].[NewProviderOffice]
(
[ProviderOffice_PK] [int] NOT NULL,
[NPI] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClientProviderID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Advance_Addr1] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Advance_Zip] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Phone] [varchar] (75) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Fax] [varchar] (75) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CurrentPhone] [varchar] (75) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
