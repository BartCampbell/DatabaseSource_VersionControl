CREATE TABLE [x12].[SegNTE]
(
[NTE_RowID] [int] NULL,
[NTE_RowIDParent] [int] NULL,
[NTE_CentauriClientID] [int] NULL,
[NTE_FileLogID] [int] NULL,
[NTE_TransactionImplementationConventionReference] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NTE_TransactionControlNumber] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NTE_LoopID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NTE_NoteReferenceCode_NTE01] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NTE_Description_NTE02] [varchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
