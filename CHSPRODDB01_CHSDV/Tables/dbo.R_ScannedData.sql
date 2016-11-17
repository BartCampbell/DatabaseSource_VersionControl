CREATE TABLE [dbo].[R_ScannedData]
(
[CentauriScannedDataID] [int] NOT NULL IDENTITY(101, 1),
[ClientID] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClientScannedDataID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [date] NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ScannedDataHashKey] AS (upper(CONVERT([char](32),hashbytes('MD5',upper(rtrim(ltrim(coalesce([CentauriScannedDataID],''))))),(2))))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[R_ScannedData] ADD CONSTRAINT [PK_R_ScannedData] PRIMARY KEY CLUSTERED  ([CentauriScannedDataID]) ON [PRIMARY]
GO
