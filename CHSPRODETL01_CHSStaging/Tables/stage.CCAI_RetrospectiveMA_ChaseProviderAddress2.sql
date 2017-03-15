CREATE TABLE [stage].[CCAI_RetrospectiveMA_ChaseProviderAddress2]
(
[ServicingProviderNPI] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderAddress] [char] (55) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderAddress2] [char] (55) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderCity] [char] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderState] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderZip] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Office_KEY] [int] NOT NULL,
[ProviderOffice_PK] [bigint] NULL,
[Uni] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Provider_PK] [bigint] NULL,
[ProviderMaster_PK] [bigint] NULL,
[Q_Office_PK] [bigint] NULL,
[QRAD] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NewAddress] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NewZIP] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
