CREATE TABLE [Member].[EnrollmentPopulationProductLines]
(
[PopulationID] [int] NOT NULL,
[ProductLineID] [tinyint] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [Member].[EnrollmentPopulationProductLines] ADD CONSTRAINT [PK_EnrollmentPopulationProductLines] PRIMARY KEY CLUSTERED  ([PopulationID], [ProductLineID]) ON [PRIMARY]
GO
