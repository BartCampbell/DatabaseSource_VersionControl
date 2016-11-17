CREATE TABLE [dbo].[FHN_CareCollaboration_IncentivePaymentDetail]
(
[RecID] [int] NOT NULL IDENTITY(1, 1),
[PCPID] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PCPName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[GroupID] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[GroupName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FullMeasureDescription] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DisplayName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MemberID] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MemberName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MemberDOB] [date] NULL,
[MemberGender] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CompliantFlag] [int] NULL,
[LoadDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FHN_CareCollaboration_IncentivePaymentDetail] ADD CONSTRAINT [UQ__FHN_Care__360414FE4F340C49] UNIQUE NONCLUSTERED  ([RecID]) ON [PRIMARY]
GO
