CREATE TABLE [dbo].[LS_MemberOECProjectHCC]
(
[LS_MemberOECProjectHCC_RK] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[L_MemberOECProject_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HCC] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HashDiff] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordEndDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LS_MemberOECProjectHCC] ADD CONSTRAINT [PK_LS_MemberOECProjectHCC] PRIMARY KEY CLUSTERED  ([LS_MemberOECProjectHCC_RK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LS_MemberOECProjectHCC] ADD CONSTRAINT [FK_LS_MemberOECProjectHCC_L_MemberOECProject] FOREIGN KEY ([L_MemberOECProject_RK]) REFERENCES [dbo].[L_MemberOECProject] ([L_MemberOECProject_RK])
GO
