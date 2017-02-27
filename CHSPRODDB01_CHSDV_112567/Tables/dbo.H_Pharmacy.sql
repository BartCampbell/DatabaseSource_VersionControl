CREATE TABLE [dbo].[H_Pharmacy]
(
[H_Pharmacy_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Pharmacy_BK] [int] NULL,
[ClientPharmacyID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL CONSTRAINT [DF_H_Pharmacy_LoadDate] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[H_Pharmacy] ADD CONSTRAINT [PK_H_Pharmacy] PRIMARY KEY CLUSTERED  ([H_Pharmacy_RK]) ON [PRIMARY]
GO
