CREATE TABLE [import].[ProvidersHAI]
(
[provid] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pcp] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[obgyn] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mhprov] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[eyecprov] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dentist] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[neph] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[anes] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[npr] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pas] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[provpres] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[phaprov] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[hosp] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[snf] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[surg] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rn] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[contract] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[hospid] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[measureset] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[measure] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ihds_provider_id] [int] NULL,
[id] [bigint] NOT NULL IDENTITY(1, 1)
) ON [PRIMARY]
GO
ALTER TABLE [import].[ProvidersHAI] ADD CONSTRAINT [PK_ProvidersHAI] PRIMARY KEY CLUSTERED  ([id]) ON [PRIMARY]
GO
