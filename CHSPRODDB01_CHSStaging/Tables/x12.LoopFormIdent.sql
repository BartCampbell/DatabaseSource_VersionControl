CREATE TABLE [x12].[LoopFormIdent]
(
[FormIdent_RowID] [int] NULL,
[FormIdent_RowIDParent] [int] NULL,
[FormIdent_CentauriClientID] [int] NULL,
[FormIdent_FileLogID] [int] NULL,
[FormIdent_TransactionImplementationConventionReference] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FormIdent_TransactionControlNumber] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FormIdent_LoopID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FormIdent_CodeListQualifierCode_LQ01] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FormIdent_IndustryCode_LQ02] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
