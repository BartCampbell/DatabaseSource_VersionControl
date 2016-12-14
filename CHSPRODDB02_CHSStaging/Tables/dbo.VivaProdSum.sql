CREATE TABLE [dbo].[VivaProdSum]
(
[RecID] [int] NULL,
[Member_ID] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Member] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Provider_ID] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Provider] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Address] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ZipCode] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[City] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[State] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OfficeStatus] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Scheduled] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Extracted] [datetime] NULL,
[CNA] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CNANote] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Coded] [datetime] NULL,
[ChartPriority] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
