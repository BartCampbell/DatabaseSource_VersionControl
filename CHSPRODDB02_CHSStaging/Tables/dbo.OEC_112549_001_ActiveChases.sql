CREATE TABLE [dbo].[OEC_112549_001_ActiveChases]
(
[Suspect_PK] [bigint] NOT NULL,
[ChaseID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsCoded] [bit] NULL,
[IsCNA] [bit] NULL,
[IsScanned] [bit] NULL,
[IsQA] [bit] NULL,
[ProviderOffice_PK] [bigint] NOT NULL,
[Address] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ZipCode_PK] [int] NULL,
[ProviderMaster_PK] [bigint] NOT NULL,
[Provider_ID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NPI] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
