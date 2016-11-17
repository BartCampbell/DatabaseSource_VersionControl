CREATE TABLE [dbo].[OakStreetHealthMemberMonth]
(
[RecordID] [bigint] NOT NULL IDENTITY(1, 1),
[MemberID] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MedicareID] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MemberLastName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MemberFirstName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MemberDOB] [date] NULL,
[ReportDate] [date] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[OakStreetHealthMemberMonth] ADD CONSTRAINT [UQ__OakStree__FBDF78C843F77090] UNIQUE NONCLUSTERED  ([RecordID]) ON [PRIMARY]
GO
