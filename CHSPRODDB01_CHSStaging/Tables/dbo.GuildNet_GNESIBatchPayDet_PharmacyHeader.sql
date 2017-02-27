CREATE TABLE [dbo].[GuildNet_GNESIBatchPayDet_PharmacyHeader]
(
[PHR-RECORD-TYPE] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
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
[FILLER] [varchar] (1397) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FileName] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL,
[GKEY] [int] NOT NULL,
[CentauriPharmacyID] [int] NULL
) ON [PRIMARY]
GO
