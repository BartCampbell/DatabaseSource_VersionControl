CREATE TABLE [dbo].[BrXref_AuthDetail]
(
[BusRuleDtlID] [int] NOT NULL IDENTITY(1, 1),
[AuthDtlID] [bigint] NULL,
[DHMPLineOfBusiness] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
