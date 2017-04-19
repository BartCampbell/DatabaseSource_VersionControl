CREATE TABLE [dbo].[FHN_Provider_Stage]
(
[Report To ID] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Network Name] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderType Description] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Provider Type Code] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Provider Name] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Primary Specialty] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Specialty Type Code] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NPI] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[VidaProID] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Address] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Zip Code] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[County] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[City] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[State] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CentauriProviderID] [bigint] NULL,
[FileName] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Phone] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Fax] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HashKey] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL,
[CentauriNetworkID] [bigint] NULL
) ON [PRIMARY]
GO
