CREATE TABLE [x12].[SegPER]
(
[PER_RowID] [int] NULL,
[PER_RowIDParent] [int] NULL,
[PER_CentauriClientID] [int] NULL,
[PER_FileLogID] [int] NULL,
[PER_TransactionImplementationConventionReference] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PER_TransactionControlNumber] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PER_LoopID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PER_ContactFunctionCode_PER01] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PER_Name_PER02] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PER_CommunicationNumberQualifier_PER03] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PER_CommunicationNumber_PER04] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PER_CommunicationNumberQualifier_PER05] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PER_CommunicationNumber_PER06] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PER_CommunicationNumberQualifier_PER07] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PER_CommunicationNumber_PER08] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PER_ContactInquiryReference_PER09] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
