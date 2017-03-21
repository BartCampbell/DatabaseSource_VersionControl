CREATE TABLE [stage].[badProviders]
(
[PrimaryProvider_ProviderName] [sys].[sysname] NULL,
[ProviderMaster_PK] [bigint] NULL,
[PrimaryProvider_UniqueID] [sys].[sysname] NULL,
[pin] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Firstname] [varchar] (75) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Lastname] [varchar] (75) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
