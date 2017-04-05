CREATE TABLE [Measure].[EnrollmentBenefits]
(
[BenefitID] [smallint] NOT NULL,
[MeasEnrollID] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [Measure].[EnrollmentBenefits] ADD CONSTRAINT [PK_MeasureEnrollmentBenefits] PRIMARY KEY CLUSTERED  ([BenefitID], [MeasEnrollID]) ON [PRIMARY]
GO
