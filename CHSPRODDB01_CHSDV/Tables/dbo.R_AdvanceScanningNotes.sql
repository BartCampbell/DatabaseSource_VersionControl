CREATE TABLE [dbo].[R_AdvanceScanningNotes]
(
[CentauriScanningNotesID] [int] NOT NULL IDENTITY(10001, 1),
[ClientID] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClientScanningNotesID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ScanningNotesHashKey] AS (upper(CONVERT([char](32),hashbytes('MD5',upper(rtrim(ltrim(coalesce([CentauriScanningNotesID],''))))),(2))))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[R_AdvanceScanningNotes] ADD CONSTRAINT [PK_CentauriScanningNotesID] PRIMARY KEY CLUSTERED  ([CentauriScanningNotesID]) ON [PRIMARY]
GO
