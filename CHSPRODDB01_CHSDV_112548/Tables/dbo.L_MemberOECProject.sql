CREATE TABLE [dbo].[L_MemberOECProject]
(
[L_MemberOECProject_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[H_Member_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[H_OECProject_RK] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordEndDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[L_MemberOECProject] ADD CONSTRAINT [PK_L_MemberOECProject] PRIMARY KEY CLUSTERED  ([L_MemberOECProject_RK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[L_MemberOECProject] ADD CONSTRAINT [FK_L_MemberOECProject_H_Member] FOREIGN KEY ([H_Member_RK]) REFERENCES [dbo].[H_Member] ([H_Member_RK])
GO
ALTER TABLE [dbo].[L_MemberOECProject] ADD CONSTRAINT [FK_L_MemberOECProject_H_OECProject] FOREIGN KEY ([H_OECProject_RK]) REFERENCES [dbo].[H_OECProject] ([H_OECProject_RK])
GO
