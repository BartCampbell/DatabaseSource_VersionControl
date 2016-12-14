CREATE TABLE [x12].[LoopSvcLnAdj]
(
[SvcLnAdj_RowID] [int] NULL,
[SvcLnAdj_RowIDParent] [int] NULL,
[SvcLnAdj_CentauriClientID] [int] NULL,
[SvcLnAdj_FileLogID] [int] NULL,
[SvcLnAdj_TransactionImplementationConventionReference] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SvcLnAdj_TransactionControlNumber] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SvcLnAdj_LoopID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SvcLnAdj_IdentificationCode_SVD01] [varchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SvcLnAdj_MonetaryAmount_SVD02] [varchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SvcLnAdj_ProductServiceIDQualifier_SVD0301] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SvcLnAdj_ProductServiceID_SVD0302] [varchar] (48) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SvcLnAdj_ProcedureModifier_SVD0303] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SvcLnAdj_ProcedureModifier_SVD0304] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SvcLnAdj_ProcedureModifier_SVD0305] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SvcLnAdj_ProcedureModifier_SVD0306] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SvcLnAdj_Description_SVD0307] [varchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SvcLnAdj_ProductServiceID_SVD0308] [varchar] (48) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SvcLnAdj_ProductServiceID_SVD04] [varchar] (48) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SvcLnAdj_Quantity_SVD05] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SvcLnAdj_AssignedNumber_SVD06] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
