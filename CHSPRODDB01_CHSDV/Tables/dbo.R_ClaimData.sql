CREATE TABLE [dbo].[R_ClaimData]
(
[CentauriClaimDataID] [int] NOT NULL IDENTITY(101, 1),
[ClientID] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClientClaimDataID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [date] NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClaimDataHashKey] AS (upper(CONVERT([char](32),hashbytes('MD5',upper(rtrim(ltrim(coalesce([CentauriClaimDataID],''))))),(2))))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[R_ClaimData] ADD CONSTRAINT [PK_R_ClaimData] PRIMARY KEY CLUSTERED  ([CentauriClaimDataID]) ON [PRIMARY]
GO
