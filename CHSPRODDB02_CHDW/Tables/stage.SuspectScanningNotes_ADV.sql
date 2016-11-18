CREATE TABLE [stage].[SuspectScanningNotes_ADV]
(
[CentauriSuspectID] [int] NOT NULL,
[CentauriUserID] [int] NULL,
[CentauriScanningNotesId] [int] NULL,
[dtInsert] [smalldatetime] NULL,
[ClientID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL
) ON [PRIMARY]
GO
