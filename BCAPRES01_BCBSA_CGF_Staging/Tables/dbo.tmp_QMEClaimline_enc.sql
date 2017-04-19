CREATE TABLE [dbo].[tmp_QMEClaimline_enc]
(
[ClaimLineItemID] [bigint] NULL,
[ClaimID] [int] NULL,
[DataSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NDC] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CVX] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsSupplemental] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [Tmp_Drive02]
GO
CREATE NONCLUSTERED INDEX [idx] ON [dbo].[tmp_QMEClaimline_enc] ([ClaimLineItemID], [DataSource]) INCLUDE ([ClaimID]) ON [Tmp_Drive01]
GO
CREATE STATISTICS [spidx] ON [dbo].[tmp_QMEClaimline_enc] ([ClaimLineItemID], [DataSource])
GO
