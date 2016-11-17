CREATE TABLE [dbo].[L_MemberLocation]
(
[L_MemberLocation_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[H_Member_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[H_Location_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordEndDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[L_MemberLocation] ADD CONSTRAINT [PK_L_MemberLocation] PRIMARY KEY CLUSTERED  ([L_MemberLocation_RK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[L_MemberLocation] ADD CONSTRAINT [FK_H_Location_RK] FOREIGN KEY ([H_Location_RK]) REFERENCES [dbo].[H_Location] ([H_Location_RK]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[L_MemberLocation] ADD CONSTRAINT [FK_H_Member_RK3] FOREIGN KEY ([H_Member_RK]) REFERENCES [dbo].[H_Member] ([H_Member_RK]) ON DELETE CASCADE ON UPDATE CASCADE
GO
