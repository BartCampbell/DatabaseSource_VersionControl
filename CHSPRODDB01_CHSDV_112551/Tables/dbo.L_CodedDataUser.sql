CREATE TABLE [dbo].[L_CodedDataUser]
(
[L_CodedDataUser_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[H_CodedData_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[H_User_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordEndDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[L_CodedDataUser] ADD CONSTRAINT [PK_L_CodedDataUser] PRIMARY KEY CLUSTERED  ([L_CodedDataUser_RK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[L_CodedDataUser] ADD CONSTRAINT [FK_H_CodedData_RK3] FOREIGN KEY ([H_CodedData_RK]) REFERENCES [dbo].[H_CodedData] ([H_CodedData_RK]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[L_CodedDataUser] ADD CONSTRAINT [FK_H_User_RK17] FOREIGN KEY ([H_User_RK]) REFERENCES [dbo].[H_User] ([H_User_RK]) ON DELETE CASCADE ON UPDATE CASCADE
GO
