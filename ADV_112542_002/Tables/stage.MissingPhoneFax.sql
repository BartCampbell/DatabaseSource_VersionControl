CREATE TABLE [stage].[MissingPhoneFax]
(
[CentauriProviderID] [int] NULL,
[ProviderNPI] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Phone] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Fax] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PMphone] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PMfax] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
