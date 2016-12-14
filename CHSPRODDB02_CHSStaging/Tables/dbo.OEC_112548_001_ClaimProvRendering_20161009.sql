CREATE TABLE [dbo].[OEC_112548_001_ClaimProvRendering_20161009]
(
[OECRenderingID] [int] NOT NULL IDENTITY(1, 1),
[Client_ID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Chase_ID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Member_ID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Claim_ID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Service_Line] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Rendering_Provider_ID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Rendering_Provider_NPI] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Rendering_Provider_Last_Name] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Rendering_Provider_First_Name] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Rendering_Provider_Office_Address] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Rendering_Provider_Office_City] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Rendering_Provider_Office_State] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Rendering_Provider_Office_Zip] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Rendering_Provider_Office_Phone] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Rendering_Provider_Office_Fax] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CentauriChaseID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NPI_ProviderLastName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NPI_ProviderFirstName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NPI_ProviderAddress] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NPI_ProviderZip] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NPI_ProviderPhone] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NPI_ProviderFax] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IncludeYN] [bit] NULL,
[ExtractedDoNotUpdate] [bit] NULL,
[AddressMatch] [bit] NULL,
[IgnoreForNow] [bit] NULL,
[NewChaseID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RowNum] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[OEC_112548_001_ClaimProvRendering_20161009] ADD CONSTRAINT [PK_OEC_112548_001_ClaimProvRendering_20161009] PRIMARY KEY CLUSTERED  ([OECRenderingID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_OEC_112548_001_ClaimProvRenderin_20_2066314621__K8_K4_11] ON [dbo].[OEC_112548_001_ClaimProvRendering_20161009] ([Rendering_Provider_NPI], [Member_ID]) INCLUDE ([Rendering_Provider_Office_Address]) ON [PRIMARY]
GO
