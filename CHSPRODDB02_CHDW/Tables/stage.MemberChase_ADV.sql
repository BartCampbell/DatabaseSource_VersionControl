CREATE TABLE [stage].[MemberChase_ADV]
(
[CentauriMemberID] [int] NOT NULL,
[ChaseID] [bigint] NULL,
[PID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[REN_Provider_Specialty] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Segment_PK] [tinyint] NULL,
[ChartPriority] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Ref_Number] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordSource] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClientID] [int] NULL,
[LoadDate] [datetime] NULL
) ON [PRIMARY]
GO
