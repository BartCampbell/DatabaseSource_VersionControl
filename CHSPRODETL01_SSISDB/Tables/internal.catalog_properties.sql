CREATE TABLE [internal].[catalog_properties]
(
[property_name] [nvarchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[property_value] [nvarchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [internal].[catalog_properties] ADD CONSTRAINT [PK_ISServer_Property] PRIMARY KEY CLUSTERED  ([property_name]) ON [PRIMARY]
GO
