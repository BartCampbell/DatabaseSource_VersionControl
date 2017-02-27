CREATE TABLE [dbo].[S_Pharmacyesi1900]
(
[S_Pharmacyesi1900_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LoadDate] [datetime] NOT NULL,
[H_Pharmacy_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PharmacyNABPNumber] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PharmacyQualifier] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HashDiff] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordEndDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[S_Pharmacyesi1900] ADD CONSTRAINT [PK_S_Pharmacyesi1900] PRIMARY KEY CLUSTERED  ([S_Pharmacyesi1900_RK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[S_Pharmacyesi1900] ADD CONSTRAINT [FK_S_Pharmacyesi1900_H_Pharmacy] FOREIGN KEY ([H_Pharmacy_RK]) REFERENCES [dbo].[H_Pharmacy] ([H_Pharmacy_RK])
GO
