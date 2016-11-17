CREATE TABLE [dbo].[LS_ScannedDataUser]
(
[LS_ScannedDataUser_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LoadDate] [datetime] NULL,
[L_ScannedDataUser_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[H_ScannedData_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[H_User_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Active] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HashDiff] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordEndDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LS_ScannedDataUser] ADD CONSTRAINT [PK_LS_ScannedDataUser] PRIMARY KEY CLUSTERED  ([LS_ScannedDataUser_RK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [NonClusteredIndex-20161004-143535] ON [dbo].[LS_ScannedDataUser] ([HashDiff]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LS_ScannedDataUser] ADD CONSTRAINT [FK_L_ScannedDataUser_RK1] FOREIGN KEY ([L_ScannedDataUser_RK]) REFERENCES [dbo].[L_ScannedDataUser] ([L_ScannedDataUser_RK]) ON DELETE CASCADE ON UPDATE CASCADE
GO
