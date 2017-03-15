CREATE TABLE [dbo].[ExportedData]
(
[LocationID] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Address] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[City] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[County] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[State] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Zipcode] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ContactPerson] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ContactNumber] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FaxNumber] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OfficeIssueStatusText] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ChaseID] [float] NULL,
[Provider_ID] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Provider] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Member_ID] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Member] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Issue Note] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Issue Additional Info] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IssueDate] [float] NULL,
[IssueResponse] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ReponseDate] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
