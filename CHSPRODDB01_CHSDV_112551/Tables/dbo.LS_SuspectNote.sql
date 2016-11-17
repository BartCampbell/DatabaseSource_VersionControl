CREATE TABLE [dbo].[LS_SuspectNote]
(
[LS_SuspectNote_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LoadDate] [datetime] NULL,
[L_SuspectUserNote_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Coded_Date] [smalldatetime] NULL,
[HashDiff] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordEndDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LS_SuspectNote] ADD CONSTRAINT [PK_LS_SuspectNote] PRIMARY KEY CLUSTERED  ([LS_SuspectNote_RK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LS_SuspectNote] ADD CONSTRAINT [FK_L_SuspectUserNote_RK] FOREIGN KEY ([L_SuspectUserNote_RK]) REFERENCES [dbo].[L_SuspectUserNote] ([L_SuspectUserNote_RK]) ON DELETE CASCADE ON UPDATE CASCADE
GO
