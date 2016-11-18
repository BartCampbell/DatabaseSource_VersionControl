CREATE TABLE [dim].[ScanningNotes]
(
[ScanningNotesID] [int] NOT NULL IDENTITY(1, 1),
[CentauriScanningNotesID] [int] NULL,
[Note_Text] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsCNA] [bit] NOT NULL,
[LastUpdated] [smalldatetime] NULL,
[CreateDate] [datetime] NULL CONSTRAINT [DF_ScanningNotes_CreateDate] DEFAULT (getdate()),
[LastUpdate] [datetime] NULL CONSTRAINT [DF_ScanningNotes_LastUpdate] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dim].[ScanningNotes] ADD CONSTRAINT [PK_ScanningNotes] PRIMARY KEY CLUSTERED  ([ScanningNotesID]) ON [PRIMARY]
GO
