CREATE TABLE [dbo].[Member_Stage]
(
[CMI] [int] NOT NULL,
[ClientMemberID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MemberHashKey] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SSN] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CCI] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsActive] [bit] NULL
) ON [PRIMARY]
GO
