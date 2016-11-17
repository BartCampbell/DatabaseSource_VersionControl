CREATE TABLE [dbo].[H_ScanningNotes]
(
[H_ScanningNotes_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ScanningNotes_BK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClientScanningNotesID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[H_ScanningNotes] ADD CONSTRAINT [PK_H_ScanningNotes] PRIMARY KEY CLUSTERED  ([H_ScanningNotes_RK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
