CREATE TABLE [dbo].[HPSept 20161099]
(
[RowNum] [float] NULL,
[Customer] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Customer Name] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Invoice] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Invoice Date] [datetime] NULL,
[Patient Name] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Chase ID] [char] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Patient DOB] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Site #] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Site Name] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PAGES] [float] NULL,
[Open Balance] [money] NULL,
[ValidChase] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Extracted] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Duplicate] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
