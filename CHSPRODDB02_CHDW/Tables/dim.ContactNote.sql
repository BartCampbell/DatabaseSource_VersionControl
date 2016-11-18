CREATE TABLE [dim].[ContactNote]
(
[ContactNoteID] [int] NOT NULL IDENTITY(1, 1),
[CentauriContactNoteID] [int] NULL,
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
[CreateDate] [datetime] NULL CONSTRAINT [DF_ContactNote_CreateDate] DEFAULT (getdate()),
[LastUpdate] [datetime] NULL CONSTRAINT [DF_ContactNote_LastUpdate] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dim].[ContactNote] ADD CONSTRAINT [PK_ContactNote] PRIMARY KEY CLUSTERED  ([ContactNoteID]) ON [PRIMARY]
GO
