CREATE TABLE [dbo].[tblUserSessionLog]
(
[Session_PK] [bigint] NOT NULL,
[AccessedPage] [varchar] (50) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[AccessedDate] [datetime] NULL
) ON [PRIMARY]
GO
