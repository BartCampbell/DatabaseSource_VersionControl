CREATE TABLE [x12].[HierPrv]
(
[HierPrv_RowID] [int] NULL,
[HierPrv_RowIDParent] [int] NULL,
[HierPrv_CentauriClientID] [int] NULL,
[HierPrv_FileLogID] [int] NULL,
[HierPrv_TransactionImplementationConventionReference] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HierPrv_TransactionControlNumber] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HierPrv_LoopID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HierPrv_HierarchicalIDNumber_HL01] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HierPrv_HierarchicalParentIDNumber_HL02] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HierPrv_HierarchicalLevelCode_HL03] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HierPrv_HierarchicalChildCode_HL04] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HierPrv_ProviderCode_PRV01] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HierPrv_ReferenceIdentificationQualifier_PRV02] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HierPrv_ReferenceIdentification_PRV03] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HierPrv_StateOrProvinceCode_PRV04] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HierPrv_ProviderSpecialtyInformation_PRV05] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HierPrv_ProviderOrganizationCode_PRV06] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HierPrv_EntityIdentifierCode_CUR01] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HierPrv_CurrencyCode_CUR02] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HierPrv_ExchangeRate_CUR03] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HierPrv_EntityIdentifierCode_CUR04] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HierPrv_CurrencyCode_CUR05] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HierPrv_CurrencyMarketExchangeCode_CUR06] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HierPrv_DateTimeQualifier_CUR07] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HierPrv_Date_CUR08] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HierPrv_Time_CUR09] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HierPrv_DateTimeQualifier_CUR10] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HierPrv_Date_CUR11] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HierPrv_Time_CUR12] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HierPrv_DateTimeQualifier_CUR13] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HierPrv_Date_CUR14] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HierPrv_Time_CUR15] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HierPrv_DateTimeQualifier_CUR16] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HierPrv_Date_CUR17] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HierPrv_Time_CUR18] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HierPrv_DateTimeQualifier_CUR19] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HierPrv_Date_CUR20] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HierPrv_Time_CUR21] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
