CREATE TABLE [dbo].[L_ProviderPharmacyClaim]
(
[L_ProviderPharmacyClaim_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[H_Provider_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[H_PharmacyClaim_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordEndDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[L_ProviderPharmacyClaim] ADD CONSTRAINT [PK_L_ProviderPharmacyClaim] PRIMARY KEY CLUSTERED  ([L_ProviderPharmacyClaim_RK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[L_ProviderPharmacyClaim] ADD CONSTRAINT [FK_ProviderPharmacyClaim_H_PharmacyClaim_RK] FOREIGN KEY ([H_PharmacyClaim_RK]) REFERENCES [dbo].[H_PharmacyClaim] ([H_PharmacyClaim_RK]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[L_ProviderPharmacyClaim] ADD CONSTRAINT [FK_ProviderPharmacyClaim_H_Provider_RK] FOREIGN KEY ([H_Provider_RK]) REFERENCES [dbo].[H_Provider] ([H_Provider_RK]) ON DELETE CASCADE ON UPDATE CASCADE
GO
