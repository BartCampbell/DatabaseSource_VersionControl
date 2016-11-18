CREATE TABLE [fact].[OECClaimLineDetail]
(
[OECClaimLineDetailID] [bigint] NOT NULL IDENTITY(1, 1),
[MemberID] [int] NOT NULL,
[OECProjectID] [int] NOT NULL,
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
[EmployeeYN] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CreateDate] [datetime] NOT NULL,
[LastUpdate] [datetime] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [fact].[OECClaimLineDetail] ADD CONSTRAINT [PK_OECClaimLineDetail] PRIMARY KEY CLUSTERED  ([OECClaimLineDetailID]) ON [PRIMARY]
GO
ALTER TABLE [fact].[OECClaimLineDetail] ADD CONSTRAINT [FK_OECClaimLineDetail_Member] FOREIGN KEY ([MemberID]) REFERENCES [dim].[Member] ([MemberID])
GO
ALTER TABLE [fact].[OECClaimLineDetail] ADD CONSTRAINT [FK_OECClaimLineDetail_OECProject] FOREIGN KEY ([OECProjectID]) REFERENCES [dim].[OECProject] ([OECProjectID])
GO
