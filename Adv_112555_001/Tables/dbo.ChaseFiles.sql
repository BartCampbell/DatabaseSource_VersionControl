CREATE TABLE [dbo].[ChaseFiles]
(
[ChaseID] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Chart_File_Name] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Suspect_PK] [int] NOT NULL,
[IsProcessed] [int] NOT NULL
) ON [PRIMARY]
GO
