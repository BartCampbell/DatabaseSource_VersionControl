CREATE TABLE [raps].[RAPS_RESPONSE_ZZZ]
(
[RecordID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SubmitterID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FileID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BBBRecordTotal] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ResponseFileID] [int] NOT NULL,
[H_RAPS_Response_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[S_RAPS_Response_ZZZ_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HashDiff] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
