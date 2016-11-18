CREATE TABLE [fact].[SuspectScanningNotes]
(
[SuspectScanningNotesID] [int] NOT NULL IDENTITY(1, 1),
[SuspectID] [int] NOT NULL,
[UserID] [int] NULL,
[ScanningNotesId] [int] NULL,
[dtInsert] [smalldatetime] NULL,
[CreateDate] [datetime] NULL CONSTRAINT [DF_SuspectScanningNotes_CreateDate] DEFAULT (getdate()),
[LastUpdate] [datetime] NULL CONSTRAINT [DF_ProviderSuspectScanningNotes_LastUpdate] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [fact].[SuspectScanningNotes] ADD CONSTRAINT [PK_SuspectScanningNotes] PRIMARY KEY CLUSTERED  ([SuspectScanningNotesID]) ON [PRIMARY]
GO
ALTER TABLE [fact].[SuspectScanningNotes] ADD CONSTRAINT [FK_SuspectScanningNotes_ScanningNotes] FOREIGN KEY ([ScanningNotesId]) REFERENCES [dim].[ScanningNotes] ([ScanningNotesID])
GO
ALTER TABLE [fact].[SuspectScanningNotes] ADD CONSTRAINT [FK_SuspectScanningNotes_Suspect] FOREIGN KEY ([SuspectID]) REFERENCES [fact].[Suspect] ([SuspectID])
GO
ALTER TABLE [fact].[SuspectScanningNotes] ADD CONSTRAINT [FK_SuspectScanningNotes_User] FOREIGN KEY ([UserID]) REFERENCES [dim].[User] ([UserID])
GO
