CREATE TABLE [dbo].[QiNET_ETL_Profile]
(
[ProfileID] [int] NOT NULL IDENTITY(1, 1),
[ProfileType] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProfileTable] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProfileErrorCnt] [int] NULL,
[TableCnt] [int] NULL
) ON [PRIMARY]
GO
