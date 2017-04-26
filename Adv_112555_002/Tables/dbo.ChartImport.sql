CREATE TABLE [dbo].[ChartImport]
(
[RecID] [int] NOT NULL IDENTITY(1, 1),
[Extract_Date] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Chart_ID] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Database] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Client_Member_ID] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Chart_File_Name] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ReceivedDate] [datetime] NULL,
[Suspect_PK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Vendor] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsProcessed] [bit] NULL,
[IsInProcess] [bit] NULL
) ON [PRIMARY]
GO
