CREATE TABLE [oec].[EnrolleeStratum_112549]
(
[Client_ID] [int] NULL,
[Member_ID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Issuer] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Stratum] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Stratum_Description] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CentauriMemberID] [bigint] NULL,
[H_Member_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OEC_ProjectID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[L_MemberOECProject_RK] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LS_MemberOECProjectStratum_RK] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[H_OECProject_RK] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HashDiff] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL,
[FileName] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
