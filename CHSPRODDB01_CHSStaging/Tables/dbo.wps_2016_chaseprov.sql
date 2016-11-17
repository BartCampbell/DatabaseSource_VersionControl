CREATE TABLE [dbo].[wps_2016_chaseprov]
(
[MemberID] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Provider Last] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Provider First] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Provider ID] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Provider NPI] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Payee ID] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Payee Name] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Provider Days of Service] [float] NULL,
[Last seen] [datetime] NULL,
[Number Suggestive Fills] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Last Suggestive Fill] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Cluster] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Reason] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Weight] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OverallMemberOpportunity] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
