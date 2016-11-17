CREATE TABLE [dbo].[L_SuspectUser]
(
[L_SuspectUser_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[H_Suspect_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[H_User_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordEndDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[L_SuspectUser] ADD CONSTRAINT [PK_L_SuspectUser] PRIMARY KEY CLUSTERED  ([L_SuspectUser_RK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[L_SuspectUser] ADD CONSTRAINT [FK_H_Suspect_RK4] FOREIGN KEY ([H_Suspect_RK]) REFERENCES [dbo].[H_Suspect] ([H_Suspect_RK]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[L_SuspectUser] ADD CONSTRAINT [FK_H_User_RK10] FOREIGN KEY ([H_User_RK]) REFERENCES [dbo].[H_User] ([H_User_RK]) ON DELETE CASCADE ON UPDATE CASCADE
GO
