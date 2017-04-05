CREATE TABLE [dbo].[Provider]
(
[ProviderID] [int] NOT NULL IDENTITY(1, 1),
[CustomerProviderID] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BoardCertification1] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BoardCertification2] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Client] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DataSource] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DateOfBirth] [smalldatetime] NULL,
[DEANumber] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EIN] [char] (9) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Gender] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HedisMeasureID] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ihds_prov_id] [int] NULL,
[InstanceID] [uniqueidentifier] NULL,
[LicenseNumber] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MedicaidID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MedicareID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NameFirst] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NameLast] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NameMiddleInitial] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NamePrefix] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NameSuffix] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NameTitle] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NetworkID] [int] NULL,
[NPI] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderType] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SpecialtyCode1] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SpecialtyCode2] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SSN] [char] (9) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TaxID] [varchar] (11) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UPIN] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderPrescribingPrivFlag] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderPaidInpatientRateFlag] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderPaidOutpatientRateFlag] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PCPFlag] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OBGynFlag] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MentalHealthFlag] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EyeCareFlag] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DentistFlag] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NephrologistFlag] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CDProviderFlag] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NursePractFlag] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PhysicianAsstFlag] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClinicalPharmacistFlag] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AnesthesiologistFlag] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HospitalFlag] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SkilledNursingFacFlag] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SurgeonFlag] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RegisteredNurseFlag] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DurableMedEquipmentFlag] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AmbulanceFlag] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Contracted] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RowID] [int] NULL,
[HashValue] [binary] (16) NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Provider] ADD CONSTRAINT [actProvider_PK] PRIMARY KEY CLUSTERED  ([ProviderID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [fk_ihds_prov_id] ON [dbo].[Provider] ([ihds_prov_id]) ON [PRIMARY]
GO
CREATE STATISTICS [sp_fk_ihds_prov_id] ON [dbo].[Provider] ([ihds_prov_id])
GO
CREATE STATISTICS [sp_actProvider_PK] ON [dbo].[Provider] ([ProviderID])
GO
ALTER TABLE [dbo].[Provider] ADD CONSTRAINT [actNetwork_Provider_FK1] FOREIGN KEY ([NetworkID]) REFERENCES [dbo].[Network] ([NetworkID])
GO
