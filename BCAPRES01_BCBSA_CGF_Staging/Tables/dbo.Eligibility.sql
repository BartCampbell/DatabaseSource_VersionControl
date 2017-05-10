CREATE TABLE [dbo].[Eligibility]
(
[EligibilityID] [int] NOT NULL IDENTITY(1, 1),
[Client] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DataSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DateEffective] [datetime] NULL,
[DateRowCreated] [datetime] NULL,
[DateTerminated] [datetime] NULL,
[HealthPlanID] [int] NOT NULL,
[MemberID] [int] NOT NULL,
[RowID] [int] NULL,
[ProductType] [char] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CoverageCDAmbulatoryFlag] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CoverageCDDayNightFlag] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CoverageCDInpatientFlag] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CoverageDentalFlag] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CoverageMHAmbulatoryFlag] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CoverageMHDayNightFlag] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CoverageMHInpatientFlag] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CoveragePharmacyFlag] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadInstanceFileID] [int] NULL,
[EmployerGroup] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CoverageHospiceFlag] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProductPriority] [int] NULL,
[HedisMeasureID] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HealthPlanEmployeeFlag] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PlanProduct] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [dbo_Eligibility]
GO
