CREATE TABLE [stage].[ProviderOffice_ADV]
(
[CentauriProviderOfficeID] [int] NOT NULL,
[CentauriProviderID] [int] NOT NULL,
[ClientID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
