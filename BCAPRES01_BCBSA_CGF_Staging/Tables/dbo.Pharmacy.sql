CREATE TABLE [dbo].[Pharmacy]
(
[PharmacyID] [int] NOT NULL IDENTITY(1, 1),
[Address1] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Address2] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[City] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Client] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DataSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DateRowCreated] [datetime] NULL,
[DateValidBegin] [datetime] NULL,
[DateValidEnd] [datetime] NULL,
[DEANumber] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Fax] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HashValue] [binary] (16) NULL,
[InstanceID] [int] NULL,
[IsUpdated] [bit] NULL,
[NABPNumber] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NPI] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PharmacyName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Phone] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RowID] [int] NULL,
[State] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ZipCode] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
