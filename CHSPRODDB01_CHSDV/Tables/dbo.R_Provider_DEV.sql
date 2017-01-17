CREATE TABLE [dbo].[R_Provider_DEV]
(
[CentauriProviderID] [int] NOT NULL,
[NPI] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClientID] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClientProviderID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ChaseID] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProjectID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TIN] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime2] (3) NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderHashKey] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
