CREATE TABLE [dbo].[healthplan_20170425]
(
[HealthPlanID] [int] NOT NULL IDENTITY(1, 1),
[Address1] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Address2] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[City] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Client] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ContactName] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DataSource] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Email] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Fax] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HealthPlanIDQualifier] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HealthPlanName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MPISourceName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Phone] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[State] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ZipCode] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustomerHealthPlanID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
