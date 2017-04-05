CREATE TABLE [CGF].[DataSets]
(
[CreatedDate] [datetime] NOT NULL,
[DataSetGuid] [uniqueidentifier] NOT NULL,
[DataSource] [nvarchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DataSourceGuid] [uniqueidentifier] NOT NULL
) ON [PRIMARY]
GO
