CREATE TABLE [stage].[tblSuspect]
(
[Project_Name] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MemberID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ChaseID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[REN_PROVIDER_SPECIALTY] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ContractCode] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ChasePriority] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MedicalRecordID] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClientProviderID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ConsolidatedProviderID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
