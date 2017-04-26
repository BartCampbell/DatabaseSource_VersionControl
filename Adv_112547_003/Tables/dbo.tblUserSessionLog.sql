CREATE TABLE [dbo].[tblUserSessionLog]
(
[Session_PK] [bigint] NOT NULL,
[AccessedPage] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AccessedDate] [datetime] NULL
) ON [PRIMARY]
GO
