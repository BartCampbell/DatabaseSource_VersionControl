CREATE TABLE [dbo].[fact_OEC_VIVA]
(
[OECID] [int] NOT NULL IDENTITY(1, 1),
[OECProjectID] [int] NULL,
[ProviderID] [int] NULL,
[MemberID] [int] NULL,
[ProviderLocationID] [int] NULL,
[ProviderContactID] [int] NULL,
[VendorLocationID] [int] NULL,
[VendorContactID] [int] NULL,
[NetworkID] [int] NULL,
[MemberHICNID] [int] NULL,
[ChaseID] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ChasePriority] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MedicalRecordID] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderRelationsRep] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClaimID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DiagnosisCode] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ICD_Indicator] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DOS_FromDate] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DOS_ToDate] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CreateDate] [datetime] NOT NULL,
[LastUpdate] [datetime] NOT NULL
) ON [PRIMARY]
GO
