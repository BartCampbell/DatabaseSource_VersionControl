CREATE TABLE [dbo].[tblSuspectIncompleteNotesLog]
(
[Suspect_PK] [bigint] NOT NULL,
[Note] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dtInsert] [smalldatetime] NULL,
[User_PK] [smallint] NULL,
[IncompleteNote_pk] [int] NULL,
[IsScheduler] [bit] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
