CREATE TABLE [dbo].[tblContactNotesOfficeArc_BAK]
(
[ContactNotesOffice_PK] [int] NOT NULL,
[Project_PK] [smallint] NULL,
[Office_PK] [bigint] NULL,
[ContactNote_PK] [smallint] NULL,
[ContactNoteText] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastUpdated_User_PK] [smallint] NULL,
[LastUpdated_Date] [smalldatetime] NULL,
[contact_num] [tinyint] NULL,
[followup] [date] NULL,
[IsResponded] [bit] NULL,
[IsViewedByScheduler] [bit] NULL,
[IsRemoved] [bit] NULL,
[IsHide] [bit] NULL
) ON [PRIMARY]
GO
