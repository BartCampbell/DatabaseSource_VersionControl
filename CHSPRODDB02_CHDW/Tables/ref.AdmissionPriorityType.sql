CREATE TABLE [ref].[AdmissionPriorityType]
(
[AdmissionPriorityTypeID] [int] NOT NULL IDENTITY(1, 1),
[AdmissionPriorityTypeCode] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[AdmissionPriorityType] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[EffectiveStartDate] [datetime] NOT NULL,
[EffectiveEndDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [ref].[AdmissionPriorityType] ADD CONSTRAINT [PK_AdmissionPriorityType] PRIMARY KEY CLUSTERED  ([AdmissionPriorityTypeID]) ON [PRIMARY]
GO
