CREATE TABLE [dbo].[TableNames]
(
[TableName_PK] [int] NOT NULL IDENTITY(1, 1),
[TableName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CreateDate] [datetime] NULL
) ON [PRIMARY]
GO
