CREATE TABLE [import].[Labs]
(
[memid] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cptcode] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[loinc] [varchar] (7) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[value] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[date_s] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[suppdata] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[measureset] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[measure] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ihds_member_id] [int] NULL,
[id] [bigint] NOT NULL IDENTITY(1, 1)
) ON [PRIMARY]
GO
ALTER TABLE [import].[Labs] ADD CONSTRAINT [PK_Labs] PRIMARY KEY CLUSTERED  ([id]) ON [PRIMARY]
GO
