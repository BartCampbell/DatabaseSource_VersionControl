CREATE TABLE [dbo].[GuildNetPharmacy_FileHeader]
(
[hdr ] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FHR-BATCH-NUMBER ] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FHR-END-OF-CYCLE-DATE] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FHR-SEQUENCE-NUMBER] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FILLER ] [varchar] (1485) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FileName] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL,
[GKEY] [int] NOT NULL IDENTITY(1, 1)
) ON [PRIMARY]
GO
