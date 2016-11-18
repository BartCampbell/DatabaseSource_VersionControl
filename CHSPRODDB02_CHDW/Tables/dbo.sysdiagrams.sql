CREATE TABLE [dbo].[sysdiagrams]
(
[name] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[principal_id] [int] NOT NULL,
[diagram_id] [int] NOT NULL,
[version] [int] NULL,
[definition] [varbinary] (max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
