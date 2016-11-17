CREATE TABLE [dbo].[L_100003_MemberClient]
(
[L_MemberClient_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[H_Member_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[H_Client_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordEndDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[L_100003_MemberClient] ADD CONSTRAINT [PK_L_100003_MemberClient] PRIMARY KEY CLUSTERED  ([L_MemberClient_RK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[L_100003_MemberClient] ADD CONSTRAINT [FK_L_100003_MemberClient_H_100003_Member] FOREIGN KEY ([H_Member_RK]) REFERENCES [dbo].[H_100003_Member] ([H_Member_RK])
GO
