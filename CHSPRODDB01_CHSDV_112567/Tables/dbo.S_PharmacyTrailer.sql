CREATE TABLE [dbo].[S_PharmacyTrailer]
(
[S_PharmacyTrailer_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LoadDate] [datetime] NOT NULL,
[H_Pharmacy_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PHR-BATCH-NUMBER] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PTR-END-OF-CYCLE-DATE] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PTR-PHARMACY-NABP-NO] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PTR-VENDOR] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PTR-TOTAL-AMOUNT] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PTR-NUMBER-OF-CLAIMS] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PTR-TOTAL-REJECTS] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PTR-NPI-ID] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PTR-TOTAL-ADMIN] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HashDiff] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordEndDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[S_PharmacyTrailer] ADD CONSTRAINT [PK_S_PharmacyTrailer] PRIMARY KEY CLUSTERED  ([S_PharmacyTrailer_RK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[S_PharmacyTrailer] ADD CONSTRAINT [FK_S_PharmacyTrailer_H_Pharmacy] FOREIGN KEY ([H_Pharmacy_RK]) REFERENCES [dbo].[H_Pharmacy] ([H_Pharmacy_RK])
GO
