CREATE TABLE [dbo].[S_ContactNoteDetail]
(
[S_ContactNoteDetail_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LoadDate] [datetime] NULL,
[H_ContactNote_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
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
[HashDiff] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordEndDate] [datetime] NULL,
[ChaseStatus_PK] [int] NULL,
[IsContact] [bit] NULL,
[ContactNoteID] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsIssueLogResponse] [bit] NULL,
[ProviderOfficeSubBucket_PK] [tinyint] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[S_ContactNoteDetail] ADD CONSTRAINT [PK_S_ContactNoteDetail] PRIMARY KEY CLUSTERED  ([S_ContactNoteDetail_RK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [NonClusteredIndex-20161003-081332] ON [dbo].[S_ContactNoteDetail] ([HashDiff]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[S_ContactNoteDetail] ADD CONSTRAINT [FK_H_ContactNote_RK] FOREIGN KEY ([H_ContactNote_RK]) REFERENCES [dbo].[H_ContactNote] ([H_ContactNote_RK]) ON DELETE CASCADE ON UPDATE CASCADE
GO
