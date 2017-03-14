CREATE TABLE [dbo].[L_MemberApixioReturn]
(
[L_MemberApixioReturn_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[H_Member_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[H_ApixioReturn_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LoadDate] [datetime] NOT NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[L_MemberApixioReturn] ADD CONSTRAINT [PK_L_MemberApixioReturn] PRIMARY KEY CLUSTERED  ([L_MemberApixioReturn_RK]) ON [PRIMARY]
GO
