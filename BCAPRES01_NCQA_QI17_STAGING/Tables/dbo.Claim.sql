CREATE TABLE [dbo].[Claim]
(
[ClaimID] [int] NOT NULL IDENTITY(1, 1),
[BillingProviderID] [int] NULL,
[BillType] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClaimDisallowReason] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClaimType] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClaimTypeIndicator] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClaimStatus] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Client] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DataSource] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DateClaimPaid] [smalldatetime] NULL,
[DateServiceBegin] [smalldatetime] NULL,
[DateServiceEnd] [smalldatetime] NULL,
[DiagnosisCode1] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DiagnosisCode2] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DiagnosisCode3] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DiagnosisCode4] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DiagnosisCode5] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DiagnosisCode6] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DiagnosisCode7] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DiagnosisCode8] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DiagnosisCode9] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DiagnosisCode10] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DiagnosisCode11] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DiagnosisCode12] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DiagnosisCode13] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DiagnosisCode14] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DiagnosisCode15] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DiagnosisCode16] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DiagnosisCode17] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DiagnosisCode18] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DiagnosisCode19] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DiagnosisCode20] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DischargeStatus] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DiagnosisRelatedGroup] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DiagnosisRelatedGroupType] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HealthPlanID] [int] NULL,
[HedisMeasureID] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ihds_member_id] [int] NULL,
[ihds_prov_id_attending] [int] NULL,
[ihds_prov_id_billing] [int] NULL,
[ihds_prov_id_med_group] [int] NULL,
[ihds_prov_id_pcp] [int] NULL,
[ihds_prov_id_referring] [int] NULL,
[ihds_prov_id_servicing] [int] NULL,
[ihds_prov_id_vendor] [int] NULL,
[InstanceID] [uniqueidentifier] NULL,
[MedicarePaidIndicator] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MemberID] [int] NULL,
[PatientStatus] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PayerClaimID] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PayerClaimIDSuffix] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PayerID] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PlaceOfService] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordType] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ReferringProviderID] [int] NULL,
[ServicingProviderID] [int] NULL,
[SurgicalProcedure1] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SurgicalProcedure2] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SurgicalProcedure3] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SurgicalProcedure4] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SurgicalProcedure5] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SurgicalProcedure6] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SurgicalProcedure7] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SurgicalProcedure8] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SurgicalProcedure9] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SurgicalProcedure10] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SurgicalProcedure11] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SurgicalProcedure12] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SurgicalProcedure13] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SurgicalProcedure14] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SurgicalProcedure15] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SurgicalProcedure16] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SurgicalProcedure17] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SurgicalProcedure18] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SurgicalProcedure19] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SurgicalProcedure20] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SupplementalDataFlag] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__Claim__Supplemen__485D3337] DEFAULT ('N'),
[ICDCodeType] [tinyint] NOT NULL CONSTRAINT [Claim_ICDCodeType] DEFAULT ((9)),
[SupplementalDataCode] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Claim] ADD CONSTRAINT [actClaim_PK] PRIMARY KEY CLUSTERED  ([ClaimID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [tmp_IX_fromTransformEncounterClaims] ON [dbo].[Claim] ([DiagnosisCode10]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Claim_HedisMeasureID] ON [dbo].[Claim] ([HedisMeasureID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ix_Claim_ihds_member_id] ON [dbo].[Claim] ([ihds_member_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ix_Claim_MemberID] ON [dbo].[Claim] ([MemberID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ix_Claim_PayerClaimID] ON [dbo].[Claim] ([PayerClaimID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Claim_ServicingProviderID] ON [dbo].[Claim] ([ServicingProviderID]) ON [PRIMARY]
GO
CREATE STATISTICS [sp_actClaim_PK] ON [dbo].[Claim] ([ClaimID])
GO
CREATE STATISTICS [sp_tmp_IX_fromTransformEncounterClaims] ON [dbo].[Claim] ([DiagnosisCode10])
GO
CREATE STATISTICS [sp_IX_Claim_HedisMeasureID] ON [dbo].[Claim] ([HedisMeasureID])
GO
CREATE STATISTICS [sp_ix_Claim_ihds_member_id] ON [dbo].[Claim] ([ihds_member_id])
GO
CREATE STATISTICS [sp_ix_Claim_MemberID] ON [dbo].[Claim] ([MemberID])
GO
CREATE STATISTICS [sp_ix_Claim_PayerClaimID] ON [dbo].[Claim] ([PayerClaimID])
GO
CREATE STATISTICS [sp_IX_Claim_ServicingProviderID] ON [dbo].[Claim] ([ServicingProviderID])
GO
ALTER TABLE [dbo].[Claim] ADD CONSTRAINT [actMember_Claim_FK1] FOREIGN KEY ([MemberID]) REFERENCES [dbo].[Member] ([MemberID])
GO
ALTER TABLE [dbo].[Claim] ADD CONSTRAINT [actProvider_Claim_FK1] FOREIGN KEY ([ReferringProviderID]) REFERENCES [dbo].[Provider] ([ProviderID])
GO
ALTER TABLE [dbo].[Claim] ADD CONSTRAINT [actProvider_Claim_FK2] FOREIGN KEY ([ServicingProviderID]) REFERENCES [dbo].[Provider] ([ProviderID])
GO
ALTER TABLE [dbo].[Claim] ADD CONSTRAINT [actProvider_Claim_FK3] FOREIGN KEY ([BillingProviderID]) REFERENCES [dbo].[Provider] ([ProviderID])
GO
ALTER TABLE [dbo].[Claim] ADD CONSTRAINT [FK__Claim__HealthPla__147C05D0] FOREIGN KEY ([HealthPlanID]) REFERENCES [dbo].[HealthPlan] ([HealthPlanID])
GO
ALTER TABLE [dbo].[Claim] ADD CONSTRAINT [FK_Claim_Provider] FOREIGN KEY ([ReferringProviderID]) REFERENCES [dbo].[Provider] ([ProviderID])
GO
ALTER TABLE [dbo].[Claim] ADD CONSTRAINT [FK_Claim_Provider1] FOREIGN KEY ([ServicingProviderID]) REFERENCES [dbo].[Provider] ([ProviderID])
GO
ALTER TABLE [dbo].[Claim] ADD CONSTRAINT [FK_Claim_Provider2] FOREIGN KEY ([BillingProviderID]) REFERENCES [dbo].[Provider] ([ProviderID])
GO
