CREATE TABLE [dbo].[L_MemberProvider]
(
[L_MemberProvider_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[H_Member_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[H_Provider_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL CONSTRAINT [DF_L_MemberProvider_LoadDate] DEFAULT (getdate()),
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordEndDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[L_MemberProvider] ADD CONSTRAINT [PK_L_MemberProvider] PRIMARY KEY CLUSTERED  ([L_MemberProvider_RK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[L_MemberProvider] ADD CONSTRAINT [FK_L_MemberProvider_H_Member] FOREIGN KEY ([H_Member_RK]) REFERENCES [dbo].[H_Member] ([H_Member_RK])
GO
ALTER TABLE [dbo].[L_MemberProvider] ADD CONSTRAINT [FK_L_MemberProvider_H_Provider] FOREIGN KEY ([H_Provider_RK]) REFERENCES [dbo].[H_Provider] ([H_Provider_RK])
GO
