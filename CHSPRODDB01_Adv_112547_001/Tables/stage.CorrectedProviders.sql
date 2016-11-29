CREATE TABLE [stage].[CorrectedProviders]
(
[Chart ID] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CentauriProviderID] [bigint] NULL,
[PROV FIRST] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PROV LAST] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NewAddress] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NewZip] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CorrectCentauriProviderID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SourceChaseID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OldProvider_PK] [int] NULL,
[NewProvider_PK] [int] NULL
) ON [PRIMARY]
GO
