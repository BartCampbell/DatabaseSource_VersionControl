CREATE TABLE [dbo].[HEDISDefinitionProfileMonthlyCountResultsHistory]
(
[ID] [int] NULL,
[ReportName] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClientName] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProfileID] [int] NULL,
[ProfileName] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DBName] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SchemaName] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Order_no] [int] NULL,
[SQLCommand] [varchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SourceDataFile] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ReturnValue] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bDetailReport] [bit] NULL,
[Date] [datetime] NULL,
[LoadDateTime] [datetime] NULL
) ON [PRIMARY]
GO
