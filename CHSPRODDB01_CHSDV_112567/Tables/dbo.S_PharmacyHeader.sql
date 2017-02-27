CREATE TABLE [dbo].[S_PharmacyHeader]
(
[S_PharmacyHeader_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LoadDate] [datetime] NOT NULL,
[H_Pharmacy_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PHR-BATCH-NUMBER] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PHR-END-OF-CYCLE-DATE] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PHR-PHARMACY-NABP-NO] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PHR-VENDOR-NUMBER] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PHR-PHARMACY-NAME] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PHR-HIP-PHARMACY-CODE] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PHR-RECONCILIATION-GROUP] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PHR-STATE-LICENSE-NUMBER] [varchar] (9) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PHR-MEDICAID-PROVIDER-ID] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PHR-NPI-ID] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PHR-CLIENT] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HashDiff] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordEndDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[S_PharmacyHeader] ADD CONSTRAINT [PK_S_PharmacyHeader] PRIMARY KEY CLUSTERED  ([S_PharmacyHeader_RK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[S_PharmacyHeader] ADD CONSTRAINT [FK_S_PharmacyHeader_H_Pharmacy] FOREIGN KEY ([H_Pharmacy_RK]) REFERENCES [dbo].[H_Pharmacy] ([H_Pharmacy_RK])
GO
