CREATE TABLE [dbo].[S_ContactNotesOfficeDetail]
(
[S_ContactNotesOfficeDetail_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LoadDate] [datetime] NULL,
[H_ContactNotesOffice_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ContactNoteText] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastUpdated_Date] [smalldatetime] NULL,
[contact_num] [tinyint] NULL,
[followup] [date] NULL,
[IsResponded] [bit] NULL,
[IsViewedByScheduler] [bit] NULL,
[HashDiff] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordEndDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[S_ContactNotesOfficeDetail] ADD CONSTRAINT [PK_S_ContactNotesOfficeDetail] PRIMARY KEY CLUSTERED  ([S_ContactNotesOfficeDetail_RK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [NonClusteredIndex-20161003-081030] ON [dbo].[S_ContactNotesOfficeDetail] ([HashDiff]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[S_ContactNotesOfficeDetail] ADD CONSTRAINT [FK_H_ContactNotesOffice_RK] FOREIGN KEY ([H_ContactNotesOffice_RK]) REFERENCES [dbo].[H_ContactNotesOffice] ([H_ContactNotesOffice_RK]) ON DELETE CASCADE ON UPDATE CASCADE
GO
