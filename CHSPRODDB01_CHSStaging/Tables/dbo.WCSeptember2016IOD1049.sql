CREATE TABLE [dbo].[WCSeptember2016IOD1049]
(
[RowNum] [float] NULL,
[Invoice #] [float] NULL,
[Order  #] [float] NULL,
[Chart ID] [char] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Patient - Last] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Patient - First] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Balance] [money] NULL,
[Inv Date Sent] [datetime] NULL,
[Prov #] [float] NULL,
[Chart] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Site Name] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Site City] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Site State] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Order Page Count] [float] NULL,
[Days Old] [float] NULL,
[ValidChase] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Extracted] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Duplicate] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
