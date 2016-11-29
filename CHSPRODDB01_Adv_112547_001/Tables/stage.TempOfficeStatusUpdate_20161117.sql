CREATE TABLE [stage].[TempOfficeStatusUpdate_20161117]
(
[tblProviderOfficeStatus_Project_PK] [smallint] NOT NULL,
[tblProviderOfficeStatus_ProviderOffice_PK] [bigint] NOT NULL,
[tblProviderOfficeStatus_OfficeIssueStatus] [tinyint] NULL,
[OfficeIssueStatusText] [varchar] (27) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Bucket] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Address] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tblContactNotesOffice_ContactNotesOffice_PK] [int] NOT NULL,
[tblContactNotesOffice_Project_PK] [smallint] NULL,
[tblContactNotesOffice_Office_PK] [bigint] NULL,
[tblContactNotesOffice_ContactNote_PK] [smallint] NULL,
[tblContactNotesOffice_ContactNoteText] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tblContactNotesOffice_LastUpdated_User_PK] [smallint] NULL,
[tblContactNotesOffice_LastUpdated_Date] [smalldatetime] NULL,
[tblContactNotesOffice_contact_num] [tinyint] NULL,
[tblContactNotesOffice_followup] [date] NULL,
[tblContactNotesOffice_IsResponded] [bit] NULL,
[tblContactNotesOffice_IsViewedByScheduler] [bit] NULL
) ON [PRIMARY]
GO
