CREATE TABLE [dbo].[tblSuspectIncompleteNotes]
(
[Suspect_PK] [bigint] NOT NULL,
[Note] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dtInsert] [smalldatetime] NULL,
[User_PK] [smallint] NULL,
[IncompleteNote_pk] [tinyint] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
