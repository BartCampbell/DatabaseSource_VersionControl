CREATE TABLE [dbo].[H_Session]
(
[H_Session_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Session_BK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClientSessionID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL CONSTRAINT [DF__H_Session__LoadD__245D67DE] DEFAULT (getdate()),
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[H_Session] ADD CONSTRAINT [PK_H_Session] PRIMARY KEY CLUSTERED  ([H_Session_RK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
