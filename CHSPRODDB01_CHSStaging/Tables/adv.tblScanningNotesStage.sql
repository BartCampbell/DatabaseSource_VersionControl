CREATE TABLE [adv].[tblScanningNotesStage]
(
[ScanningNote_PK] [tinyint] NOT NULL,
[Note_Text] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsCNA] [bit] NOT NULL,
[LastUpdated] [smalldatetime] NULL,
[Client] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordSource] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL,
[CCI] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ScanningNotesHashKey] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClientHashKey] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CNI] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [adv].[tblScanningNotesStage] ADD CONSTRAINT [PK_tblScanningNotes] PRIMARY KEY CLUSTERED  ([ScanningNote_PK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
