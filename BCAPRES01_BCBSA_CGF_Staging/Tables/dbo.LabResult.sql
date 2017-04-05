CREATE TABLE [dbo].[LabResult]
(
[LabResultID] [int] NOT NULL IDENTITY(1, 1),
[Client] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DataSource] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MemberID] [int] NOT NULL,
[CustomerMemberID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CustomerOrderingProviderID] [int] NOT NULL,
[DateOfService] [smalldatetime] NULL,
[HCPCSProcedureCode] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HedisMeasureID] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ihds_member_id] [int] NULL,
[ihds_prov_id_ordering] [int] NULL,
[InstanceID] [uniqueidentifier] NULL,
[LabProviderID] [int] NOT NULL,
[LabValue] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LOINCCode] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OrderNumber] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PNIndicator] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SupplementalDataFlag] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SupplementalDataCategory] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CVX] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DateServiceBegin] [datetime] NULL,
[DateServiceEnd] [datetime] NULL,
[SNOMEDCode] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SupplementalDataCode] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [dbo_LabResult]
GO
CREATE NONCLUSTERED INDEX [idxLabResultID] ON [dbo].[LabResult] ([LabResultID]) INCLUDE ([DateOfService]) ON [dbo_LabResult_IDX]
GO
CREATE CLUSTERED INDEX [idxmemberID] ON [dbo].[LabResult] ([MemberID], [LabResultID]) ON [dbo_LabResult]
GO
CREATE STATISTICS [spidxLabResultID] ON [dbo].[LabResult] ([LabResultID])
GO
CREATE STATISTICS [spidxmemberID] ON [dbo].[LabResult] ([MemberID], [LabResultID])
GO
