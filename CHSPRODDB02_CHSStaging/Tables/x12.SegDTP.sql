CREATE TABLE [x12].[SegDTP]
(
[DTP_RowID] [int] NULL,
[DTP_RowIDParent] [int] NULL,
[DTP_CentauriClientID] [int] NULL,
[DTP_FileLogID] [int] NULL,
[DTP_TransactionImplementationConventionReference] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DTP_TransactionControlNumber] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DTP_LoopID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DTP_DateTimeQualifier_DTP01] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DTP_DateTimePeriodFormatQualifier_DTP02] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DTP_DateTimePeriod_DTP03] [varchar] (35) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
