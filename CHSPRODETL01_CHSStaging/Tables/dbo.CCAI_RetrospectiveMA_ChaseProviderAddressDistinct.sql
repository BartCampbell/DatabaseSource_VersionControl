CREATE TABLE [dbo].[CCAI_RetrospectiveMA_ChaseProviderAddressDistinct]
(
[ServicingProviderNPI] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MemberID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderAddress] [char] (55) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderAddress2] [char] (55) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderCity] [char] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderState] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderZip] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Office_KEY] [int] NOT NULL IDENTITY(1, 1),
[ProviderOffice_PK] [bigint] NULL,
[Chosen] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
