CREATE TABLE [dbo].[ProviderSite]
(
[ProviderSiteID] [int] NOT NULL IDENTITY(1, 1),
[CustomerProviderSiteID] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ProviderSiteName] [varchar] (75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Address1] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Address2] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[City] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[State] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Zip] [varchar] (9) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Phone] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Fax] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Contact] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[County] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TaxID] [varchar] (11) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OriginalAddress1] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OriginalAddress2] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OriginalCity] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OriginalState] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OriginalZip] [varchar] (9) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OriginalPhone] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OriginalFax] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OriginalContact] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OriginalCounty] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Changed] AS (CONVERT([bit],case  when isnull([Address1],'')<>isnull([OriginalAddress1],'') OR isnull([Address2],'')<>isnull([OriginalAddress2],'') OR isnull([City],'')<>isnull([OriginalCity],'') OR isnull([State],'')<>isnull([OriginalState],'') OR isnull([Zip],'')<>isnull([OriginalZip],'') OR isnull([Phone],'')<>isnull([OriginalPhone],'') OR isnull([Fax],'')<>isnull([OriginalFax],'') OR isnull([Contact],'')<>isnull([OriginalContact],'') OR isnull([County],'')<>isnull([OriginalCounty],'') then (1) else (0) end,(0))) PERSISTED,
[CreatedDate] [datetime] NOT NULL CONSTRAINT [DF_ProviderSite_CreatedDate] DEFAULT (getdate()),
[CreatedUser] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastChangedDate] [datetime] NOT NULL CONSTRAINT [DF_ProviderSite_LastChangedDate] DEFAULT (getdate()),
[LastChangedUser] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ProviderSite] ADD CONSTRAINT [PK_ProviderSite_1] PRIMARY KEY CLUSTERED  ([ProviderSiteID]) ON [PRIMARY]
GO
