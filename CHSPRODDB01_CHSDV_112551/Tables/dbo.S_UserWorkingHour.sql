CREATE TABLE [dbo].[S_UserWorkingHour]
(
[S_UserWorkingHour_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LoadDate] [datetime] NULL,
[Day_PK] [tinyint] NOT NULL,
[FromHour] [tinyint] NULL,
[FromMin] [tinyint] NULL,
[ToHour] [tinyint] NULL,
[ToMin] [tinyint] NULL,
[H_User_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HashDiff] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordEndDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[S_UserWorkingHour] ADD CONSTRAINT [PK_S_UserWorkingHour] PRIMARY KEY CLUSTERED  ([S_UserWorkingHour_RK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[S_UserWorkingHour] ADD CONSTRAINT [FK_H_User_RK9] FOREIGN KEY ([H_User_RK]) REFERENCES [dbo].[H_User] ([H_User_RK]) ON DELETE CASCADE ON UPDATE CASCADE
GO
