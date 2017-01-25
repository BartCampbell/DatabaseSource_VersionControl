CREATE TABLE [Internal].[Enrollment]
(
[BatchID] [int] NOT NULL,
[BeginDate] [datetime] NULL,
[BitBenefits] [bigint] NOT NULL CONSTRAINT [DF_Enrollment_BitBenefits] DEFAULT ((0)),
[BitProductLines] [bigint] NOT NULL CONSTRAINT [DF_Enrollment_BitProductLines] DEFAULT ((0)),
[DataRunID] [int] NOT NULL,
[DataSetID] [int] NULL,
[DataSourceID] [int] NOT NULL,
[DSMemberID] [bigint] NOT NULL,
[EligibilityID] [int] NULL,
[EndDate] [datetime] NULL,
[EnrollGroupID] [int] NOT NULL,
[EnrollItemID] [bigint] NOT NULL,
[IsEmployee] [bit] NOT NULL CONSTRAINT [DF_Temp_Enrollment_IsEmployee] DEFAULT ((0)),
[SpId] [int] NOT NULL CONSTRAINT [DF_Enrollment_SpId] DEFAULT (@@spid)
) ON [PRIMARY]
GO
ALTER TABLE [Internal].[Enrollment] ADD CONSTRAINT [PK_Internal_Enrollment] PRIMARY KEY CLUSTERED  ([SpId], [EnrollItemID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Internal_Enrollment_DSMemberID] ON [Internal].[Enrollment] ([SpId], [DSMemberID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Internal_Enrollment] ON [Internal].[Enrollment] ([SpId], [DSMemberID], [BeginDate], [EndDate], [EnrollGroupID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Internal_Enrollment_EnrollGroupID] ON [Internal].[Enrollment] ([SpId], [EnrollGroupID]) ON [PRIMARY]
GO
