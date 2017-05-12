CREATE TABLE [dbo].[R_MAO004Record]
(
[CentauriRecordID] [int] NOT NULL IDENTITY(100000, 1),
[ClientID] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EncounterICN] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MAO004HashKey] AS (upper(CONVERT([char](32),hashbytes('MD5',upper(rtrim(ltrim(coalesce([CentauriRecordID],''))))),(2))))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[R_MAO004Record] ADD CONSTRAINT [PK_CentauriMAO004Record] PRIMARY KEY CLUSTERED  ([CentauriRecordID]) ON [PRIMARY]
GO
