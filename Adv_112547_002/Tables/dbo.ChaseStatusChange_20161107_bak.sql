CREATE TABLE [dbo].[ChaseStatusChange_20161107_bak]
(
[ChaseID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OldChaseStatus_PK] [int] NULL,
[OldStatus] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NewStatus] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ChaseStatus_PK] [int] NOT NULL
) ON [PRIMARY]
GO
