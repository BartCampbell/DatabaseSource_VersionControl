CREATE TABLE [x12].[SegFRM]
(
[FRM_RowID] [int] NULL,
[FRM_RowIDParent] [int] NULL,
[FRM_CentauriClientID] [int] NULL,
[FRM_FileLogID] [int] NULL,
[FRM_TransactionImplementationConventionReference] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FRM_TransactionControlNumber] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FRM_LoopID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FRM_AssignedIdentification_FRM01] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FRM_YesNoConditionOrResponseCode_FRM02] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FRM_ReferenceIdentification_FRM03] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FRM_Date_FRM04] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FRM_PercentDecimalFormat_FRM05] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
