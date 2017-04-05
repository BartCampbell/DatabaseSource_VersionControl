CREATE TABLE [import].[StagingPharmacyClinical]
(
[ptid] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[odate] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[startdate] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rxnorm] [varchar] (11) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[oflag] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mtext] [varchar] (160) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[freq] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ddate] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[edate] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[active] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[immyr] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
