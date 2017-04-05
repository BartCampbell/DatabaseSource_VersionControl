CREATE TABLE [dbo].[MemberProvider]
(
[MemberProviderID] [int] NOT NULL IDENTITY(1, 1),
[MemberID] [int] NOT NULL,
[ProviderID] [int] NOT NULL,
[Client] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DataSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DateEffective] [datetime] NOT NULL,
[DateTerminated] [datetime] NULL,
[HedisMeasureID] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderMedicalGroupID] [int] NULL,
[SrcRowid] [int] NULL,
[IHDS_Prov_id] [bigint] NULL
) ON [PRIMARY]
GO
