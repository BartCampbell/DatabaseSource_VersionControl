CREATE TABLE [dbo].[FaxLogStatus]
(
[FaxLogStatusID] [int] NOT NULL,
[Description] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsSent] [bit] NOT NULL CONSTRAINT [DF_FaxLogStatus_IsSent] DEFAULT ((0)),
[IsReceived] [bit] NOT NULL CONSTRAINT [DF_FaxLogStatus_IsReceived] DEFAULT ((1)),
[FaxProc] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FaxLogStatus] ADD CONSTRAINT [PK_FaxLogStatus] PRIMARY KEY CLUSTERED  ([FaxLogStatusID]) ON [PRIMARY]
GO
