CREATE TABLE [Result].[DataSetProviderKey]
(
[BitSpecialties] [bigint] NOT NULL CONSTRAINT [DF_DataSetProviderKey_BitSpecialties] DEFAULT ((0)),
[CustomerProviderID] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DisplayID] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DataRunID] [int] NOT NULL,
[DataSetID] [int] NOT NULL,
[DSProviderID] [bigint] NOT NULL,
[IhdsProviderID] [int] NOT NULL,
[ProviderName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [Result].[DataSetProviderKey] ADD CONSTRAINT [PK_DataSetProviderKey] PRIMARY KEY CLUSTERED  ([DSProviderID], [DataRunID]) ON [PRIMARY]
GO
