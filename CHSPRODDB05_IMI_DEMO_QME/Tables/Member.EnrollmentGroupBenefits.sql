CREATE TABLE [Member].[EnrollmentGroupBenefits]
(
[BenefitID] [int] NOT NULL,
[EnrollGroupID] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [Member].[EnrollmentGroupBenefits] ADD CONSTRAINT [PK_EnrollmentGroupBenefits] PRIMARY KEY CLUSTERED  ([EnrollGroupID], [BenefitID]) ON [PRIMARY]
GO
