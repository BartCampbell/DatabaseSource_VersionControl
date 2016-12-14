CREATE TABLE [x12].[TR]
(
[TR_RowID] [int] NULL,
[TR_RowIDParent] [int] NULL,
[TR_CentauriClientID] [int] NULL,
[TR_FileLogID] [int] NULL,
[TR_TransactionImplementationConventionReference] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TR_TransactionControlNumber] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TR_LoopID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TR_TransactionSetIdentifierCode_ST01] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TR_TransactionSetControlNumber_ST02] [varchar] (9) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TR_ImplementationConventionReference_ST03] [varchar] (35) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TR_HierarchicalStructureCode_BHT01] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TR_TransactionSetPurposeCode_BHT02] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TR_ReferenceIdentification_BHT03] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TR_Date_BHT04] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TR_Time_BHT05] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TR_TransactionTypeCode_BHT06] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SE_NumberofIncludedSegments_SE01] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SE_TransactionSetControlNumber_SE02] [varchar] (9) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
