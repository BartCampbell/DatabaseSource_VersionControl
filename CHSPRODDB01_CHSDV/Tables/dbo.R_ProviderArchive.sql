CREATE TABLE [dbo].[R_ProviderArchive]
(
[CentauriProviderID] [int] NOT NULL,
[NPI] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClientID] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClientProviderID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ChaseID] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderHashKey] AS (upper(CONVERT([char](32),hashbytes('MD5',upper(rtrim(ltrim(coalesce([CentauriProviderID],''))))),(2))))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[R_ProviderArchive] ADD CONSTRAINT [PK_CentauriProviderArchive] PRIMARY KEY CLUSTERED  ([CentauriProviderID]) ON [PRIMARY]
GO
