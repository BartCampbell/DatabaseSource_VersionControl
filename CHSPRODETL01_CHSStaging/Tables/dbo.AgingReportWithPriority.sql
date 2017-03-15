CREATE TABLE [dbo].[AgingReportWithPriority]
(
[Chase ID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Member ID] [varchar] (22) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Member DOB] [date] NULL,
[Member Name] [varchar] (202) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderName] [varchar] (152) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Provider Tax ID] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[N P I] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Provider Phone] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Provider Fax] [varchar] (120) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Provider Address] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Provider City] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Provider State] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Zip Code] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Provider County] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Date of Service] [date] NULL,
[Chase Priority] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Contact Name] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Office Status] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Scheduled] [varchar] (7) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Extracted] [smalldatetime] NULL,
[C N A] [smalldatetime] NULL,
[Coded] [smalldatetime] NULL,
[Scheduled Date] [date] NULL
) ON [PRIMARY]
GO
