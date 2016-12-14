CREATE TABLE [x12].[SegK3]
(
[K3_RowID] [int] NULL,
[K3_RowIDParent] [int] NULL,
[K3_CentauriClientID] [int] NULL,
[K3_FileLogID] [int] NULL,
[K3_TransactionImplementationConventionReference] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[K3_TransactionControlNumber] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[K3_LoopID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[K3_FixedFormatInformation_K301] [varchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[K3_RecordFormatCode_K302] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[K3_CompositeUnitOfMeasure_K303] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
