CREATE TABLE [stage].[MemorilaHermannChaseCommerical2016_12_15]
(
[clcl_id] [sys].[sysname] NULL,
[MemberNumber] [sys].[sysname] NULL,
[LowDateOfService] [sys].[sysname] NULL,
[Paid_Dt] [sys].[sysname] NULL,
[BIRTH_DT] [sys].[sysname] NULL,
[SEX_CD] [sys].[sysname] NULL,
[PRODUCTPLAN] [sys].[sysname] NULL,
[PRODUCTNAME] [sys].[sysname] NULL,
[Admit Date] [sys].[sysname] NULL,
[Discharge Date] [sys].[sysname] NULL,
[CLASS_PLAN_ID] [sys].[sysname] NULL,
[MemberFullName] [sys].[sysname] NULL,
[MemberFirstName] [sys].[sysname] NULL,
[MemberLastName] [sys].[sysname] NULL,
[BillingProviderName] [sys].[sysname] NULL,
[BillingProviderNPI] [sys].[sysname] NULL,
[BillingProviderUniqueID] [sys].[sysname] NULL,
[BillingProviderTIN] [sys].[sysname] NULL,
[BillingProviderTinName] [sys].[sysname] NULL,
[PAYEE_PRIM_ADDR_LN_1] [sys].[sysname] NULL,
[PAYEE_PRIM_ADDR_LN_2] [sys].[sysname] NULL,
[PAYEE_PRIM_ADDR_LN_3] [sys].[sysname] NULL,
[PAYEE_PRIM_CITY_NAME] [sys].[sysname] NULL,
[PAYEE_PRIM_STATE_CD] [sys].[sysname] NULL,
[PAYEE_PRIM_POSTAL] [sys].[sysname] NULL,
[PAYEE_PRIM_PHONE_NUM] [sys].[sysname] NULL,
[PAYEE_PRIM_FAX_NUM] [sys].[sysname] NULL,
[ServiceProviderName] [sys].[sysname] NULL,
[ServiceProviderNPI] [sys].[sysname] NULL,
[ServiceProviderUniqueID] [sys].[sysname] NULL,
[ServiceProviderTIN] [sys].[sysname] NULL,
[ServiceProviderTinName] [sys].[sysname] NULL,
[SVC_PRIM_ADDR_LN_1] [sys].[sysname] NULL,
[SVC_PRIM_ADDR_LN_2] [sys].[sysname] NULL,
[SVC_PRIM_ADDR_LN_3] [sys].[sysname] NULL,
[SVC_PRIM_CITY_NAME] [sys].[sysname] NULL,
[SVC_PRIM_STATE_CD] [sys].[sysname] NULL,
[SVC_PRIM_POSTAL] [sys].[sysname] NULL,
[SVC_PRIM_PHONE_NUM] [sys].[sysname] NULL,
[SVC_PRIM_FAX_NUM] [sys].[sysname] NULL,
[FAC_ProviderName] [sys].[sysname] NULL,
[FAC_ProviderNPI] [sys].[sysname] NULL,
[FAC_UniqueID] [sys].[sysname] NULL,
[FAC_ProviderTIN] [sys].[sysname] NULL,
[FAC_ProviderTinName] [sys].[sysname] NULL,
[FAC_PRIM_ADDR_LN_1] [sys].[sysname] NULL,
[FAC_PRIM_ADDR_LN_2] [sys].[sysname] NULL,
[FAC_PRIM_ADDR_LN_3] [sys].[sysname] NULL,
[FAC_PRIM_CITY_NAME] [sys].[sysname] NULL,
[FAC_PRIM_STATE_CD] [sys].[sysname] NULL,
[FAC_PRIM_POSTAL] [sys].[sysname] NULL,
[FAC_PRIM_PHONE_NUM] [sys].[sysname] NULL,
[FAC_PRIM_FAX_NUM] [sys].[sysname] NULL,
[Claim_Category_Primary1] [sys].[sysname] NULL,
[Claim_Category_Primary2] [sys].[sysname] NULL,
[Claim_Category_Primary3] [sys].[sysname] NULL,
[Claim_Category_Secondary1] [sys].[sysname] NULL,
[Claim_Category_Secondary2] [sys].[sysname] NULL,
[Claim_Category_Secondary3] [sys].[sysname] NULL,
[Provider_Specialty_Desc1] [sys].[sysname] NULL,
[Provider_Specialty_Desc2] [sys].[sysname] NULL,
[Provider_Specialty_Desc3] [sys].[sysname] NULL,
[Claim Category] [sys].[sysname] NULL,
[MHMD?] [sys].[sysname] NULL,
[PrimaryProvider_ProviderName] [sys].[sysname] NULL,
[PrimaryProvider_ProviderNPI] [sys].[sysname] NULL,
[PrimaryProvider_UniqueID] [sys].[sysname] NULL,
[PrimaryProvider_ProviderTIN] [sys].[sysname] NULL,
[PrimaryProvider_ProviderTinName] [sys].[sysname] NULL,
[PrimaryProvider_PRIM_ADDR_LN_1] [sys].[sysname] NULL,
[PrimaryProvider_PRIM_ADDR_LN_2] [sys].[sysname] NULL,
[PrimaryProvider_PRIM_ADDR_LN_3] [sys].[sysname] NULL,
[PrimaryProvider_PRIM_CITY_NAME] [sys].[sysname] NULL,
[PrimaryProvider_PRIM_STATE_CD] [sys].[sysname] NULL,
[PrimaryProvider_PRIM_POSTAL] [sys].[sysname] NULL,
[PrimaryProvider_PRIM_PHONE_NUM] [sys].[sysname] NULL,
[PrimaryProvider_PRIM_FAX_NUM] [sys].[sysname] NULL,
[Unique Chart ID] [sys].[sysname] NULL,
[hash] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NewAddress] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NewZip] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RawAddresstoUse] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RawZIPtoUse] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PhoneUSed] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FAXUSed] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NPIUsed] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CentuariProviderID] [bigint] NULL,
[Member_PK] [bigint] NULL,
[Provider_PK] [bigint] NULL,
[ProviderMaster_PK] [bigint] NULL,
[ProviderOffice_PK] [bigint] NULL,
[Omit] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UniqueChart] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
