CREATE TABLE [fact].[ClaimData]
(
[ClaimDataID] [int] NOT NULL IDENTITY(1, 1),
[CentauriClaimDataID] [int] NOT NULL,
[ProviderID] [int] NOT NULL,
[MemberID] [int] NOT NULL,
[DiagnosisCode] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DOS_From] [smalldatetime] NULL,
[DOS_Thru] [smalldatetime] NULL,
[CPT] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsICD10] [bit] NULL,
[Claim_ID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CreateDate] [datetime] NULL CONSTRAINT [DF_ClaimData_CreateDate] DEFAULT (getdate()),
[LastUpdate] [datetime] NULL CONSTRAINT [DF_ProviderClaimData_LastUpdate] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [fact].[ClaimData] ADD CONSTRAINT [PK_ClaimData] PRIMARY KEY CLUSTERED  ([ClaimDataID]) ON [PRIMARY]
GO
ALTER TABLE [fact].[ClaimData] ADD CONSTRAINT [FK_ClaimData_Member] FOREIGN KEY ([MemberID]) REFERENCES [dim].[Member] ([MemberID])
GO
ALTER TABLE [fact].[ClaimData] ADD CONSTRAINT [FK_ClaimData_Provider] FOREIGN KEY ([ProviderID]) REFERENCES [dim].[Provider] ([ProviderID])
GO
