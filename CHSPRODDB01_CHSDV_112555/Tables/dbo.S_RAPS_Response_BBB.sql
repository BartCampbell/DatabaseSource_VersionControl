CREATE TABLE [dbo].[S_RAPS_Response_BBB]
(
[S_RAPS_Response_BBB_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[H_RAPS_Response_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[RecordID] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SeqNo] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PlanNo] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OverpaymentID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OverpaymentIDErrorCode] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PaymentYear] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PaymentYearErrorCode] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HashDiff] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LoadDate] [datetime] NOT NULL CONSTRAINT [DF_S_RAPS_Response_BBB_LoadDate] DEFAULT (getdate()),
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[RecordEndDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[S_RAPS_Response_BBB] ADD CONSTRAINT [PK_S_RAPS_Response_BBB] PRIMARY KEY CLUSTERED  ([S_RAPS_Response_BBB_RK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[S_RAPS_Response_BBB] ADD CONSTRAINT [FK_S_RAPS_Response_BBB_H_RAPS_Response] FOREIGN KEY ([H_RAPS_Response_RK]) REFERENCES [dbo].[H_RAPS_Response] ([H_RAPS_Response_RK])
GO
