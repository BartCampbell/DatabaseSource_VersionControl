CREATE TABLE [stage].[CCAI_Inhome Medical20170321]
(
[Last Name] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[First Name] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Member Number] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Provider] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DOS] [datetime] NULL,
[Provider Type ] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Provider NPI#] [float] NULL,
[Billing Name] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Billing Address] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Billing Address 2] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Billing City] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Billing State] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Billing Postal Code] [float] NULL,
[Tax ID#] [float] NULL,
[Billing NPI#] [float] NULL,
[CentauriProviderID] [int] NULL,
[DOB] [date] NULL,
[Gender] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Member_PK] [int] NULL,
[Provider_PK] [int] NULL,
[ProviderOffice_PK] [int] NULL,
[ProviderMaster_PK] [int] NULL,
[ChaseID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderLastName] [varchar] (75) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderFirstName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
