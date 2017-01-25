CREATE TABLE [dbo].[GuildNetPharmacy_PharmacyTrailer]
(
[PTR-RECORD-TYPE] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PHR-BATCH-NUMBER] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PTR-END-OF-CYCLE-DATE] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PTR-PHARMACY-NABP-NO] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PTR-VENDOR] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PTR-TOTAL-AMOUNT] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PTR-NUMBER-OF-CLAIMS] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PTR-TOTAL-REJECTS] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PTR-NPI-ID ] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PTR-TOTAL-ADMIN] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FILLER   ] [varchar] (1420) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FileName] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL,
[GKEY] [int] NOT NULL IDENTITY(1, 1)
) ON [PRIMARY]
GO
