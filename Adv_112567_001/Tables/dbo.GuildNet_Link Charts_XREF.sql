CREATE TABLE [dbo].[GuildNet_Link Charts_XREF]
(
[CLIENTID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PROJECTID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PDF_FILENAME] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ChaseID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Chart_File_Name] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Suspect_PK] [int] NULL,
[IsProcessed] [bit] NULL
) ON [PRIMARY]
GO
