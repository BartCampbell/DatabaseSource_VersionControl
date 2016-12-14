CREATE TABLE [adv].[tblClaimDataStage]
(
[ClaimData_PK] [bigint] NOT NULL,
[Member_PK] [bigint] NOT NULL,
[DiagnosisCode] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DOS_From] [smalldatetime] NULL,
[DOS_Thru] [smalldatetime] NULL,
[CPT] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderMaster_PK] [bigint] NULL,
[IsICD10] [bit] NULL,
[Claim_ID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Client] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL CONSTRAINT [DF__tblClaimD__LoadD__627C2C96] DEFAULT (getdate()),
[CCI] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClaimDataHashKey] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClientHashKey] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CDI] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [adv].[tblClaimDataStage] ADD CONSTRAINT [PK_tblClaimDataStage] PRIMARY KEY CLUSTERED  ([ClaimData_PK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
