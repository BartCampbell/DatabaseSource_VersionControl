CREATE TABLE [dbo].[R_AdvanceProject]
(
[CentauriProjectID] [int] NOT NULL IDENTITY(10001, 1),
[ClientID] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClientProjectID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProjectHashKey] AS (upper(CONVERT([char](32),hashbytes('MD5',upper(rtrim(ltrim(coalesce([CentauriProjectID],''))))),(2))))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[R_AdvanceProject] ADD CONSTRAINT [PK_CentauriProjectID] PRIMARY KEY CLUSTERED  ([CentauriProjectID]) ON [PRIMARY]
GO
