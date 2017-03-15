CREATE TABLE [stage].[CCAI_RetrospectiveMA_ChaseProviderAddressDistinct2]
(
[ServicingProviderNPI] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MemberID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderAddress] [char] (55) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderAddress2] [char] (55) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderCity] [char] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderState] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderZip] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Office_KEY] [int] NOT NULL,
[ProviderOffice_PK] [bigint] NULL,
[Chosen] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DIST] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RowUse] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[QRAD] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Q_Office_PK] [bigint] NULL,
[Provider_PK] [bigint] NULL,
[ProviderMaster_PK] [bigint] NULL
) ON [PRIMARY]
GO
