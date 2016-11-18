CREATE TABLE [fact].[IssueResponseOffice]
(
[IssueResponseOfficeID] [int] NOT NULL IDENTITY(1, 1),
[CentauriIssueResponseID] [int] NOT NULL,
[ContactNotesOfficeID] [int] NULL,
[UserID] [int] NULL,
[IssueResponse] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AdditionalResponse] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dtInsert] [smalldatetime] NULL,
[CreateDate] [datetime] NULL CONSTRAINT [DF_IssueResponseOffice_CreateDate] DEFAULT (getdate()),
[LastUpdate] [datetime] NULL CONSTRAINT [DF_ProviderIssueResponseOffice_LastUpdate] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [fact].[IssueResponseOffice] ADD CONSTRAINT [PK_IssueResponseOffice] PRIMARY KEY CLUSTERED  ([IssueResponseOfficeID]) ON [PRIMARY]
GO
ALTER TABLE [fact].[IssueResponseOffice] ADD CONSTRAINT [FK_IssueResponseOffice_ContactNotesOffice] FOREIGN KEY ([ContactNotesOfficeID]) REFERENCES [fact].[ContactNotesOffice] ([ContactNotesOfficeID])
GO
ALTER TABLE [fact].[IssueResponseOffice] ADD CONSTRAINT [FK_IssueResponseOffice_User] FOREIGN KEY ([UserID]) REFERENCES [dim].[User] ([UserID])
GO
