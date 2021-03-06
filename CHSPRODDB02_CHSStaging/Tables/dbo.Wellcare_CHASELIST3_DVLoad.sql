CREATE TABLE [dbo].[Wellcare_CHASELIST3_DVLoad]
(
[Client_ID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Chase_ID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Member_ID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Member_HICN] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Medical_Record_ID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Member_Last_Name] [varchar] (75) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Member_First_Name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Member_DOB] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Member_Gender] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Provider_ID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Provider_NPI] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Provider_Last_Name] [varchar] (75) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Provider_First_Name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Provider_Specialty] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Provider_Office_Address] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Provider_Office_City] [varchar] (75) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Provider_Office_State] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Provider_Office_Zip] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Provider_Office_Phone] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Provider_Office_Fax] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Provider_Group_Name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Provider_Group_ID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Vendor_Name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Vendor_ID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Vendor_Address] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Vendor_City] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Vendor_State] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Vendor_Zip] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Vendor_Phone] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Vendor_Fax] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Chase_Priority] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Provider_Relations_Rep] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Claim_ID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Diagnosis_Code] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ICD9_ICD10_Ind] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DOS_From_Date] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DOS_To_Date] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ExistingProvider] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ExistingProviderAdd] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NewAddress] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NewZip] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AddressUsed] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ZIPUSed] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LOB] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AdvanceAddress] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AdvanceZIP] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DataIssue] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PhoneUsed] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FaxUsed] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderMaster_PK] [bigint] NULL,
[CentuariProviderID] [bigint] NULL,
[Member_PK] [bigint] NULL,
[Provider_PK] [bigint] NULL,
[ProviderOffice_PK] [bigint] NULL,
[ExistingProvNew] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LocRecID] [int] NULL,
[H_Provider_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[H_Member_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[H_Client_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[H_Location_RK_Provider] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[H_Location_RK_Vendor] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[H_Specialty_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[H_OECProject_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[H_Vendor_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[H_Contact_RK_Provider] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[H_Contact_RK_Vendor] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[L_MemberOEC_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[L_MemberProvider_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[L_OECProviderContact_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[L_OECVendorContact_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[L_OECProviderLocation_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[L_OECVendorLocation_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[L_ProviderSpecialty_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[L_OECProjectOEC_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
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
[S_OECProject_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[S_OECProject_HashDiff] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Location_BK_Provider] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Location_BK_Vendor] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Contact_BK_Provider] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Contact_BK_Vendor] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OECProject_BK] [int] NULL,
[OEC_ProjectID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OEC_ProjectName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CentauriMemberID] [int] NULL,
[LoadDate] [datetime] NULL,
[ClientName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
