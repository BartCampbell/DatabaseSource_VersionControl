CREATE TABLE [fact].[RAPSResponse]
(
[RAPSResponseID] [bigint] NOT NULL IDENTITY(1, 1),
[ResponseFileID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SeqNo] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ClientID] [int] NOT NULL,
[MemberID] [int] NOT NULL,
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
[FileName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CreateDate] [datetime] NOT NULL CONSTRAINT [DF_RAPSResponse_CreateDate] DEFAULT (getdate()),
[LastUpdate] [datetime] NOT NULL CONSTRAINT [DF_RAPSResponse_LastUpdate] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [fact].[RAPSResponse] ADD CONSTRAINT [PK_RAPSResponse] PRIMARY KEY CLUSTERED  ([RAPSResponseID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_Filename] ON [fact].[RAPSResponse] ([FileName]) INCLUDE ([Accepted], [ClaimNumber], [ClientID], [ClusteringGroupID], [CreateDate], [DOBErrorCode], [DXCode], [ErrorA], [ErrorB], [FileDiagType], [FileTransactionDate], [FromDate], [HICErrorCode], [HicNo], [LastUpdate], [MemberID], [PatientControlNo], [PatientDOB], [PlanNo], [ProviderType], [RAPSResponseID], [ResponseFileID], [RiskAssessmentCode], [RiskAssessmentCodeError], [SeqNo], [ThruDate]) ON [PRIMARY]
GO
ALTER TABLE [fact].[RAPSResponse] ADD CONSTRAINT [FK_RAPSResponse_Client] FOREIGN KEY ([ClientID]) REFERENCES [dim].[Client] ([ClientID])
GO
ALTER TABLE [fact].[RAPSResponse] ADD CONSTRAINT [FK_RAPSResponse_Member] FOREIGN KEY ([MemberID]) REFERENCES [dim].[Member] ([MemberID])
GO
