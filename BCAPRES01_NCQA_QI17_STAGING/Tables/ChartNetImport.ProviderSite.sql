CREATE TABLE [ChartNetImport].[ProviderSite]
(
[ProviderSiteID] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CustomerProviderID] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderSiteName] [varchar] (75) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Address1] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Address2] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[City] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[State] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Zip] [varchar] (9) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Phone] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Fax] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Contact] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[County] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TaxID] [varchar] (11) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [ChartNetImport].[ProviderSite] ADD CONSTRAINT [PK_ProviderSite] PRIMARY KEY CLUSTERED  ([ProviderSiteID]) ON [PRIMARY]
GO
