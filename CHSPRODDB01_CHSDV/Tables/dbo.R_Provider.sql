CREATE TABLE [dbo].[R_Provider]
(
[CentauriProviderID] [int] NOT NULL IDENTITY(1000481864, 1),
[NPI] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClientID] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClientProviderID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ChaseID] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProjectID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TIN] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderHashKey] AS (upper(CONVERT([char](32),hashbytes('MD5',upper(rtrim(ltrim(coalesce([CentauriProviderID],''))))),(2))))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[R_Provider] ADD CONSTRAINT [PK_CentauriProvider2] PRIMARY KEY CLUSTERED  ([CentauriProviderID]) ON [PRIMARY]
GO
