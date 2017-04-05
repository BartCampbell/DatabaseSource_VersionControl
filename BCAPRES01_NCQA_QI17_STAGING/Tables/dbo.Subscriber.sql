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
ALTER TABLE [dbo].[Subscriber] ADD CONSTRAINT [actSubscriber_PK] PRIMARY KEY CLUSTERED  ([SubscriberID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [fk_employeeid] ON [dbo].[Subscriber] ([EmployeeID]) ON [PRIMARY]
GO
CREATE STATISTICS [sp_fk_employeeid] ON [dbo].[Subscriber] ([EmployeeID])
GO
CREATE STATISTICS [sp_actSubscriber_PK] ON [dbo].[Subscriber] ([SubscriberID])
GO
ALTER TABLE [dbo].[Subscriber] ADD CONSTRAINT [actEmployee_Subscriber_FK1] FOREIGN KEY ([EmployeeID]) REFERENCES [dbo].[Employee] ([EmployeeID])
GO
