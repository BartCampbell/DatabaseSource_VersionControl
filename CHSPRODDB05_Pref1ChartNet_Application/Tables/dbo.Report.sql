CREATE TABLE [dbo].[Report]
(
[ReportID] [int] NOT NULL IDENTITY(1, 1),
[ReportName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Description] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Class] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[AssemblyName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Report] ADD CONSTRAINT [PK_Report] PRIMARY KEY CLUSTERED  ([ReportID]) ON [PRIMARY]
GO
