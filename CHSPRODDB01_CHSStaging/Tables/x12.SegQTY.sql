CREATE TABLE [x12].[SegQTY]
(
[QTY_RowID] [int] NULL,
[QTY_RowIDParent] [int] NULL,
[QTY_CentauriClientID] [int] NULL,
[QTY_FileLogID] [int] NULL,
[QTY_TransactionImplementationConventionReference] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[QTY_TransactionControlNumber] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[QTY_LoopID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[QTY_QuantityQualifier_QTY01] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[QTY_Quantity_QTY02] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[QTY_CompositeUnitofMeasure_QTY03] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[QTY_FreeForminformation_QTY04] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
