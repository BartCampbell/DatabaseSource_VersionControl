CREATE TABLE [adv].[tblUserSessionLogStage]
(
[Session_PK] [bigint] NOT NULL,
[AccessedPage] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AccessedDate] [datetime] NULL,
[Client] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL CONSTRAINT [DF__tblUserSe__LoadD__2EFC8890] DEFAULT (getdate())
) ON [PRIMARY]
GO
