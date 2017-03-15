CREATE TABLE [x12].[SegCRC]
(
[CRC_RowID] [int] NULL,
[CRC_RowIDParent] [int] NULL,
[CRC_CentauriClientID] [int] NULL,
[CRC_FileLogID] [int] NULL,
[CRC_TransactionImplementationConventionReference] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CRC_TransactionControlNumber] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CRC_LoopID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CRC_CodeCategory_CRC01] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CRC_YesNoConditionOrResponseCode_CRC02] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CRC_ConditionIndicator_CRC03] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CRC_ConditionIndicator_CRC04] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CRC_ConditionIndicator_CRC05] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CRC_ConditionIndicator_CRC06] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CRC_ConditionIndicator_CRC07] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
