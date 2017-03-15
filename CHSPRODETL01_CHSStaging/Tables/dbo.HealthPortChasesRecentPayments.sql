CREATE TABLE [dbo].[HealthPortChasesRecentPayments]
(
[Invoice] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PatientName] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DOB] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProvID] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SiteName] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Address] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[City] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ST] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Zip] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[InvoiceAmount] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FirstName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MemberID] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RevisedDOB] [int] NULL,
[RevDOBDate] [datetime] NULL
) ON [PRIMARY]
GO
