CREATE TABLE [dbo].[tmp_claimlineitem]
(
[ClaimLineItemID] [bigint] NULL,
[ClaimID] [int] NULL,
[DateServiceBegin] [datetime] NULL,
[DateServiceEnd] [datetime] NULL,
[DataSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [Tmp_Drive01]
GO
