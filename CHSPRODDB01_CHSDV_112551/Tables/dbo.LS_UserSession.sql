CREATE TABLE [dbo].[LS_UserSession]
(
[LS_UserSession_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LoadDate] [datetime] NULL,
[L_UserSession_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SessionStart] [datetime] NULL,
[SesssionEnd] [datetime] NULL,
[HashDiff] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordEndDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LS_UserSession] ADD CONSTRAINT [PK_LS_UserSession] PRIMARY KEY CLUSTERED  ([LS_UserSession_RK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LS_UserSession] ADD CONSTRAINT [FK_L_UserSession_RK] FOREIGN KEY ([L_UserSession_RK]) REFERENCES [dbo].[L_UserSession] ([L_UserSession_RK]) ON DELETE CASCADE ON UPDATE CASCADE
GO
