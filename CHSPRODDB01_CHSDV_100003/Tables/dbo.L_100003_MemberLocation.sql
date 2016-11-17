CREATE TABLE [dbo].[L_100003_MemberLocation]
(
[L_MemberLocation_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[H_Member_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[H_Location_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordEndDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[L_100003_MemberLocation] ADD CONSTRAINT [PK_L_100003_MemberLocation] PRIMARY KEY CLUSTERED  ([L_MemberLocation_RK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[L_100003_MemberLocation] ADD CONSTRAINT [FK_L_100003_MemberLocation_H_100003_Member] FOREIGN KEY ([H_Member_RK]) REFERENCES [dbo].[H_100003_Member] ([H_Member_RK])
GO
