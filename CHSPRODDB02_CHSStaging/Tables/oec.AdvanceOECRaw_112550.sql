CREATE TABLE [oec].[AdvanceOECRaw_112550]
(
[AdvanceOECRawID] [int] NOT NULL IDENTITY(1, 1),
[FileName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LoadDate] [datetime] NOT NULL,
[ClientID] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ChaseID] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MemberID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MemberHICN] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MedicalRecordID] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MemberLastName] [varchar] (75) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MemberFirstName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MemberDOB] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MemberGender] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderNPI] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderLastName] [varchar] (75) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderFirstName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderSpecialty] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderAddress] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderCity] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderState] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderZip] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderPhone] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderFax] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderGroupName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderGroupID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[VendorName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[VendorID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[VendorAddress] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[VendorCity] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[VendorState] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[VendorZip] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[VendorPhone] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[VendorFax] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ChasePriority] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderRelationsRep] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClaimID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DiagnosisCode] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ICD9_ICD10_Ind] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DOS_FromDate] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DOS_ToDate] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CentauriMemberID] [int] NULL,
[CentauriProviderID] [int] NULL,
[CentauriNetworkID] [int] NULL,
[H_Provider_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[H_Member_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[H_Client_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[H_Location_RK_Provider] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[H_Location_RK_Vendor] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[H_OEC_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[H_Specialty_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[H_OECProject_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[H_Vendor_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[H_Contact_RK_Provider] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[H_Contact_RK_Vendor] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[H_Network_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[L_OECProviderNetwork_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[L_MemberOEC_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[L_MemberProvider_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[L_OECProviderContact_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[L_OECVendorContact_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[L_OECProviderLocation_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[L_OECVendorLocation_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[L_ProviderSpecialty_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[L_OECProjectOEC_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[S_OECDetail_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[S_OECDetail_HashDiff] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[S_MemberDemo_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[S_MemberDemoHashDiff] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[S_ProviderDemo_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[S_ProviderDemoHashDiff] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[S_Vendor_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[S_VendorHashDiff] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[S_Location_RK_Provider] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[S_LocationHashDiff_Provider] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[S_Location_RK_Vendor] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[S_LocationHashDiff_Vendor] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[S_Contact_RK_Provider] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[S_ContactHashDiff_Provider] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[S_Contact_RK_Vendor] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[S_ContactHashDiff_Vendor] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[S_MemberHICN_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[S_MemberHICN_HashDiff] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[S_Network_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[S_NetworkHashDiff] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[S_OECProject_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[S_OECProject_HashDiff] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClientName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Location_BK_Provider] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Location_BK_Vendor] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Contact_BK_Provider] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Contact_BK_Vendor] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OEC_BK] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OECProject_BK] [int] NULL,
[OEC_ProjectID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OEC_ProjectName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[L_MemberOECProject_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Duplicate] [bit] NULL
) ON [PRIMARY]
GO
ALTER TABLE [oec].[AdvanceOECRaw_112550] ADD CONSTRAINT [PK_AdvanceOECRaw_112550] PRIMARY KEY CLUSTERED  ([AdvanceOECRawID]) ON [PRIMARY]
GO