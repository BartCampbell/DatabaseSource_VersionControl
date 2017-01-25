CREATE TABLE [dbo].[ProviderMedicalGroup]
(
[ProviderMedicalGroupID] [int] NOT NULL IDENTITY(1, 1),
[Address1] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Address2] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[City] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Client] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DataSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HedisMeasureID] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ihds_prov_id_med_group] [uniqueidentifier] NULL,
[MedicalGroupEIN] [char] (9) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MedicalGroupName] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderID] [int] NULL,
[State] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ZipCode] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CustomerGroupID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustomerGroupKey] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SourceSystem] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ProviderMedicalGroup] ADD CONSTRAINT [pk_ProviderMedicalGroup] PRIMARY KEY CLUSTERED  ([ProviderMedicalGroupID]) ON [PRIMARY]
GO
CREATE STATISTICS [sp_pk_ProviderMedicalGroup] ON [dbo].[ProviderMedicalGroup] ([ProviderMedicalGroupID])
GO
