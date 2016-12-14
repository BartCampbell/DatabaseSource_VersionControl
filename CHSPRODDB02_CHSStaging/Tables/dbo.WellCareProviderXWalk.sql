CREATE TABLE [dbo].[WellCareProviderXWalk]
(
[WellCareProviderID] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CentauriProviderID] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Lastname] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Firstname] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NPI] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TIN] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Address] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Zip] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ContactNumber] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FaxNumber] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
