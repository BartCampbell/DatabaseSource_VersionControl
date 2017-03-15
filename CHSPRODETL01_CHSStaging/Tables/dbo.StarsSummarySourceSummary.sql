CREATE TABLE [dbo].[StarsSummarySourceSummary]
(
[Measure ID] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Measure Name] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Data Source Per Technical Specifications] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Stars Measurement Period] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Data Received Through] [datetime] NULL,
[Comments] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Star Measure Category] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Star Measure Sub-Category] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Source Data] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Source Location] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Source File] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Star Ratings Year] [float] NULL,
[Load Date] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
