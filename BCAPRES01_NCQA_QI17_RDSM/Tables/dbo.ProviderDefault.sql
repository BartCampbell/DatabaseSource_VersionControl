CREATE TABLE [dbo].[ProviderDefault]
(
[provid] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[pcp] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ProviderDefault_pcp] DEFAULT ('N'),
[obgyn] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ProviderDefault_obgyn] DEFAULT ('N'),
[mhprov] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ProviderDefault_mhprov] DEFAULT ('N'),
[eyecprov] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ProviderDefault_eyecprov] DEFAULT ('N'),
[dentist] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ProviderDefault_dentist] DEFAULT ('N'),
[neph] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ProviderDefault_neph] DEFAULT ('N'),
[anes] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ProviderDefault_anes] DEFAULT ('N'),
[npr] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ProviderDefault_npr] DEFAULT ('N'),
[pas] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ProviderDefault_pas] DEFAULT ('N'),
[provpres] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ProviderDefault_provpres] DEFAULT ('N'),
[phaprov] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ProviderDefault_phaprov] DEFAULT ('N'),
[hosp] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ProviderDefault_hosp] DEFAULT ('N'),
[snf] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ProviderDefault_snf] DEFAULT ('N'),
[surg] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ProviderDefault_surg] DEFAULT ('N'),
[rn] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ProviderDefault_rn] DEFAULT ('N')
) ON [PRIMARY]
GO
