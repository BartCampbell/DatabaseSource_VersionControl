CREATE TABLE [stage].[tblClaimData]
(
[MemberID] [varchar] (20) COLLATE SQL_Latin1_General_CP437_CI_AI NOT NULL,
[ChaseID] [varchar] (20) COLLATE SQL_Latin1_General_CP437_CI_AI NOT NULL,
[DiagnosisCode] [varchar] (10) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[DOS_From] [smalldatetime] NULL,
[DOS_Thru] [smalldatetime] NULL,
[CPT] [varchar] (12) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[ProviderID] [varchar] (20) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[IsICD10] [bit] NULL,
[Claim_ID] [varchar] (50) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[ClientProviderID] [varchar] (20) COLLATE SQL_Latin1_General_CP437_CI_AI NULL
) ON [PRIMARY]
GO
