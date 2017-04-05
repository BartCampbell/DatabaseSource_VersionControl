CREATE TABLE [Ncqa].[IDSS_Columns]
(
[DataType] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_IDSS_Columns_DataType] DEFAULT ('int'),
[Descr] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FieldID] [int] NULL,
[IdssColumnGuid] [uniqueidentifier] NOT NULL CONSTRAINT [DF_IDSS_Columns_IdssColumnGuid] DEFAULT (newid()),
[IdssColumnID] [int] NOT NULL IDENTITY(1, 1),
[IsDistinct] [bit] NOT NULL,
[IsEnabled] [bit] NOT NULL CONSTRAINT [DF_IDSS_Columns_IsEnabled] DEFAULT ((1)),
[IsResultTypeDriven] [bit] NOT NULL CONSTRAINT [DF_IDSS_Columns_IsResultTypeDriven] DEFAULT ((0)),
[SourceColumn] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SourceSchema] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SourceTable] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [Ncqa].[IDSS_Columns] ADD CONSTRAINT [PK_IDSS_Columns] PRIMARY KEY CLUSTERED  ([IdssColumnID]) ON [PRIMARY]
GO
