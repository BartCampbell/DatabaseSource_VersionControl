CREATE TABLE [fact].[MemberChase]
(
[MemberChaseID] [int] NOT NULL IDENTITY(1, 1),
[MemberID] [int] NOT NULL,
[ChaseID] [bigint] NULL,
[PID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[REN_Provider_Specialty] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Segment_PK] [tinyint] NULL,
[ChartPriority] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Ref_Number] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordStartDate] [datetime] NULL CONSTRAINT [DF_MemberChase_CreateDate] DEFAULT (getdate()),
[RecordEndDate] [datetime] NULL CONSTRAINT [DF_MemberChase_LastUpdate] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [fact].[MemberChase] ADD CONSTRAINT [PK_MemberChase] PRIMARY KEY CLUSTERED  ([MemberChaseID]) ON [PRIMARY]
GO
ALTER TABLE [fact].[MemberChase] ADD CONSTRAINT [FK_MemberChase_Member] FOREIGN KEY ([MemberID]) REFERENCES [dim].[Member] ([MemberID])
GO
