CREATE TABLE [fact].[ContactNotesOffice]
(
[ContactNotesOfficeID] [int] NOT NULL IDENTITY(1, 1),
[CentauriContactNotesOfficeID] [int] NOT NULL,
[ProjectID] [int] NULL,
[CentauriProviderOfficeID] [int] NULL,
[ContactNoteID] [int] NULL,
[ContactNoteText] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UserID] [int] NULL,
[LastUpdated_Date] [smalldatetime] NULL,
[contact_num] [tinyint] NULL,
[followup] [date] NULL,
[IsResponded] [bit] NULL,
[IsViewedByScheduler] [bit] NULL,
[CreateDate] [datetime] NULL CONSTRAINT [DF_ContactNotesOffice_CreateDate] DEFAULT (getdate()),
[LastUpdate] [datetime] NULL CONSTRAINT [DF_ProviderContactNotesOffice_LastUpdate] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [fact].[ContactNotesOffice] ADD CONSTRAINT [PK_ContactNotesOffice] PRIMARY KEY CLUSTERED  ([ContactNotesOfficeID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_LastUpdatedDate] ON [fact].[ContactNotesOffice] ([LastUpdated_Date]) INCLUDE ([CentauriProviderOfficeID], [UserID]) ON [PRIMARY]
GO
ALTER TABLE [fact].[ContactNotesOffice] ADD CONSTRAINT [FK_ContactNotesOffice_ContactNote] FOREIGN KEY ([ContactNoteID]) REFERENCES [dim].[ContactNote] ([ContactNoteID])
GO
ALTER TABLE [fact].[ContactNotesOffice] ADD CONSTRAINT [FK_ContactNotesOffice_Project] FOREIGN KEY ([ProjectID]) REFERENCES [dim].[ADVProject] ([ProjectID])
GO
ALTER TABLE [fact].[ContactNotesOffice] ADD CONSTRAINT [FK_ContactNotesOffice_User] FOREIGN KEY ([UserID]) REFERENCES [dim].[User] ([UserID])
GO
