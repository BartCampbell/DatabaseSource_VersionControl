CREATE TABLE [dbo].[tblClaimData]
(
[ClaimData_PK] [bigint] NOT NULL IDENTITY(1, 1),
[Member_PK] [bigint] NOT NULL,
[DiagnosisCode] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DOS_From] [smalldatetime] NULL,
[DOS_Thru] [smalldatetime] NULL,
[CPT] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderMaster_PK] [bigint] NULL,
[IsICD10] [bit] NULL,
[Claim_ID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Suspect_PK] [bigint] NULL
) ON [PRIMARY]
GO
