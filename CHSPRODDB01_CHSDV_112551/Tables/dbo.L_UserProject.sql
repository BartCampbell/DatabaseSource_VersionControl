CREATE TABLE [dbo].[L_UserProject]
(
[L_UserProject_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[H_User_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[H_Project_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordEndDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[L_UserProject] ADD CONSTRAINT [PK_L_UserProject] PRIMARY KEY CLUSTERED  ([L_UserProject_RK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[L_UserProject] ADD CONSTRAINT [FK_H_Project_RK3] FOREIGN KEY ([H_Project_RK]) REFERENCES [dbo].[H_Project] ([H_Project_RK]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[L_UserProject] ADD CONSTRAINT [FK_H_User_RK6] FOREIGN KEY ([H_User_RK]) REFERENCES [dbo].[H_User] ([H_User_RK]) ON DELETE CASCADE ON UPDATE CASCADE
GO
