CREATE TYPE [internal].[decrypted_data_table] AS TABLE
(
[id] [bigint] NOT NULL,
[value] [varbinary] (max) NULL
)
GO
