CREATE TABLE [dbo].[LS_SuspectScanningNote]
(
[LS_SuspectScanningNote_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LoadDate] [datetime] NULL,
[L_SuspectUserScanningNotes_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dtInsert] [smalldatetime] NULL,
[HashDiff] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordEndDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LS_SuspectScanningNote] ADD CONSTRAINT [PK_LS_SuspectScanningNote] PRIMARY KEY CLUSTERED  ([LS_SuspectScanningNote_RK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LS_SuspectScanningNote] ADD CONSTRAINT [FK_L_SuspectUserScanningNotes_RK] FOREIGN KEY ([L_SuspectUserScanningNotes_RK]) REFERENCES [dbo].[L_SuspectUserScanningNotes] ([L_SuspectUserScanningNotes_RK]) ON DELETE CASCADE ON UPDATE CASCADE
GO
