CREATE TABLE [stage].[DuplicateProviders3]
(
[Chart ID] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OldProvider_ID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OldLastName] [varchar] (75) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OldAddress] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NewProviderID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NewLastName] [varchar] (75) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NewAddress] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OldProvider_PK] [bigint] NOT NULL,
[NewProvider_PK] [bigint] NULL
) ON [PRIMARY]
GO
