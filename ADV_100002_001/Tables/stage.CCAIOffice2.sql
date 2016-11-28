CREATE TABLE [stage].[CCAIOffice2]
(
[NPI] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Lastname] [varchar] (75) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Address] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ZipCode_PK] [int] NULL,
[ContactNumber] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FaxNumber] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderOffice_PK] [bigint] NOT NULL,
[Provider_PK] [bigint] NOT NULL
) ON [PRIMARY]
GO
