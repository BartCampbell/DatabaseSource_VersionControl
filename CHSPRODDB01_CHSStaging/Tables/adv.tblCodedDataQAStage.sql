CREATE TABLE [adv].[tblCodedDataQAStage]
(
[CodedData_PK] [bigint] NULL,
[IsConfirmed] [bit] NULL,
[IsRemoved] [bit] NULL,
[Old_ICD9] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Old_CPT] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dtInsert] [smalldatetime] NULL,
[QA_User_PK] [int] NULL,
[IsAdded] [bit] NULL,
[IsChanged] [bit] NULL,
[Client] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL CONSTRAINT [DF__tblCodedD__LoadD__1A016BAA] DEFAULT (getdate()),
[CCI] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CodedDataHashKey] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClientHashKey] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CDI] [int] NULL
) ON [PRIMARY]
GO
