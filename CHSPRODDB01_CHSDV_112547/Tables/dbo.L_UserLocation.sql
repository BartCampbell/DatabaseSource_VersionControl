CREATE TABLE [dbo].[L_UserLocation]
(
[L_UserLocation_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[H_User_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[H_Location_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordEndDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[L_UserLocation] ADD CONSTRAINT [PK_L_UserLocation] PRIMARY KEY CLUSTERED  ([L_UserLocation_RK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[L_UserLocation] ADD CONSTRAINT [FK_H_Location_RK3] FOREIGN KEY ([H_Location_RK]) REFERENCES [dbo].[H_Location] ([H_Location_RK]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[L_UserLocation] ADD CONSTRAINT [FK_H_User_RK3] FOREIGN KEY ([H_User_RK]) REFERENCES [dbo].[H_User] ([H_User_RK]) ON DELETE CASCADE ON UPDATE CASCADE
GO
