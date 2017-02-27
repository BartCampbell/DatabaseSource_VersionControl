CREATE TABLE [dbo].[L_PharmacyPharmacyClaim]
(
[L_PharmacyPharmacyClaim_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[H_Pharmacy_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[H_PharmacyClaim_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordEndDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[L_PharmacyPharmacyClaim] ADD CONSTRAINT [PK_L_PharmacyPharmacyClaim] PRIMARY KEY CLUSTERED  ([L_PharmacyPharmacyClaim_RK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[L_PharmacyPharmacyClaim] ADD CONSTRAINT [FK_PharmacyPharmacyClaim_H_Pharmacy_RK] FOREIGN KEY ([H_Pharmacy_RK]) REFERENCES [dbo].[H_Pharmacy] ([H_Pharmacy_RK]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[L_PharmacyPharmacyClaim] ADD CONSTRAINT [FK_PharmacyPharmacyClaim_H_PharmacyClaim_RK] FOREIGN KEY ([H_PharmacyClaim_RK]) REFERENCES [dbo].[H_PharmacyClaim] ([H_PharmacyClaim_RK]) ON DELETE CASCADE ON UPDATE CASCADE
GO
