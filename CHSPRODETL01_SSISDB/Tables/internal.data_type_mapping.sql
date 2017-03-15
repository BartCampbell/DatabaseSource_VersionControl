CREATE TABLE [internal].[data_type_mapping]
(
[mapping_id] [bigint] NOT NULL IDENTITY(1, 1),
[ssis_data_type] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[sql_data_type] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [internal].[data_type_mapping] ADD CONSTRAINT [PK_Data_Type_Mapping] PRIMARY KEY CLUSTERED  ([mapping_id]) ON [PRIMARY]
GO
ALTER TABLE [internal].[data_type_mapping] ADD CONSTRAINT [Unique_data_type_mapping] UNIQUE NONCLUSTERED  ([ssis_data_type], [sql_data_type]) ON [PRIMARY]
GO
