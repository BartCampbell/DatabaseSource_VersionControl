CREATE TYPE [internal].[PackageTableType] AS TABLE
(
[name] [nvarchar] (260) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[package_guid] [uniqueidentifier] NOT NULL,
[description] [nvarchar] (1024) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[package_format_version] [int] NOT NULL,
[version_major] [int] NOT NULL,
[version_minor] [int] NOT NULL,
[version_build] [int] NOT NULL,
[version_comments] [nvarchar] (1024) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[version_guid] [uniqueidentifier] NOT NULL,
[entry_point] [bit] NOT NULL,
[validation_status] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[last_validation_time] [datetimeoffset] NULL,
[package_data] [varbinary] (max) NULL
)
GO
GRANT EXECUTE ON TYPE:: [internal].[PackageTableType] TO [public]
GO
