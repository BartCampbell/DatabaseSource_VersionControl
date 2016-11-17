CREATE TABLE [dbo].[L_ScannedDataUser]
(
[L_ScannedDataUser_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[H_ScannedData_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[H_User_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordEndDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[L_ScannedDataUser] ADD CONSTRAINT [PK_L_ScannedDataUser] PRIMARY KEY CLUSTERED  ([L_ScannedDataUser_RK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[L_ScannedDataUser] ADD CONSTRAINT [FK_H_ScannedData_RK3] FOREIGN KEY ([H_ScannedData_RK]) REFERENCES [dbo].[H_ScannedData] ([H_ScannedData_RK]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[L_ScannedDataUser] ADD CONSTRAINT [FK_H_User_RK18] FOREIGN KEY ([H_User_RK]) REFERENCES [dbo].[H_User] ([H_User_RK]) ON DELETE CASCADE ON UPDATE CASCADE
GO
