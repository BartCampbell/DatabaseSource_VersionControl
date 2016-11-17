CREATE TABLE [dbo].[L_UserAdvanceLocation]
(
[L_UserAdvanceLocation_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[H_User_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[H_AdvanceLocation_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordEndDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[L_UserAdvanceLocation] ADD CONSTRAINT [PK_L_UserAdvanceLocation] PRIMARY KEY CLUSTERED  ([L_UserAdvanceLocation_RK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[L_UserAdvanceLocation] ADD CONSTRAINT [FK_H_AdvanceLocation_RK3] FOREIGN KEY ([H_AdvanceLocation_RK]) REFERENCES [dbo].[H_AdvanceLocation] ([H_AdvanceLocation_RK]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[L_UserAdvanceLocation] ADD CONSTRAINT [FK_H_User_RK22] FOREIGN KEY ([H_User_RK]) REFERENCES [dbo].[H_User] ([H_User_RK]) ON DELETE CASCADE ON UPDATE CASCADE
GO
