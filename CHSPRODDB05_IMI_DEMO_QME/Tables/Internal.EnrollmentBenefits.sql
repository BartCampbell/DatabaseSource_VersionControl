CREATE TABLE [Internal].[EnrollmentBenefits]
(
[BatchID] [int] NOT NULL,
[BenefitID] [int] NOT NULL,
[DataRunID] [int] NOT NULL,
[DataSetID] [int] NOT NULL,
[EnrollItemID] [bigint] NOT NULL,
[SpId] [int] NOT NULL CONSTRAINT [DF_EnrollmentBenefits_SpId] DEFAULT (@@spid)
) ON [PRIMARY]
GO
ALTER TABLE [Internal].[EnrollmentBenefits] ADD CONSTRAINT [PK_Internal_EnrollmentBenefits] PRIMARY KEY CLUSTERED  ([SpId], [EnrollItemID], [BenefitID]) ON [PRIMARY]
GO
