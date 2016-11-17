CREATE TABLE [x12].[LoopEntity]
(
[Entity_RowID] [int] NULL,
[Entity_RowIDParent] [int] NULL,
[Entity_CentauriClientID] [int] NULL,
[Entity_FileLogID] [int] NULL,
[Entity_TransactionImplementationConventionReference] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Entity_TransactionControlNumber] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Entity_LoopID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Entity_EntityIdentifierCode_NM101] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Entity_EntityTypeQualifier_NM102] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Entity_NameLastOrEntityName_NM103] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Entity_FirstName_NM104] [varchar] (35) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Entity_MiddleName_NM105] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Entity_NamePrefix_NM106] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Entity_NameSuffix_NM107] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Entity_IdentificationCodeQualifier_NM108] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Entity_IndentificationCode_NM109] [varchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Entity_EntityRelationshipCode_NM110] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Entity_EntityIdentifierCode_NM111] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Entity_NameLastOrOrganizaionName_NM112] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Entity_AddressInformation_N301] [varchar] (55) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Entity_AddressInformation_N302] [varchar] (55) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Entity_CityName_N401] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Entity_StateOrProvinceCode_N402] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Entity_PostalCode_N403] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Entity_CountryCode_N404] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Entity_LocationQualifier_N405] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Entity_LocationIdentifier_N406] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Entity_CountrySubdivisionCode_N407] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Entity_DateTimePeriodFormatQualifier_DMG01] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Entity_DateTimePeriod_DMG02] [varchar] (35) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Entity_GenderCode_DMG03] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Entity_MaritalStatusCode_DMG04] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Entity_CompositeRaceOrEthnicityInformation_DMG05] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Entity_CitizenshipStatusCode_DMG06] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Entity_CountryCode_DMG07] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Entity_BasisofVerificationCode_DMG08] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Entity_Quantity_DMG09] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Entity_CodeListQualifierCode_DMG10] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Entity_IndustryCode_DMG11] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Entity_ProviderCode_PRV01] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Entity_ReferenceIdentificationQualifier_PRV02] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Entity_ReferenceIdentification_PRV03] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Entity_StateOrProvinceCode_PRV04] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Entity_ProviderSpecialtyInformation_PRV05] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Entity_ProviderOrganizationCode_PRV06] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
