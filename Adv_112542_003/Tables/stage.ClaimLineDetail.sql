CREATE TABLE [stage].[ClaimLineDetail]
(
[ChaseID] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClientMemberID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClaimID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ServiceLine] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RevenueCode] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ServiceCode] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ServiceModifierCode] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BillTypeCode] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FacilityTypeCode] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderNPI] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderLastName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderFirstName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderSpecialty] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderAddress] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderCity] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderState] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderZip] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderPhone] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderFax] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EmployeeYN] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
