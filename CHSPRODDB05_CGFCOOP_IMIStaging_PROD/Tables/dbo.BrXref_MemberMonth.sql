CREATE TABLE [dbo].[BrXref_MemberMonth]
(
[EligibilityMemberMonthsID] [int] NOT NULL IDENTITY(1, 1),
[EligibilityID] [int] NULL,
[MemberID] [int] NULL,
[MonthDate] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[member_month_first] [int] NOT NULL,
[member_month_mid] [int] NOT NULL,
[Client] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idxEligibility] ON [dbo].[BrXref_MemberMonth] ([EligibilityID]) ON [NDX]
GO
CREATE NONCLUSTERED INDEX [fk] ON [dbo].[BrXref_MemberMonth] ([EligibilityID], [MemberID], [member_month_first]) ON [NDX]
GO
CREATE NONCLUSTERED INDEX [idxMemember] ON [dbo].[BrXref_MemberMonth] ([MemberID]) ON [NDX]
GO
CREATE STATISTICS [sp_idxEligibility] ON [dbo].[BrXref_MemberMonth] ([EligibilityID])
GO
CREATE STATISTICS [sp] ON [dbo].[BrXref_MemberMonth] ([EligibilityID], [MemberID], [member_month_first])
GO
CREATE STATISTICS [sp_fk] ON [dbo].[BrXref_MemberMonth] ([EligibilityID], [MemberID], [member_month_first])
GO
CREATE STATISTICS [sp_idxMemember] ON [dbo].[BrXref_MemberMonth] ([MemberID])
GO
