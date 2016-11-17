CREATE TABLE [dbo].[L_UserClient]
(
[L_UserClient_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[H_User_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[H_Client_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordEndDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[L_UserClient] ADD CONSTRAINT [PK_L_UserClient] PRIMARY KEY CLUSTERED  ([L_UserClient_RK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[L_UserClient] ADD CONSTRAINT [FK_H_Client_RK1] FOREIGN KEY ([H_Client_RK]) REFERENCES [dbo].[H_Client] ([H_Client_RK]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[L_UserClient] ADD CONSTRAINT [FK_H_User_RK] FOREIGN KEY ([H_User_RK]) REFERENCES [dbo].[H_User] ([H_User_RK]) ON DELETE CASCADE ON UPDATE CASCADE
GO
