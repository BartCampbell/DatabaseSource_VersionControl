CREATE TABLE [dbo].[WC_ChartExtract]
(
[RecID] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProjectName] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LocationGroupID] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ChartID] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Resolution] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ResolutionDate] [datetime] NULL,
[DocumentStatus] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Measure] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DocumentPageCount] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClientMemberID] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MemberLastName] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MemberFirstName] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MemberDOB] [datetime] NULL
) ON [PRIMARY]
GO
