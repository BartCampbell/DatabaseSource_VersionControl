CREATE TABLE [ref].[CMSMonthlyReportByPlan]
(
[CMSMonthlyReportByPlanID] [int] NOT NULL IDENTITY(1, 1),
[ContractNumber] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PlanID] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OrganizationType] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PlanType] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OffersPartD] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OrganizationName] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OrganizationMarketingName] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PlanName] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ParentOrganization] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ContractEffectiveDate] [date] NULL,
[Enrollment] [bigint] NULL,
[LastUpdated] [datetime] NULL,
[RecordSource] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [ref].[CMSMonthlyReportByPlan] ADD CONSTRAINT [PK_CMSMonthlyReportByPlan] PRIMARY KEY CLUSTERED  ([CMSMonthlyReportByPlanID]) ON [PRIMARY]
GO
