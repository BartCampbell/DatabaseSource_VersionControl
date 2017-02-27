CREATE TABLE [dbo].[S_TRRVerbatim]
(
[S_TRRVerbatim_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[H_TRRVerbatim_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[HICN] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Surname] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FirstName] [varchar] (7) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MiddleInitial] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[GenderCode] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DOB] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordType] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ContractNumber] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PlanTransactionText] [varchar] (300) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TransactionAcceptRejectStatus] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SystemAssignedTransactionTrackingID] [varchar] (11) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PlanAssignedTransactionTrackingID] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HashDiff] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordEndDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[S_TRRVerbatim] ADD CONSTRAINT [PK_S_TRRVerbatim] PRIMARY KEY CLUSTERED  ([S_TRRVerbatim_RK]) ON [PRIMARY]
GO
