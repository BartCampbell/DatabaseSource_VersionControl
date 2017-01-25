CREATE TABLE [Member].[EnrollmentPopulationMeasures]
(
[MeasureID] [int] NOT NULL,
[PopulationID] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [Member].[EnrollmentPopulationMeasures] ADD CONSTRAINT [PK_EnrollmentPopulationMeasures] PRIMARY KEY CLUSTERED  ([MeasureID], [PopulationID]) ON [PRIMARY]
GO
