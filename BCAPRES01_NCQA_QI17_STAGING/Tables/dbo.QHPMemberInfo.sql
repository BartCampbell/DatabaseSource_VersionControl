CREATE TABLE [dbo].[QHPMemberInfo]
(
[EligibilityID] [int] NULL,
[MemberID] [int] NULL,
[IssuerName] [varchar] (41) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[IssuerID] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[QHPState] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ReportingUnitID] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[StandardComponentID] [varchar] (14) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MetalLevel] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[VariantID] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MSPFlag] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MarketCoverage] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[EnrollmentRoute] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SpokenLanguage] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[WrittenLanguage] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[APTCorCSREligibilityFlag] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Hispanic] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Race] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CitizenshipStatus] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PlanMarketingName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MedicaidExpansionQHPEnrollee] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[YearPlanBeganOperating] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
