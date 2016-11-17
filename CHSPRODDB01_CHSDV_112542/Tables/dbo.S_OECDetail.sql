CREATE TABLE [dbo].[S_OECDetail]
(
[S_OECDetail_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[H_OEC_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MemberHICN] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ChaseID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClaimID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DiagnosisCode] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DiagnosisCodeOrder] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DxCodesBillTypeCd] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ICD_Indicator] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DOS_FromDate] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DOS_ToDate] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MedicalRecordID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderSpecialty] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderSpecialty2] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderSpecialty3] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PricingID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SVCTaxID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MHFacilityFlag] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NetworkIndicator] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Claim_Category_Primary1] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Claim_Category_Primary2] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Claim_Category_Primary3] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Claim_Category_Secondary1] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Claim_Category_Secondary2] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Claim_Category_Secondary3] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MHMD] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OfficeName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OfficeAddress] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OfficeCity] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OfficeState] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OfficeZip] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HashDiff] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LoadDate] [datetime] NOT NULL,
[RecordEndDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[S_OECDetail] ADD CONSTRAINT [PK_S_OECDetail] PRIMARY KEY CLUSTERED  ([S_OECDetail_RK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[S_OECDetail] ADD CONSTRAINT [FK_S_OECDetail_H_OEC] FOREIGN KEY ([H_OEC_RK]) REFERENCES [dbo].[H_OEC] ([H_OEC_RK])
GO
