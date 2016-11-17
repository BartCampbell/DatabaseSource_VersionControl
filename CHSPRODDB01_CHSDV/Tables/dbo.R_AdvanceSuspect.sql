CREATE TABLE [dbo].[R_AdvanceSuspect]
(
[CentauriSuspectID] [int] NOT NULL IDENTITY(10001, 1),
[ClientID] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClientSuspectID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SuspectHashKey] AS (upper(CONVERT([char](32),hashbytes('MD5',upper(rtrim(ltrim(coalesce([CentauriSuspectID],''))))),(2))))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[R_AdvanceSuspect] ADD CONSTRAINT [PK_CentauriSuspectID] PRIMARY KEY CLUSTERED  ([CentauriSuspectID]) ON [PRIMARY]
GO
