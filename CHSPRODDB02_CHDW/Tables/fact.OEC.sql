CREATE TABLE [fact].[OEC]
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
[ProviderSpecialty] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClaimID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DiagnosisCode] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ICD_Indicator] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DOS_FromDate] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DOS_ToDate] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Eff_Date] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Exp_Date] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ContractCode] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DNC] [bit] NULL,
[CreateDate] [datetime] NOT NULL CONSTRAINT [DF_OEC_RecordStartDate] DEFAULT (getdate()),
[LastUpdate] [datetime] NOT NULL CONSTRAINT [DF_OEC_RecordEndDate] DEFAULT (getdate()),
[DiagnosisCodeOrder] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DxCodesBillTypeCd] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
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
[OfficeZip] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [fact].[OEC] ADD CONSTRAINT [PK_OEC] PRIMARY KEY CLUSTERED  ([OECID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [_dta_index_OEC_17_752721734__K3_K2] ON [fact].[OEC] ([ProviderID], [OECProjectID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [_dta_index_OEC_17_752721734__K3_K2_K4_K1_K11_K19_K20] ON [fact].[OEC] ([ProviderID], [OECProjectID], [MemberID], [OECID], [ChaseID], [DOS_FromDate], [DOS_ToDate]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [_dta_index_OEC_17_752721734__K3_K2_K1_K4_K15_K23_K12_K13_11] ON [fact].[OEC] ([ProviderID], [OECProjectID], [OECID], [MemberID], [ProviderSpecialty], [ContractCode], [ChasePriority], [MedicalRecordID]) INCLUDE ([ChaseID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [_dta_index_OEC_17_752721734__K5_K2_K14] ON [fact].[OEC] ([ProviderLocationID], [OECProjectID], [ProviderRelationsRep]) ON [PRIMARY]
GO
ALTER TABLE [fact].[OEC] ADD CONSTRAINT [FK_OEC_Member] FOREIGN KEY ([MemberID]) REFERENCES [dim].[Member] ([MemberID])
GO
ALTER TABLE [fact].[OEC] ADD CONSTRAINT [FK_OEC_MemberHICN] FOREIGN KEY ([MemberHICNID]) REFERENCES [dim].[MemberHICN] ([MemberHICNID])
GO
ALTER TABLE [fact].[OEC] ADD CONSTRAINT [FK_OEC_Network] FOREIGN KEY ([NetworkID]) REFERENCES [dim].[Network] ([NetworkID])
GO
ALTER TABLE [fact].[OEC] ADD CONSTRAINT [FK_OEC_OECProject] FOREIGN KEY ([OECProjectID]) REFERENCES [dim].[OECProject] ([OECProjectID])
GO
ALTER TABLE [fact].[OEC] ADD CONSTRAINT [FK_OEC_Provider] FOREIGN KEY ([ProviderID]) REFERENCES [dim].[Provider] ([ProviderID])
GO
ALTER TABLE [fact].[OEC] ADD CONSTRAINT [FK_OEC_ProviderContact] FOREIGN KEY ([ProviderContactID]) REFERENCES [dim].[ProviderContact] ([ProviderContactID])
GO
ALTER TABLE [fact].[OEC] ADD CONSTRAINT [FK_OEC_ProviderLocation] FOREIGN KEY ([ProviderLocationID]) REFERENCES [dim].[ProviderLocation] ([ProviderLocationID])
GO
ALTER TABLE [fact].[OEC] ADD CONSTRAINT [FK_OEC_VendorContact] FOREIGN KEY ([VendorContactID]) REFERENCES [dim].[VendorContact] ([VendorContactID])
GO
ALTER TABLE [fact].[OEC] ADD CONSTRAINT [FK_OEC_VendorLocation] FOREIGN KEY ([VendorLocationID]) REFERENCES [dim].[VendorLocation] ([VendorLocationID])
GO
