CREATE TABLE [dbo].[R_ProviderMaster]
(
[CentauriProviderMasterID] [int] NOT NULL IDENTITY(1000009558, 1),
[NPI] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClientID] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClientProviderMasterID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ChaseID] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderMasterHashKey] AS (upper(CONVERT([char](32),hashbytes('MD5',upper(rtrim(ltrim(coalesce([CentauriProviderMasterID],''))))),(2))))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[R_ProviderMaster] ADD CONSTRAINT [PK_CentauriProviderMaster] PRIMARY KEY CLUSTERED  ([CentauriProviderMasterID]) ON [PRIMARY]
GO
