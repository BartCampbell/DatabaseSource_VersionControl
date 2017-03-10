CREATE TABLE [dbo].[FaxLogStatus_Backup]
(
[FaxLogStatusID] [int] NOT NULL,
[Description] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsSent] [bit] NOT NULL,
[IsReceived] [bit] NOT NULL,
[FaxProc] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
