CREATE TABLE [stage].[ScanningNotes_ADV]
(
[CentauriScanningNotesID] [int] NULL,
[Note_Text] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsCNA] [bit] NOT NULL,
[LastUpdated] [smalldatetime] NULL
) ON [PRIMARY]
GO
