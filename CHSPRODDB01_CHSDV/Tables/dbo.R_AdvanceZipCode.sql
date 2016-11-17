CREATE TABLE [dbo].[R_AdvanceZipCode]
(
[CentauriZipCodeID] [int] NOT NULL IDENTITY(1, 1),
[ClientID] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClientZipCodeID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ZipCodeHashKey] AS (upper(CONVERT([char](32),hashbytes('MD5',upper(rtrim(ltrim(coalesce([CentauriZipCodeID],''))))),(2))))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[R_AdvanceZipCode] ADD CONSTRAINT [PK_CentauriZipCodeID] PRIMARY KEY CLUSTERED  ([CentauriZipCodeID]) ON [PRIMARY]
GO
