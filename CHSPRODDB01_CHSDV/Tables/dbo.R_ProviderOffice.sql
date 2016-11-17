CREATE TABLE [dbo].[R_ProviderOffice]
(
[CentauriProviderOfficeID] [int] NOT NULL IDENTITY(1000009558, 1),
[NPI] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClientID] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClientProviderOfficeID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ChaseID] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderOfficeHashKey] AS (upper(CONVERT([char](32),hashbytes('MD5',upper(rtrim(ltrim(coalesce([CentauriProviderOfficeID],''))))),(2))))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[R_ProviderOffice] ADD CONSTRAINT [PK_CentauriProviderOffice] PRIMARY KEY CLUSTERED  ([CentauriProviderOfficeID]) ON [PRIMARY]
GO
