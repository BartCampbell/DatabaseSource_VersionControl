CREATE TABLE [stage].[RenderingChases]
(
[Chase_ID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Member_ID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Claim_ID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderNPI] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderLastName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderFirstName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderAddress] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderZip] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderPhone] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderFax] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ChaseID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NPILocation] [int] NOT NULL,
[ProviderOffice_PK] [int] NULL,
[ProviderMaster_PK] [int] NULL,
[Provider_PK] [int] NULL,
[Member_PK] [int] NULL,
[Project_PK] [int] NULL,
[Suspect_PK] [int] NULL,
[AdvancePhone] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AdvanceFax] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DNC] [bit] NULL,
[Duplicate] [bit] NULL
) ON [PRIMARY]
GO
