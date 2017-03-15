CREATE TABLE [raps].[RAPS_RESPONSE_BBB]
(
[RecordID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SeqNo] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PlanNo] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OverpaymentID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OverpaymentIDErrorCode] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PaymentYear] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PaymentYearErrorCode] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ResponseFileID] [int] NOT NULL,
[H_RAPS_Response_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[S_RAPS_Response_BBB_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HashDiff] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
