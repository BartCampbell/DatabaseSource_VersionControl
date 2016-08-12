CREATE TABLE [dbo].[tblContactNotesOffice]
(
[ContactNotesOffice_PK] [int] NOT NULL IDENTITY(1, 1),
[Project_PK] [smallint] NULL,
[Office_PK] [bigint] NULL,
[ContactNote_PK] [smallint] NULL,
[ContactNoteText] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastUpdated_User_PK] [smallint] NULL,
[LastUpdated_Date] [smalldatetime] NULL,
[contact_num] [tinyint] NULL CONSTRAINT [DF__tblContac__conta__46D27B73] DEFAULT ((1)),
[followup] [date] NULL,
[IsResponded] [bit] NULL,
[IsViewedByScheduler] [bit] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblContactNotesOffice] ADD CONSTRAINT [PK_tblContactNotesOffice] PRIMARY KEY CLUSTERED  ([ContactNotesOffice_PK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tblContactNotesOffice_ContactNote] ON [dbo].[tblContactNotesOffice] ([ContactNote_PK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_ContactNote_PK] ON [dbo].[tblContactNotesOffice] ([ContactNote_PK], [Office_PK], [Project_PK]) INCLUDE ([LastUpdated_Date]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_CNOPK_ProjPK_OfficePK] ON [dbo].[tblContactNotesOffice] ([ContactNotesOffice_PK], [Project_PK], [Office_PK]) INCLUDE ([LastUpdated_Date]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tblContactNotesOfficeUpdated] ON [dbo].[tblContactNotesOffice] ([LastUpdated_Date]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tblContactNotesOffice_Office] ON [dbo].[tblContactNotesOffice] ([Office_PK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tblContactNotesOffice_Project] ON [dbo].[tblContactNotesOffice] ([Project_PK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
