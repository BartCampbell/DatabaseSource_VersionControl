CREATE TABLE [Member].[Enrollment]
(
[BeginDate] [datetime] NULL,
[BitBenefits] [bigint] NOT NULL CONSTRAINT [DF_Enrollment_BitBenefits] DEFAULT ((0)),
[BitProductLines] [bigint] NOT NULL CONSTRAINT [DF_Enrollment_BitProductLines] DEFAULT ((0)),
[DataSetID] [int] NOT NULL,
[DataSourceID] [int] NOT NULL CONSTRAINT [DF__Enrollmen__DataS__1519BF6A] DEFAULT ((-1)),
[DSMemberID] [bigint] NOT NULL,
[EligibilityID] [int] NULL,
[EndDate] [datetime] NULL,
[EnrollGroupID] [int] NOT NULL,
[EnrollItemID] [bigint] NOT NULL IDENTITY(1, 1),
[IsEmployee] [bit] NOT NULL CONSTRAINT [DF_Enrollment_IsEmployee] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [Member].[Enrollment] ADD CONSTRAINT [PK_Enrollment] PRIMARY KEY CLUSTERED  ([EnrollItemID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Enrollment_DSMemberID] ON [Member].[Enrollment] ([DSMemberID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Enrollment] ON [Member].[Enrollment] ([DSMemberID], [BeginDate], [EndDate], [EnrollGroupID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Enrollment_EligibilityID] ON [Member].[Enrollment] ([EligibilityID], [DSMemberID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Enrollment_EnrollGroupID] ON [Member].[Enrollment] ([EnrollGroupID]) ON [PRIMARY]
GO
