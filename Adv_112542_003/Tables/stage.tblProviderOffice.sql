CREATE TABLE [stage].[tblProviderOffice]
(
[ProviderOfficeID] [int] NOT NULL,
[ClientProviderID] [varchar] (20) COLLATE SQL_Latin1_General_CP437_CI_AI NOT NULL,
[Address] [varchar] (250) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[Zip] [int] NULL,
[ContactPerson] [varchar] (150) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[ContactNumber] [varchar] (120) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[FaxNumber] [varchar] (120) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[Email_Address] [varchar] (100) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[EMR_Type] [varchar] (50) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[GroupName] [varchar] (100) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[ProviderID] [varchar] (20) COLLATE SQL_Latin1_General_CP437_CI_AI NULL
) ON [PRIMARY]
GO
