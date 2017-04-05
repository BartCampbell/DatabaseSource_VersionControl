CREATE TABLE [import].[Enrollment]
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
[ind] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[measureset] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[measure] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ihds_member_id] [int] NULL,
[id] [bigint] NOT NULL IDENTITY(1, 1)
) ON [PRIMARY]
GO
ALTER TABLE [import].[Enrollment] ADD CONSTRAINT [PK_Enrollment] PRIMARY KEY CLUSTERED  ([id]) ON [PRIMARY]
GO
