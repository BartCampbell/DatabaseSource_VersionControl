CREATE TABLE [dbo].[ClaimLineItem]
(
[ClaimLineItemID] [int] NOT NULL IDENTITY(1, 1),
[ClaimID] [int] NOT NULL,
[LineItemNumber] [smallint] NOT NULL,
[ClaimStatus] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Client] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DataSource] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DatePaid] [smalldatetime] NULL,
[DateServiceBegin] [smalldatetime] NULL,
[DateServiceEnd] [smalldatetime] NULL,
[DiagnosisCode] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CPTProcedureCode] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CPTProcedureCodeModifier1] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CPTProcedureCodeModifier2] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CPTProcedureCodeModifier3] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CPTProcedureCodeModifier4] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PlaceOfServiceCode] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RevenueCode] [char] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Units] [numeric] (10, 2) NULL,
[CoveredDays] [numeric] (10, 2) NULL,
[CPT_II] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HCPCSProcedureCode] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadInstanceFileID] [int] NULL,
[RowFileID] [int] NULL,
[PayClaimID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PayClaimLineID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RowID] [int] NULL,
[PayerClaimID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PayerClaimLineID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HedisMeasureID] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [dbo_ClaimLineItem]
GO
CREATE CLUSTERED INDEX [idxClaimID] ON [dbo].[ClaimLineItem] ([ClaimID], [ClaimLineItemID]) ON [dbo_ClaimLineItem]
GO
CREATE NONCLUSTERED INDEX [idxClaimLineItemID] ON [dbo].[ClaimLineItem] ([ClaimLineItemID]) INCLUDE ([ClaimID], [DateServiceBegin]) ON [dbo_ClaimLineItem_IDX]
GO
CREATE NONCLUSTERED INDEX [idxClientClaimID] ON [dbo].[ClaimLineItem] ([Client], [ClaimID]) ON [dbo_ClaimLineItem_IDX]
GO
CREATE STATISTICS [spidxClaimID] ON [dbo].[ClaimLineItem] ([ClaimID], [ClaimLineItemID])
GO
CREATE STATISTICS [spidxClaimLineItemID] ON [dbo].[ClaimLineItem] ([ClaimLineItemID])
GO
CREATE STATISTICS [spidxClientClaimID] ON [dbo].[ClaimLineItem] ([Client], [ClaimID])
GO
