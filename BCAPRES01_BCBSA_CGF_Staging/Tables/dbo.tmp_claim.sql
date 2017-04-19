CREATE TABLE [dbo].[tmp_claim]
(
[ClaimID] [bigint] NULL,
[MemberID] [int] NULL,
[ServicingProviderID] [int] NULL,
[ihds_prov_id_servicing] [int] NULL,
[ihds_member_id] [int] NULL,
[DataSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DateServiceBegin] [datetime] NULL
) ON [Tmp_Drive03]
GO
CREATE NONCLUSTERED INDEX [idx] ON [dbo].[tmp_claim] ([ClaimID], [DataSource]) INCLUDE ([ihds_member_id], [ihds_prov_id_servicing], [MemberID], [ServicingProviderID]) ON [Tmp_Drive03]
GO
CREATE STATISTICS [spidx] ON [dbo].[tmp_claim] ([ClaimID], [DataSource])
GO
