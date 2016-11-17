CREATE TABLE [dbo].[FHN_HFS_RegistryFile_20160706]
(
[Provider_Number] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Provider_Name] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Provider_StreetAddress] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Provider_StreetAddress2] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Provider_City] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Provider_State] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Provider_ZipCode] [varchar] (11) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Provider_LicenseNum] [varchar] (9) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Provider_Type] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Enrollent_Status] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Maternal-Child_Provider] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CategoryofService] [varchar] (75) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EligBeginForCategoryofService] [varchar] (7) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EligEndForCategoryofService] [varchar] (7) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Provider_FaxNumber] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Provider_MedicarePartANumber] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Provider_DEA_Num] [varchar] (9) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UniquePhysicianID] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderAMAorADANum] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EnrollmentBeginDate] [varchar] (7) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EnrollmentEndDate] [varchar] (7) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NPI] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Filler] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Stuff] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MoreStuff] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecID] [int] NOT NULL IDENTITY(1, 1)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FHN_HFS_RegistryFile_20160706] ADD CONSTRAINT [PK_FHN_HFS_RegistryFile_20160706] PRIMARY KEY CLUSTERED  ([RecID]) ON [PRIMARY]
GO
