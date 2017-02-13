CREATE TABLE [dbo].[ChartIntakeMapping2]
(
[RecID] [int] NOT NULL IDENTITY(1, 1),
[Chart_File_Name] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ChaseID] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Vendor] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DateReceived] [datetime] NULL,
[Suspect_PK] [int] NULL,
[IsProcessed] [bit] NULL
) ON [PRIMARY]
GO
