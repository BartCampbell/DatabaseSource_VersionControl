CREATE TABLE [stage].[MA_BlueTab_UpdateProvider]
(
[NewChaseID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OldChaseID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CLAIM_ID] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DOS_FromDate] [date] NULL,
[DOS_ThruDate] [date] NULL,
[CentauriProviderID] [int] NULL,
[ProviderID] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderNPI] [float] NULL,
[ProviderLastName] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Address] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ZipCode] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NewAddress] [bit] NULL,
[Phone] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Member_PK] [int] NULL,
[Project_PK] [int] NULL,
[ProviderMaster_PK] [int] NULL,
[ProviderOffice_PK] [int] NULL,
[Suspect_PK] [int] NULL,
[Provider_PK] [int] NULL,
[OldProviderMaster_PK] [int] NULL,
[OldProviderOffice_PK] [int] NULL,
[OldProvider_PK] [int] NULL
) ON [PRIMARY]
GO
