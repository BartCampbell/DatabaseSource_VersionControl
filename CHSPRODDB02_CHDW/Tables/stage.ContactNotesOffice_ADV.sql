CREATE TABLE [stage].[ContactNotesOffice_ADV]
(
[CentauriContactNotesOfficeID] [int] NOT NULL,
[CentauriProjectID] [int] NULL,
[CentauriProviderOfficeID] [int] NULL,
[CentauriContactNoteID] [int] NULL,
[ContactNoteText] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CentauriUserID] [int] NULL,
[LastUpdated_Date] [smalldatetime] NULL,
[contact_num] [tinyint] NULL,
[followup] [date] NULL,
[IsResponded] [bit] NULL,
[IsViewedByScheduler] [bit] NULL,
[ClientID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL
) ON [PRIMARY]
GO
