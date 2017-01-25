CREATE TABLE [dbo].[ReasonCodeList]
(
[RowID] [int] NOT NULL IDENTITY(1, 1),
[ReasonCode] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ReasonCodeType] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Description] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Description2] [varchar] (204) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DataSource] [varchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SrcRowID] [int] NULL,
[Client] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadInstanceID] [int] NOT NULL,
[SourceSystem] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
