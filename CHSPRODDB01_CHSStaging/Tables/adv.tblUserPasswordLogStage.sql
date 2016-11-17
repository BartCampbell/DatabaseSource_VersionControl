CREATE TABLE [adv].[tblUserPasswordLogStage]
(
[User_PK] [smallint] NULL,
[Password] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dtPassword] [date] NULL,
[Client] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL CONSTRAINT [DF__tblUserPa__LoadD__2A37D373] DEFAULT (getdate())
) ON [PRIMARY]
GO
