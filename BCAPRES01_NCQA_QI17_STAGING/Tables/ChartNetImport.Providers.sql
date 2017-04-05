CREATE TABLE [ChartNetImport].[Providers]
(
[CustomerProviderID] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[NameEntityFullName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderEntityType] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NameFirst] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NameLast] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NameMiddleInitial] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NamePrefix] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NameSuffix] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NameTitle] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DateOfBirth] [smalldatetime] NULL,
[Gender] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EIN] [char] (9) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SSN] [char] (9) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TaxID] [varchar] (11) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UPIN] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NPI] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MedicaidID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DEANumber] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LicenseNumber] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderType] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SpecialtyCode1] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SpecialtyCode2] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PCPFlag] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OBGynFlag] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderPrescribingPrivFlag] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MentalHealthFlag] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EyeCareFlag] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DentistFlag] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NephrologistFlag] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CDProviderFlag] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NursePractFlag] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PhysicianAsstFlag] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [ChartNetImport].[Providers] ADD CONSTRAINT [PK_Providers] PRIMARY KEY CLUSTERED  ([CustomerProviderID]) ON [PRIMARY]
GO
