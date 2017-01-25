CREATE TABLE [Member].[EnrollmentBenefits]
(
[BenefitID] [int] NOT NULL,
[DataSetID] [int] NOT NULL,
[EnrollItemID] [bigint] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [Member].[EnrollmentBenefits] ADD CONSTRAINT [PK_EnrollmentBenefits] PRIMARY KEY CLUSTERED  ([EnrollItemID], [BenefitID]) ON [PRIMARY]
GO
