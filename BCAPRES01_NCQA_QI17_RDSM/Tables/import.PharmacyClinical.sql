CREATE TABLE [import].[PharmacyClinical]
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
[immyr] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[measureset] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[measure] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ihds_member_id] [int] NULL,
[id] [bigint] NOT NULL IDENTITY(1, 1)
) ON [PRIMARY]
GO
ALTER TABLE [import].[PharmacyClinical] ADD CONSTRAINT [PK_PharmacyClinical] PRIMARY KEY CLUSTERED  ([id]) ON [PRIMARY]
GO
