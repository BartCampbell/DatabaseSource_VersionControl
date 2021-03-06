CREATE TABLE [dbo].[ChaseStatus_Archive]
(
[ChaseStatusID] [int] NOT NULL IDENTITY(1, 1),
[ClientID] [int] NULL,
[ChaseID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Status] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Project] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FileName] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL,
[Duplicate] [bit] NULL
) ON [PRIMARY]
GO
