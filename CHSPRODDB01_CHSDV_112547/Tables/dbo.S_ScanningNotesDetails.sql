CREATE TABLE [dbo].[S_ScanningNotesDetails]
(
[S_ScanningNotesDetails_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LoadDate] [datetime] NULL,
[H_ScanningNotes_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Note_Text] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsCNA] [bit] NOT NULL,
[LastUpdated] [smalldatetime] NULL,
[HashDiff] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordEndDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[S_ScanningNotesDetails] ADD CONSTRAINT [PK_S_ScanningNotesDetails] PRIMARY KEY CLUSTERED  ([S_ScanningNotesDetails_RK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [NonClusteredIndex-20161003-081821] ON [dbo].[S_ScanningNotesDetails] ([HashDiff]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[S_ScanningNotesDetails] ADD CONSTRAINT [FK_H_ScanningNotes_RK1] FOREIGN KEY ([H_ScanningNotes_RK]) REFERENCES [dbo].[H_ScanningNotes] ([H_ScanningNotes_RK]) ON DELETE CASCADE ON UPDATE CASCADE
GO
