CREATE TABLE [dbo].[repHighClaimCost]
(
[ClaimLineItemID] [int] NULL,
[ClaimID] [int] NULL,
[MemberID] [int] NULL,
[DateServiceBegin] [datetime] NULL,
[DatePaid] [datetime] NULL,
[LOB] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PlaceOfService] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PlaceOfServiceDesc] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TypeOfService] [varchar] (19) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ServicingProvSpecialtyDesc] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[VisitType] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[HighCostMemberReason] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DiagnosisCode1] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[diagnosis_1_short_category] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AmountNetPayment] [money] NULL,
[Param_ServiceStartDate] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Param_ServiceEndDate] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Param_PaidStartDate] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Param_PaidENdDate] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustomerMemberID] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FullName] [varchar] (202) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
