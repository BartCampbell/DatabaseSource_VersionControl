CREATE TABLE [dbo].[RAPSClusterStaging]
(
[HPlan] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClaimNumber] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MemberID] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MemberHICN] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MemberLast] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MemberFirst] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MemberDOB] [datetime] NULL,
[MemberGender] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EligDateFrom] [datetime] NULL,
[EligDateTo] [datetime] NULL,
[EligType] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DOSFrom] [datetime] NULL,
[DOSTo] [datetime] NULL,
[PlaceOfService] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BillTypeCode] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderNPI] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderTaxonomyCode] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderSpecialtyCode] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderTypeDesc] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RAPSProviderTypeCode] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClaimTypeCode] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AdmissionDate] [datetime] NULL,
[DischargeDate] [datetime] NULL,
[DXCode] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DXCodeVersion] [int] NULL,
[SubmittableFlag] [bit] NULL,
[RAPSClusterStagingID] [int] NOT NULL IDENTITY(1, 1)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[RAPSClusterStaging] ADD CONSTRAINT [PK_RAPSClusterStaging] PRIMARY KEY CLUSTERED  ([RAPSClusterStagingID]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
