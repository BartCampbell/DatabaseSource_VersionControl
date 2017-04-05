CREATE TABLE [dbo].[Employee]
(
[EmployeeID] [int] NOT NULL IDENTITY(1, 1),
[Address1] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Address2] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[City] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Client] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Company] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustomerEmployeeID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DataSource] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DateOfBirth] [datetime] NULL,
[DateHired] [smalldatetime] NULL,
[DateTerminated] [smalldatetime] NULL,
[Department] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EmployeeType] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EthnicGroup] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Gender] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[InstanceID] [uniqueidentifier] NULL,
[IsSmoker] [bit] NULL,
[JobTitle] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Location] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MaritalStatus] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NameFirst] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NameLast] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NameMiddleInitial] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Phone] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SSN] [char] (9) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[State] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ZipCode] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HedisMeasureID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ihds_member_id] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Employee] ADD CONSTRAINT [actEmployee_PK] PRIMARY KEY CLUSTERED  ([EmployeeID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [fk_employee] ON [dbo].[Employee] ([CustomerEmployeeID], [HedisMeasureID]) ON [PRIMARY]
GO
CREATE STATISTICS [sp_fk_employee] ON [dbo].[Employee] ([CustomerEmployeeID], [HedisMeasureID])
GO
CREATE STATISTICS [sp_actEmployee_PK] ON [dbo].[Employee] ([EmployeeID])
GO
