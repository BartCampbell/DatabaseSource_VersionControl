CREATE TABLE [dbo].[L_ProviderSpecialty]
(
[L_ProviderSpecialty_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[H_Provider_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[H_Specialty_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordEndDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[L_ProviderSpecialty] ADD CONSTRAINT [PK_L_ProviderSpecialty] PRIMARY KEY CLUSTERED  ([L_ProviderSpecialty_RK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[L_ProviderSpecialty] ADD CONSTRAINT [FK_L_ProviderSpecialty_H_Provider] FOREIGN KEY ([H_Provider_RK]) REFERENCES [dbo].[H_Provider] ([H_Provider_RK])
GO
ALTER TABLE [dbo].[L_ProviderSpecialty] ADD CONSTRAINT [FK_L_ProviderSpecialty_H_Specialty] FOREIGN KEY ([H_Specialty_RK]) REFERENCES [dbo].[H_Specialty] ([H_Specialty_RK])
GO
