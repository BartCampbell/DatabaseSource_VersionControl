CREATE TYPE [dbo].[ProviderTableType] AS TABLE
(
[ClientID] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClientProviderID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NPI] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
)
GO
