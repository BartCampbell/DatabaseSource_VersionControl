CREATE TABLE [dbo].[RAPSCIStaging]
(
[HPLan] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClaimNumber] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MemberID] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MemberHICN] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MemberLast] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MemberFirst] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MemberDOB] [datetime] NULL,
[MemberGender] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EligDateFrom] [datetime] NULL,
[EligDateTo] [datetime] NULL,
[EligType] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DOSFrom] [datetime] NULL,
[DOSTo] [datetime] NULL,
[ProviderNPI] [int] NULL,
[ProviderTaxonomyCode] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RAPSProviderTypeCode] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DXCode] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DXCodeVersion] [int] NULL,
[SubmittableFlag] [bit] NULL,
[SourceKey] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RAPSCIStagingID] [int] NOT NULL IDENTITY(1, 1)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[RAPSCIStaging] ADD CONSTRAINT [PK_RAPSCIStaging] PRIMARY KEY CLUSTERED  ([RAPSCIStagingID]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
