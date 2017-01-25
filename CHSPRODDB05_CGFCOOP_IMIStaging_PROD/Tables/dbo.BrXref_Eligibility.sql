CREATE TABLE [dbo].[BrXref_Eligibility]
(
[BusRuleDtlID] [int] NOT NULL IDENTITY(1, 1),
[EligibilityID] [bigint] NULL,
[DHMPLineOfBusiness] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MedicareType] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MemberGroupCategory] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idxEligibility] ON [dbo].[BrXref_Eligibility] ([EligibilityID]) ON [NDX]
GO
CREATE STATISTICS [sp_idxEligibility] ON [dbo].[BrXref_Eligibility] ([EligibilityID])
GO
