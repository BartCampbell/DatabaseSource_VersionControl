CREATE TABLE [dbo].[OEC_112549_001_ClaimProvRendering_20161020]
(
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
[Priority_Bucket_by_Enrollee] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Priority_Bucket_by_Provider] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NPI_ProviderLastName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NPI_ProviderFirstName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NPI_ProviderAddress] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NPI_ProviderZip] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NPI_ProviderPhone] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NPI_ProviderFax] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IncludeYN] [bit] NULL,
[ExtractedDoNotUpdate] [bit] NULL,
[AddressMatch] [bit] NULL,
[IgnoreForNow] [bit] NULL,
[NewChaseID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RowNum] [int] NULL,
[CentauriChaseID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OECRenderingID] [int] NOT NULL IDENTITY(1, 1),
[Employee_YN] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[OEC_112549_001_ClaimProvRendering_20161020] ADD CONSTRAINT [PK_OEC_112549_001_ClaimProvRendering_20161020] PRIMARY KEY CLUSTERED  ([OECRenderingID]) ON [PRIMARY]
GO
