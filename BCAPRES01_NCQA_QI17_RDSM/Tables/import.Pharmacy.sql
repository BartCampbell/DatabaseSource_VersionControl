CREATE TABLE [import].[Pharmacy]
(
[memid] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pdayssup] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[prservdate] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ndc] [varchar] (11) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[clmstat] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mquant] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dquant] [varchar] (7) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[suppdata] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[measureset] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[measure] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ihds_member_id] [int] NULL,
[id] [bigint] NOT NULL IDENTITY(1, 1)
) ON [PRIMARY]
GO
ALTER TABLE [import].[Pharmacy] ADD CONSTRAINT [PK_Pharmacy] PRIMARY KEY CLUSTERED  ([id]) ON [PRIMARY]
GO
