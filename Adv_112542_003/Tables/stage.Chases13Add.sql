CREATE TABLE [stage].[Chases13Add]
(
[AdvanceOECRawID] [int] NOT NULL,
[FileName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LoadDate] [datetime2] (3) NOT NULL,
[ClientID] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ChaseID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MemberID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MemberHICN] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MedicalRecordID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MemberLastName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MemberFirstName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MemberDOB] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MemberGender] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderNPI] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderLastName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderFirstName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderSpecialty] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderAddress] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderCity] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderState] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderZip] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderPhone] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClaimID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DiagnosisCode] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ICD9_ICD10_Ind] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DOS_FromDate] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DOS_ToDate] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PRICING_ID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SVC_TAX_ID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MHFacilityFlag] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NetworkIndicator] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CentauriMemberID] [int] NULL,
[CentauriProviderID] [int] NULL,
[CentauriChaseID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProjectName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Provider_PK] [int] NULL,
[ProviderMaster_PK] [int] NULL,
[ProviderOffice_PK] [int] NULL,
[Member_PK] [int] NULL
) ON [PRIMARY]
GO
