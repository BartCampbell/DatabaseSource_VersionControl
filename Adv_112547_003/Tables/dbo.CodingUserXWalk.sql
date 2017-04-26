CREATE TABLE [dbo].[CodingUserXWalk]
(
[User_PK02] [int] NOT NULL,
[Username02] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Lastname02] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Firstname02] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Email_Address02] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Location_PK02] [int] NULL,
[Location02] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[User_PK01] [int] NULL,
[Username01] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Lastname01] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Firstname01] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EmailAddress01] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Location_PK01] [int] NULL,
[Location01] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NewUser_PK02] [int] NULL
) ON [PRIMARY]
GO
