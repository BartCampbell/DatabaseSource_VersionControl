CREATE TABLE [adv].[tblSuspectDOSStage]
(
[SuspectDOS_PK] [bigint] NOT NULL,
[Suspect_PK] [bigint] NOT NULL,
[DOS_From] [smalldatetime] NULL,
[DOS_To] [smalldatetime] NULL,
[Client] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL,
[CCI] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [adv].[tblSuspectDOSStage] ADD CONSTRAINT [PK_tblSuspectDOSStage] PRIMARY KEY CLUSTERED  ([SuspectDOS_PK]) ON [PRIMARY]
GO
