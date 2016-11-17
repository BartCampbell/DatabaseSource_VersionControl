CREATE TABLE [mor].[MOR_Header_Stage]
(
[H_MOR_Header_RK] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordTypeCode] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ContractNumber] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RunDate] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PaymentYearandMonth] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL,
[RecordSource] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
