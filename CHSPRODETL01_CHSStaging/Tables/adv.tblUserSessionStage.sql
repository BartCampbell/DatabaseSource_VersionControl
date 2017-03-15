CREATE TABLE [adv].[tblUserSessionStage]
(
[Session_PK] [bigint] NOT NULL,
[User_PK] [smallint] NULL,
[SessionStart] [smalldatetime] NULL,
[SessionEnd] [smalldatetime] NULL,
[Client] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL CONSTRAINT [DF__tblUserSe__LoadD__3C417515] DEFAULT (getdate()),
[CCI] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SessionHashKey] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClientHashKey] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CSI] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UserSessionHashKey] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [adv].[tblUserSessionStage] ADD CONSTRAINT [PK_tblUserSessionStage] PRIMARY KEY CLUSTERED  ([Session_PK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
