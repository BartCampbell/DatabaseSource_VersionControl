CREATE TABLE [import].[StagingEnrollment]
(
[memid] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[startdate] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[finishdate] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dental] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[drug] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mhinpt] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mhdn] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mhamb] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cdinpt] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cddn] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cdamb] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[hospice] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[payer] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[peflag] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ind] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
