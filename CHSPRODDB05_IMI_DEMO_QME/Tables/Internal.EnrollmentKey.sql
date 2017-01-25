CREATE TABLE [Internal].[EnrollmentKey]
(
[BatchID] [int] NOT NULL,
[DataRunID] [int] NOT NULL,
[DataSetID] [int] NOT NULL,
[EnrollGroupID] [int] NOT NULL,
[PayerID] [smallint] NOT NULL,
[PopulationID] [int] NULL,
[ProductClassID] [tinyint] NOT NULL,
[ProductTypeID] [smallint] NOT NULL,
[SpId] [int] NOT NULL CONSTRAINT [DF_EnrollmentKey_SpId] DEFAULT (@@spid)
) ON [PRIMARY]
GO
ALTER TABLE [Internal].[EnrollmentKey] ADD CONSTRAINT [PK_Internal_EnrollmentKey] PRIMARY KEY CLUSTERED  ([SpId], [EnrollGroupID], [ProductClassID]) ON [PRIMARY]
GO
