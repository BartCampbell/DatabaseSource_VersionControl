CREATE TABLE [oec].[AdvanceOECRaw_112549_NPIUpdate]
(
[ChaseID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OldProvider_PK] [int] NULL,
[OldProviderOffice_PK] [bigint] NOT NULL,
[ProviderMaster_PK] [bigint] NOT NULL,
[NPI_ProviderAddress] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ZipCode_PK] [int] NULL,
[AdvancePhone] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AdvanceFax] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NewProviderOffice_PK] [int] NULL,
[NewProvider_PK] [int] NULL
) ON [PRIMARY]
GO
