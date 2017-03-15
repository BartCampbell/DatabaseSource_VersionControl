CREATE TABLE [dbo].[WellCare_MultipleChannelOffice]
(
[RowNumber] [float] NULL,
[LocationID] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Address] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[City] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[County] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[State] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Zipcode] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ContactNumber] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FaxNumber] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ContactPerson] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Providers] [float] NULL,
[Charts] [float] NULL,
[Project] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
