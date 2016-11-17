CREATE TABLE [dbo].[S_SessionLog]
(
[S_SessionLog_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LoadDate] [datetime] NULL,
[H_Session_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AccessedPage] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AccessedDate] [datetime] NULL,
[HashDiff] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordEndDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[S_SessionLog] ADD CONSTRAINT [PK_S_SessionLog] PRIMARY KEY CLUSTERED  ([S_SessionLog_RK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[S_SessionLog] ADD CONSTRAINT [FK_H_Session_RK1] FOREIGN KEY ([H_Session_RK]) REFERENCES [dbo].[H_Session] ([H_Session_RK]) ON DELETE CASCADE ON UPDATE CASCADE
GO
