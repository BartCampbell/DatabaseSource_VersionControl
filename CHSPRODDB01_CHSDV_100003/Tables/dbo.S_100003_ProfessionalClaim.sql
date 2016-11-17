CREATE TABLE [dbo].[S_100003_ProfessionalClaim]
(
[CLAIM_ID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CLAIM_SFX_OR_PARENT] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SV_LINE] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FORM_TYPE] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SV_STAT] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ADM_DATE] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ADM_TYPE] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ADM_SRC] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DIS_DATE] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CLIENT_LOS] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FROM_DATE] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TO_DATE] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HOSP_TYPE] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClientMemberID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MEMBER_QUAL] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RELATION] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[GRP_ID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CLAIM_REC_DATE] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CLAIM_ENTRY_DATE] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PAID_DATE] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CHK_NUM] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MS_DRG] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TRI_DRG] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AP_DRG] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[APR_DRG] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[APR_DRG_SEV] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CONT_STAY_ID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ICD_DIAG_ADMIT] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ICD_DIAG_01] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ICD_PROC_01] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ICD10_OR_HIGHER] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ATT_PROV] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ATT_PROV_SPEC] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ATT_IPA] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ATT_ACO] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BILL_PROV] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[REF_PROV] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ACO_ID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MED_HOME_ID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CONTRACT] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BEN_PKG_ID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[POS] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UB_BILL_TYPE] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TOS] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PROC_CODE] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CPT_MOD_1] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CPT_MOD_2] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[REV_CODE] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NDC] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RX_DAYS_SUPPLY] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RX_QTY_DISPENSED] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RX_DRUG_COST] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RX_INGR_COST] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RX_DISP_FEE] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RX_DISCOUNT] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RX_DAW] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RX_FILL_SRC] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RX_REFILLS] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RX_PAR] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RX_FORM] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SV_UNITS] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AMT_BILLED] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AMT_ALLOWED] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AMT_ALLOWED_STAT] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AMT_PAID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AMT_HRA] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AMT_DEDUCT] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AMT_COINS] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AMT_COPAY] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AMT_COB] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AMT_WITHHOLD] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AMT_DISALLOWED] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AMT_MAXIMUM] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AUTH_ID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DIS_STAT] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BABY_WGHT] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[WEEKS_GEST] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BABY_CLAIM_ID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL_DATA_SRC] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MI_POST_DATE] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CLAIM_IN_NETWORK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MAINTENANCEDATE] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RESPONSIBLEINDICATOR] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OPID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FFSCAPIND] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PROCESSINGENTITY] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SITEID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CONTRACTORIGIN] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CARECORERESPONSIBLEAMT] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NYHCRASURCHARGEAMOUNT] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MEDICARESEQUESTRATIONIND] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MEDICAREORIGINALAMOUNT] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NATIVEALLOWEDAMOUNT] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PARTICIPATINGPROVIDERIND] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[COBINDICATOR] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EMPLOYERGROUPMOD] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EMPLOYERGROUPTYPE] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BENEFITSEQUENCE] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EOCCODE] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SERVICINGPROVLOCSUFFIX] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BILLINGPROVLOCATIONSUFFIX] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[REFERRINGPROVLOCATIONSUFFIX] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SERVICEYEARMONTH] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL,
[RecordSource] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClientHashKey] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CMI] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CCI] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MemberHashKey] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[S_100003_ProfessionalClaim_RK] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[H_100003_Member_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[S_100003_ProfessionalClaim] ADD CONSTRAINT [PK__S_100003__C9BCCD92E7AE03BA] PRIMARY KEY CLUSTERED  ([S_100003_ProfessionalClaim_RK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[S_100003_ProfessionalClaim] ADD CONSTRAINT [FK_S_100003_ProfessionalClaim_H_100003_Member] FOREIGN KEY ([H_100003_Member_RK]) REFERENCES [dbo].[H_100003_Member] ([H_Member_RK])
GO
