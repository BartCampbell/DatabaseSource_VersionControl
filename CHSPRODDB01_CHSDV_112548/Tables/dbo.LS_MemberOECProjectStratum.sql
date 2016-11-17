CREATE TABLE [dbo].[LS_MemberOECProjectStratum]
(
[LS_MemberOECProjectStratum_RK] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[L_MemberOECProject_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Issuer] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Stratum] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[StratumDesc] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EdgeMemberID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HashDiff] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordEndDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LS_MemberOECProjectStratum] ADD CONSTRAINT [PK_LS_MemberOECProjectStratum] PRIMARY KEY CLUSTERED  ([LS_MemberOECProjectStratum_RK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LS_MemberOECProjectStratum] ADD CONSTRAINT [FK_LS_MemberOECProjectStratum_L_MemberOECProject] FOREIGN KEY ([L_MemberOECProject_RK]) REFERENCES [dbo].[L_MemberOECProject] ([L_MemberOECProject_RK])
GO
