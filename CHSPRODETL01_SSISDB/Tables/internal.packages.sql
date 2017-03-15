CREATE TABLE [internal].[packages]
(
[package_id] [bigint] NOT NULL IDENTITY(1, 1),
[project_version_lsn] [bigint] NOT NULL,
[name] [nvarchar] (260) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[package_guid] [uniqueidentifier] NOT NULL,
[description] [nvarchar] (1024) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[package_format_version] [int] NOT NULL,
[version_major] [int] NOT NULL,
[version_minor] [int] NOT NULL,
[version_build] [int] NOT NULL,
[version_comments] [nvarchar] (1024) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[version_guid] [uniqueidentifier] NOT NULL,
[project_id] [bigint] NOT NULL,
[entry_point] [bit] NOT NULL,
[validation_status] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[last_validation_time] [datetimeoffset] NULL,
[package_data] [varbinary] (max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [internal].[packages] ADD CONSTRAINT [PK_Packages] PRIMARY KEY CLUSTERED  ([package_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Packages_Name] ON [internal].[packages] ([name]) INCLUDE ([package_id], [project_id], [project_version_lsn]) ON [PRIMARY]
GO
ALTER TABLE [internal].[packages] ADD CONSTRAINT [FK_Packages_ProjectId_Projects] FOREIGN KEY ([project_id]) REFERENCES [internal].[projects] ([project_id]) ON DELETE CASCADE
GO
ALTER TABLE [internal].[packages] ADD CONSTRAINT [FK_Packages_ProjectVersionLsn_ObjectVersions] FOREIGN KEY ([project_version_lsn]) REFERENCES [internal].[object_versions] ([object_version_lsn]) ON DELETE CASCADE
GO
