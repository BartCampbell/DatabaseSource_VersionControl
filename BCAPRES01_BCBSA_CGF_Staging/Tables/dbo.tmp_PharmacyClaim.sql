CREATE TABLE [dbo].[tmp_PharmacyClaim]
(
[PharmacyClaimID] [int] NULL,
[MemberID] [int] NULL,
[ihds_member_id] [int] NULL,
[DataSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DateDispensed] [datetime] NULL,
[ndc] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SupplementalDataFlag] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [Tmp_Drive03]
GO
