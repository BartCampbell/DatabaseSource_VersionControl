CREATE TABLE [dbo].[ChaseFiles]
(
[ChaseID] [varchar] (20) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[Chart_File_Name] [varchar] (1000) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[Suspect_PK] [int] NOT NULL,
[IsProcessed] [int] NOT NULL
) ON [PRIMARY]
GO
