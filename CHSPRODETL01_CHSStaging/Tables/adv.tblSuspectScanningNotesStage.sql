CREATE TABLE [adv].[tblSuspectScanningNotesStage]
(
[ScanningNote_PK] [tinyint] NOT NULL,
[Suspect_PK] [bigint] NOT NULL,
[dtInsert] [smalldatetime] NULL,
[User_PK] [smallint] NULL,
[Client] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL CONSTRAINT [DF__tblSuspec__LoadD__275B66C8] DEFAULT (getdate()),
[CCI] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SuspectUserScanningNoteHashKey] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ScanningNoteHashKey] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SuspectHashKey] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UserHashKey] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CSI] [int] NULL,
[CUI] [int] NULL,
[CNI] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [adv].[tblSuspectScanningNotesStage] ADD CONSTRAINT [PK_tblSuspectScanningNotesStage] PRIMARY KEY CLUSTERED  ([ScanningNote_PK], [Suspect_PK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
