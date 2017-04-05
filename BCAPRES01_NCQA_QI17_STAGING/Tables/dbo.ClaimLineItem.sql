CREATE TABLE [dbo].[ClaimLineItem]
(
[ClaimLineItemID] [int] NOT NULL IDENTITY(1, 1),
[AmountGrossPayment] [money] NOT NULL,
[ClaimID] [int] NOT NULL,
[LineItemNumber] [smallint] NOT NULL,
[ClaimStatus] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AmountCOBSavings] [money] NULL,
[AmountCopay] [money] NULL,
[AmountDisallowed] [money] NULL,
[AmountMedicarePaid] [money] NULL,
[AmountNetPayment] [money] NULL,
[AmountTotalCharge] [money] NULL,
[AmountWithold] [money] NULL,
[Client] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DataSource] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DateAdjusted] [smalldatetime] NULL,
[DatePaid] [smalldatetime] NULL,
[DateServiceBegin] [smalldatetime] NULL,
[DateServiceEnd] [smalldatetime] NULL,
[DiagnosisCode] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CPTProcedureCode] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CPTProcedureCodeModifier1] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CPTProcedureCodeModifier2] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CPTProcedureCodeModifier3] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CPTProcedureCodeModifier4] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HedisMeasureID] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PlaceOfServiceCode] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PlaceOfServiceCodeIndicator] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RevenueCode] [char] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SubNumber] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TypeOfService] [char] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Units] [numeric] (10, 2) NULL,
[CoveredDays] [numeric] (10, 2) NULL,
[CPT_II] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HCPCSProcedureCode] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClaimDisallowReason] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ClaimLineItem] ADD CONSTRAINT [actClaimLineItem_PK] PRIMARY KEY CLUSTERED  ([ClaimLineItemID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ix_ClaimLineItem_ClaimID] ON [dbo].[ClaimLineItem] ([ClaimID]) ON [PRIMARY]
GO
CREATE STATISTICS [sp_ix_ClaimLineItem_ClaimID] ON [dbo].[ClaimLineItem] ([ClaimID])
GO
CREATE STATISTICS [sp_actClaimLineItem_PK] ON [dbo].[ClaimLineItem] ([ClaimLineItemID])
GO
ALTER TABLE [dbo].[ClaimLineItem] ADD CONSTRAINT [actClaim_ClaimLineItem_FK1] FOREIGN KEY ([ClaimID]) REFERENCES [dbo].[Claim] ([ClaimID])
GO
