CREATE TABLE [dbo].[RAPS_SubmissionHistory]
(
[RAPSResponseID] [bigint] NOT NULL,
[ResponseFileID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SeqNo] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CentauriClientID] [int] NOT NULL,
[CentauriMemberID] [int] NOT NULL,
[HicNo] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PatientControlNo] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ClaimNumber] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PatientDOB] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DOBErrorCode] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HICErrorCode] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PlanNo] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FromDate] [int] NULL,
[ThruDate] [int] NULL,
[ProviderType] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DXCode] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ErrorA] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ErrorB] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RiskAssessmentCode] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RiskAssessmentCodeError] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClusteringGroupID] [int] NULL,
[FileTransactionDate] [int] NULL,
[FileDiagType] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Accepted] [bit] NOT NULL,
[FileName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NOT NULL,
[LastUpdate] [datetime] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[RAPS_SubmissionHistory] ADD CONSTRAINT [PK_RAPS_SubmissionHistory] PRIMARY KEY CLUSTERED  ([RAPSResponseID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX1] ON [dbo].[RAPS_SubmissionHistory] ([CentauriClientID], [DOBErrorCode], [HICErrorCode], [ThruDate], [ErrorA], [ErrorB]) INCLUDE ([DXCode], [HicNo]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX2] ON [dbo].[RAPS_SubmissionHistory] ([CentauriClientID], [DXCode], [DOBErrorCode], [HICErrorCode], [ThruDate], [ErrorA], [ErrorB]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_Hicno] ON [dbo].[RAPS_SubmissionHistory] ([CentauriClientID], [HicNo], [DOBErrorCode], [HICErrorCode], [ErrorA], [ErrorB]) INCLUDE ([DXCode]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_PlanNo] ON [dbo].[RAPS_SubmissionHistory] ([PlanNo]) INCLUDE ([FileTransactionDate]) ON [PRIMARY]
GO
