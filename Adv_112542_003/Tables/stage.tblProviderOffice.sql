CREATE TABLE [stage].[tblProviderOffice]
(
[ProviderOfficeID] [int] NOT NULL,
[ClientProviderID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Address] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Zip] [int] NULL,
[ContactPerson] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ContactNumber] [varchar] (120) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FaxNumber] [varchar] (120) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Email_Address] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EMR_Type] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[GroupName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
