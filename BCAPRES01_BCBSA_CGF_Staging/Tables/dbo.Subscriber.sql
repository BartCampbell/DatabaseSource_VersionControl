CREATE TABLE [dbo].[Subscriber]
(
[SubscriberID] [int] NOT NULL IDENTITY(1, 1),
[Address1] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Address2] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[City] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Client] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CoverageType] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustomerSubscriberID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DataSource] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DateEffective] [smalldatetime] NULL,
[DateTerminated] [smalldatetime] NULL,
[EmployeeID] [int] NULL,
[SubscriberGroup] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[State] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SubscriberSubGroup] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ZipCode] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HedisMeasureID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ihds_member_id] [int] NULL
) ON [PRIMARY]
GO
