CREATE TABLE [dbo].[CCAI_LEP_Detail]
(
[RecordType] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_CCAI_LEP_Detail_RecordType] DEFAULT (getdate()),
[ContractNumber] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PBP] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PlanSegment] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HICNumber] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Surname] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FirstInitial] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Gender] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DOB] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PremAdujstStartDate] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PremAdujstEndDate] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MonthsAdujstPeriod] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UncoveredMonths] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LEPAmount] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL
) ON [PRIMARY]
GO
