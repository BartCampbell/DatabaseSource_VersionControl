CREATE TABLE [dbo].[tblClaimLineDetail]
(
[ClaimLineDetail_PK] [bigint] NOT NULL IDENTITY(1, 1),
[Suspect_PK] [bigint] NOT NULL,
[ClaimID] [varchar] (50) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[ServiceLine] [varchar] (10) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[RevenueCode] [varchar] (20) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[ServiceCode] [varchar] (20) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[ServiceModifierCode] [varchar] (10) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[BillTypeCode] [varchar] (10) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[FacilityTypeCode] [varchar] (10) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[ProviderNPI] [varchar] (20) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[ProviderLastName] [varchar] (50) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[ProviderFirstName] [varchar] (50) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[ProviderSpecialty] [varchar] (50) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[ProviderAddress] [varchar] (50) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[ProviderCity] [varchar] (50) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[ProviderState] [varchar] (20) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[ProviderZip] [varchar] (20) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[ProviderPhone] [varchar] (20) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[ProviderFax] [varchar] (20) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[EmployeeYN] [varchar] (1) COLLATE SQL_Latin1_General_CP437_CI_AI NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblClaimLineDetail] ADD CONSTRAINT [PK_tblClaimLineDetail] PRIMARY KEY CLUSTERED  ([ClaimLineDetail_PK]) ON [PRIMARY]
GO
