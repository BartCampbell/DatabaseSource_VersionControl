CREATE TABLE [dbo].[cwd_directory_operation]
(
[directory_id] [numeric] (18, 0) NOT NULL,
[operation_type] [nvarchar] (60) COLLATE SQL_Latin1_General_CP437_CI_AI NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[cwd_directory_operation] ADD CONSTRAINT [PK_cwd_directory_operation] PRIMARY KEY CLUSTERED  ([directory_id], [operation_type]) ON [PRIMARY]
GO
