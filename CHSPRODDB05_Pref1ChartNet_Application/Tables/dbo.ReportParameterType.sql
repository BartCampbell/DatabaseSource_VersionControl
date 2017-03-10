CREATE TABLE [dbo].[ReportParameterType]
(
[ParameterTypeID] [int] NOT NULL,
[DataType] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Description] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ReportParameterType] ADD CONSTRAINT [PK_ReportParameterType] PRIMARY KEY CLUSTERED  ([ParameterTypeID]) ON [PRIMARY]
GO
