CREATE TABLE [dbo].[LS_UserLocation]
(
[LS_UserLocation_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LoadDate] [datetime] NULL,
[L_UserLocation_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[H_User_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[H_Location_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Active] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HashDiff] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordEndDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LS_UserLocation] ADD CONSTRAINT [PK_LS_UserLocation] PRIMARY KEY CLUSTERED  ([LS_UserLocation_RK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LS_UserLocation] ADD CONSTRAINT [FK_L_UserLocation_RK1] FOREIGN KEY ([L_UserLocation_RK]) REFERENCES [dbo].[L_UserLocation] ([L_UserLocation_RK]) ON DELETE CASCADE ON UPDATE CASCADE
GO
