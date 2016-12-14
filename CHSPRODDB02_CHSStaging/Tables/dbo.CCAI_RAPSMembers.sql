CREATE TABLE [dbo].[CCAI_RAPSMembers]
(
[RecID] [int] NOT NULL IDENTITY(1, 1),
[MemberID] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MedicareID] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Member_LastName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Member_FirstName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Member_DOB] [date] NULL,
[PlanNo] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MemberType] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CCAI_RAPSMembers] ADD CONSTRAINT [UQ__CCAI_RAP__360414FEF844D627] UNIQUE NONCLUSTERED  ([RecID]) ON [PRIMARY]
GO
