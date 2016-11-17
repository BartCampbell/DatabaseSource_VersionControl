CREATE TABLE [dbo].[R_ExtractionQueue]
(
[CentauriExtractionQueueID] [int] NOT NULL IDENTITY(10001, 1),
[ClientID] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClientExtractionQueueID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ExtractionQueueHashKey] AS (upper(CONVERT([char](32),hashbytes('MD5',upper(rtrim(ltrim(coalesce([CentauriExtractionQueueID],''))))),(2))))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[R_ExtractionQueue] ADD CONSTRAINT [PK_CentauriExtractionQueueID] PRIMARY KEY CLUSTERED  ([CentauriExtractionQueueID]) ON [PRIMARY]
GO
