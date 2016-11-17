CREATE TABLE [dbo].[H_MOR_Header]
(
[H_MOR_Header_RK] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[RecordTypeCode] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ContractNumber] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RunDate] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PaymentYearandMonth] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL,
[RecordSource] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[H_MOR_Header] ADD CONSTRAINT [PK_H_MOR_Header] PRIMARY KEY CLUSTERED  ([H_MOR_Header_RK]) ON [PRIMARY]
GO
