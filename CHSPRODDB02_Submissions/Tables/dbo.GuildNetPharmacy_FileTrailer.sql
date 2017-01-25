CREATE TABLE [dbo].[GuildNetPharmacy_FileTrailer]
(
[FTR-RECORD-TYPE ] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FTR-BATCH-NUMBER] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FTR-END-OF-CYCLE-DATE] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FTR-SEQUENCE-NUMBER] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FTR-NUMBER-OF-PHARMACIES] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FTR-NUMBER-OF-RECORDS] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FTR-TOTAL-AMOUNT] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FTR-TOTAL-REJECTS] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FTR-TOTAL-ADMIN] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FILLER   ] [varchar] (1435) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FileName] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL,
[GKEY] [int] NOT NULL IDENTITY(1, 1)
) ON [PRIMARY]
GO
