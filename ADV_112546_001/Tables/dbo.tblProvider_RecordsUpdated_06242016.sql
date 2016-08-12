CREATE TABLE [dbo].[tblProvider_RecordsUpdated_06242016]
(
[Provider_PK] [bigint] NOT NULL,
[ProviderMaster_PK] [bigint] NULL,
[ProviderOffice_PK] [bigint] NULL,
[Fax] [varchar] (75) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ContactNumber] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Phone] [varchar] (75) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NPI] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NewProviderOffice_PK] [bigint] NOT NULL
) ON [PRIMARY]
GO
