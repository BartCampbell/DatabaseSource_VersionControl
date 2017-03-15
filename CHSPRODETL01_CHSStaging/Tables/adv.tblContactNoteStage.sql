CREATE TABLE [adv].[tblContactNoteStage]
(
[ContactNote_PK] [smallint] NOT NULL,
[ContactNote_Text] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsSystem] [bit] NULL,
[sortOrder] [smallint] NULL,
[IsIssue] [bit] NULL,
[IsCNA] [bit] NULL,
[IsFollowup] [bit] NULL,
[Followup_days] [tinyint] NULL,
[IsActive] [bit] NULL,
[IsCopyCenter] [bit] NULL,
[IsRetro] [bit] NULL,
[IsProspective] [bit] NULL,
[IsDataIssue] [bit] NULL,
[AllowedAttempts] [tinyint] NULL,
[Client] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL,
[CCI] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ContactNoteHashKey] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClientHashKey] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CNI] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [adv].[tblContactNoteStage] ADD CONSTRAINT [PK_tblContactNote] PRIMARY KEY CLUSTERED  ([ContactNote_PK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
