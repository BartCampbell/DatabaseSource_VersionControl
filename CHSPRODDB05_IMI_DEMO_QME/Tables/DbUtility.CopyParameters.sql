CREATE TABLE [DbUtility].[CopyParameters]
(
[DmCopyConfigID] [int] NOT NULL,
[DmCopyParamID] [int] NOT NULL IDENTITY(1, 1),
[IsOptional] [bit] NOT NULL CONSTRAINT [DF_CopyParameters_IsOptional] DEFAULT ((1)),
[ParamDataType] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ParamName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [DbUtility].[CopyParameters] ADD CONSTRAINT [PK_CopyParameters] PRIMARY KEY CLUSTERED  ([DmCopyParamID]) ON [PRIMARY]
GO
