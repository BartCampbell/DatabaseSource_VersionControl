CREATE TABLE [dbo].[Eligibility]
(
[EligibilityID] [int] NOT NULL IDENTITY(1, 1),
[Client] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DataSource] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DateEffective] [smalldatetime] NOT NULL,
[DateTerminated] [smalldatetime] NULL,
[HealthPlanID] [int] NOT NULL,
[MemberID] [int] NOT NULL,
[ProductType] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProductPriority] [int] NULL,
[HealthPlanEmployeeFlag] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CoverageDentalFlag] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CoveragePharmacyFlag] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CoverageMHInpatientFlag] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CoverageMHDayNightFlag] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CoverageMHAmbulatoryFlag] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CoverageCDInpatientFlag] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CoverageCDDayNightFlag] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CoverageCDAmbulatoryFlag] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CoverageHospiceFlag] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HedisMeasureID] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustomerPCPID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Eligibility] ADD CONSTRAINT [actEligibility_PK] PRIMARY KEY CLUSTERED  ([EligibilityID]) ON [PRIMARY]
GO
CREATE STATISTICS [sp_actEligibility_PK] ON [dbo].[Eligibility] ([EligibilityID])
GO
ALTER TABLE [dbo].[Eligibility] ADD CONSTRAINT [actHealthPlan_Eligibility_FK1] FOREIGN KEY ([HealthPlanID]) REFERENCES [dbo].[HealthPlan] ([HealthPlanID])
GO
ALTER TABLE [dbo].[Eligibility] ADD CONSTRAINT [actMember_Eligibility_FK1] FOREIGN KEY ([MemberID]) REFERENCES [dbo].[Member] ([MemberID])
GO
