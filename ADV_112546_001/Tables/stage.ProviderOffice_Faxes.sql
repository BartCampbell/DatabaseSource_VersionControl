CREATE TABLE [stage].[ProviderOffice_Faxes]
(
[ProviderOffice_PK] [bigint] NOT NULL,
[Address] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ZipCode_PK] [int] NULL,
[ContactPerson] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ContactNumber] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FaxNumber] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Email_Address] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EMR_Type] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EMR_Type_PK] [smallint] NULL,
[GroupName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Fax] [varchar] (75) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NPI] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
