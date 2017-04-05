CREATE TABLE [dbo].[ProviderMedicalGroup]
(
[ProviderMedicalGroupID] [int] NOT NULL IDENTITY(1, 1),
[Address1] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Address2] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[City] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Client] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DataSource] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HedisMeasureID] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ihds_prov_id_med_group] [uniqueidentifier] NULL,
[MedicalGroupEIN] [char] (9) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MedicalGroupName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ProviderID] [int] NULL,
[State] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ZipCode] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ProviderMedicalGroup] ADD CONSTRAINT [actProviderMedicalGroup_PK] PRIMARY KEY CLUSTERED  ([ProviderMedicalGroupID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ProviderMedicalGroup] ADD CONSTRAINT [actProvider_ProviderMedicalGroup_FK1] FOREIGN KEY ([ProviderID]) REFERENCES [dbo].[Provider] ([ProviderID])
GO
ALTER TABLE [dbo].[ProviderMedicalGroup] ADD CONSTRAINT [FK_ProviderMedicalGroup_Provider] FOREIGN KEY ([ProviderID]) REFERENCES [dbo].[Provider] ([ProviderID]) ON DELETE CASCADE
GO
