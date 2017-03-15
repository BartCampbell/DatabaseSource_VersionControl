CREATE TABLE [x12].[SegREF]
(
[REF_RowID] [int] NULL,
[REF_RowIDParent] [int] NULL,
[REF_CentauriClientID] [int] NULL,
[REF_FileLogID] [int] NULL,
[REF_TransactionImplementationConventionReference] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[REF_TransactionControlNumber] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[REF_LoopID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[REF_ReferenceIdentificationQualifier_REF01] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[REF_ReferenceIdentification_REF02] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[REF_Description_REF03] [varchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[REF_ReferenceIdentifier_REF04] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
