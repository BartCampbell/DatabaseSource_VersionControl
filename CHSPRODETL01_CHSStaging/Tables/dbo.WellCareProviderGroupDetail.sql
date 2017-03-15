CREATE TABLE [dbo].[WellCareProviderGroupDetail]
(
[Project] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LocationGroupId] [float] NULL,
[ChartID] [float] NULL,
[Resolution] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DocumentStatus] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DocumentPageCount] [float] NULL,
[GroupName] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AddressLine1] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AddressLine2] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[City] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[State] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Zipcode] [float] NULL,
[Phone] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Fax] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClientPrvID] [float] NULL,
[ProviderLastName] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderFirstName] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderType] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[POS] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PendStatus] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Method] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
