CREATE TABLE [dbo].[ProviderMedicalGroup]
(
[ProviderMedicalGroupID] [int] NOT NULL IDENTITY(1, 1),
[Address1] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Address2] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[City] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Client] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DataSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HedisMeasureID] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ihds_prov_id_med_group] [uniqueidentifier] NULL,
[MedicalGroupEIN] [char] (9) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MedicalGroupName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ProviderID] [int] NULL,
[State] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ZipCode] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PayerGroupID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PayerGroupKey] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderPOD] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
