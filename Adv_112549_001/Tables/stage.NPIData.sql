CREATE TABLE [stage].[NPIData]
(
[ChaseID] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MemberID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CentauriProviderID] [int] NULL,
[ProviderNPI] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Address] [varchar] (1001) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[City] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[State] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Zip] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Phone] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Fax] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastName] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FirstName] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Provider_PK] [int] NULL,
[ProviderOffice_PK] [int] NULL,
[ProviderMaster_PK] [int] NULL
) ON [PRIMARY]
GO
