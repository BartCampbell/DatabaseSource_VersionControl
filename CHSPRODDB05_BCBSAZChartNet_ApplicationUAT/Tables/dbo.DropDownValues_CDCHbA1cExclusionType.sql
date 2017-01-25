CREATE TABLE [dbo].[DropDownValues_CDCHbA1cExclusionType]
(
[ExclusionTypeID] [int] NOT NULL,
[SortKey] [int] NOT NULL CONSTRAINT [DF_DropDownValues_CDCHbA1cExclusionType_SortKey] DEFAULT ((0)),
[Description] [nvarchar] (300) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DropDownValues_CDCHbA1cExclusionType] ADD CONSTRAINT [PK_DropDownValues_CDCHbA1cExclusionType] PRIMARY KEY CLUSTERED  ([ExclusionTypeID]) ON [PRIMARY]
GO
