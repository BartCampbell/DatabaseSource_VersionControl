CREATE TABLE [stage].[RAPSResponse]
(
[CentauriClientID] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CentauriMemberID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FileID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SeqNo] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HicNo] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PatientControlNo] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClaimNumber] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PatientDOB] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DOBErrorCode] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HicErrorCode] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PlanNo] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FromDate] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ThruDate] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderType] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DXCode] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ErrorA] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ErrorB] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RiskAssessmentCode] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RiskAssessmentCodeError] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClusterGrouping] [int] NOT NULL,
[TransactionDate] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FileDiagType] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Accepted] [int] NOT NULL,
[FileName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL
) ON [PRIMARY]
GO
