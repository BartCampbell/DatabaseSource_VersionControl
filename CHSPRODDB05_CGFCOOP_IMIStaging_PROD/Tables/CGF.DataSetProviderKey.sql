CREATE TABLE [CGF].[DataSetProviderKey]
(
[CustomerProviderID] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DisplayID] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DataRunID] [int] NOT NULL,
[DataSetID] [int] NOT NULL,
[DSProviderID] [bigint] NOT NULL,
[IhdsProviderID] [int] NOT NULL,
[ProviderName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
