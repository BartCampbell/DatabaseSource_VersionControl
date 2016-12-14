CREATE TABLE [x12].[SegAMT]
(
[AMT_RowID] [int] NULL,
[AMT_RowIDParent] [int] NULL,
[AMT_CentauriClientID] [int] NULL,
[AMT_FileLogID] [int] NULL,
[AMT_TransactionImplementationConventionReference] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AMT_TransactionControlNumber] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AMT_LoopID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AMT_AmountQualifierCode_AMT01] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AMT_MonetaryAmount_AMT02] [varchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AMT_CreditDebitFlagCode_AMT03] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
