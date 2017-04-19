CREATE TABLE [dbo].[tmp_LabResult]
(
[LabResultID] [int] NULL,
[MemberID] [int] NULL,
[ihds_member_id] [int] NULL,
[DataSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DateOfService] [datetime] NULL,
[CustomerOrderingProviderID] [int] NULL,
[ihds_prov_id_ordering] [int] NULL,
[HCPCSProcedureCode] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LOINCCode] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SupplementalDataFlag] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CVX] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [Tmp_Drive03]
GO
