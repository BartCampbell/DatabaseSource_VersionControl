CREATE TABLE [dbo].[L_SuspectUserScanningNotes]
(
[L_SuspectUserScanningNotes_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[H_Suspect_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[H_User_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[H_ScanningNotes_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordEndDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[L_SuspectUserScanningNotes] ADD CONSTRAINT [PK_L_SuspectUserScanningNotes] PRIMARY KEY CLUSTERED  ([L_SuspectUserScanningNotes_RK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[L_SuspectUserScanningNotes] ADD CONSTRAINT [FK_H_ScanningNotes_RK2] FOREIGN KEY ([H_ScanningNotes_RK]) REFERENCES [dbo].[H_ScanningNotes] ([H_ScanningNotes_RK]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[L_SuspectUserScanningNotes] ADD CONSTRAINT [FK_H_Suspect_RK8] FOREIGN KEY ([H_Suspect_RK]) REFERENCES [dbo].[H_Suspect] ([H_Suspect_RK]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[L_SuspectUserScanningNotes] ADD CONSTRAINT [FK_H_User_RK15] FOREIGN KEY ([H_User_RK]) REFERENCES [dbo].[H_User] ([H_User_RK]) ON DELETE CASCADE ON UPDATE CASCADE
GO
