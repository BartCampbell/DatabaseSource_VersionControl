CREATE TABLE [ref].[AdmissionHour]
(
[AdmissionHourID] [int] NOT NULL IDENTITY(1, 1),
[AdmissionHourCode] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[AdmissionHour] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[EffectiveStartDate] [datetime] NOT NULL,
[EffectiveEndDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [ref].[AdmissionHour] ADD CONSTRAINT [PK_AdmissionHour] PRIMARY KEY CLUSTERED  ([AdmissionHourID]) ON [PRIMARY]
GO
