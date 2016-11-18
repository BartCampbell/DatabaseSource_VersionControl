CREATE TABLE [stage].[ProviderLocation_ADV]
(
[CentauriProviderOfficeID] [int] NOT NULL,
[Addr1] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Addr2] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[City] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[State] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Zip] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[County] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
