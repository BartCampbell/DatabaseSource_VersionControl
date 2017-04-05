CREATE TABLE [dbo].[LabResult]
(
[LabResultID] [int] NOT NULL IDENTITY(1, 1),
[Client] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DataSource] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MemberID] [int] NOT NULL,
[CustomerMemberID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CustomerOrderingProviderID] [int] NOT NULL,
[DateOfService] [smalldatetime] NULL,
[DateServiceBegin] [smalldatetime] NULL,
[DateServiceEnd] [smalldatetime] NULL,
[HCPCSProcedureCode] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HedisMeasureID] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ihds_member_id] [int] NULL,
[ihds_prov_id_ordering] [int] NULL,
[InstanceID] [uniqueidentifier] NULL,
[LabProviderID] [int] NOT NULL,
[LabValue] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LOINCCode] [varchar] (7) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SNOMEDCode] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OrderNumber] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PNIndicator] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SupplementalDataFlag] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__LabResult__Suppl__4A457BA9] DEFAULT ('N'),
[SupplementalDataCode] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LabStatus] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ResultType] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TestType] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Units] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LabResult] ADD CONSTRAINT [actLabResult_PK] PRIMARY KEY CLUSTERED  ([LabResultID]) ON [PRIMARY]
GO
