CREATE TABLE [dbo].[WellCareOfficeIssuesLog]
(
[LocationID] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Address] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[City] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[State] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[County] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ZipCode] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ContactPerson] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ContactNumber] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FaxNumber] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OfficeIssuesStatusText] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ChaseID] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsScanned] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsCNA] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Provider_ID] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Provider] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderGroup] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Member_ID] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Member] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IssueNote] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IssueAdditionalInfo] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IssueDate] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IssueResponse] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ResponseDate] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TO WC] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
