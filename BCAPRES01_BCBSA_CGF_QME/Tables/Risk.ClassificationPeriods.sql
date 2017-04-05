CREATE TABLE [Risk].[ClassificationPeriods]
(
[AllowPrimary] [bit] NOT NULL CONSTRAINT [DF_ClassificationPeriods_IgnorePrimDiag] DEFAULT ((0)),
[AllowSurg] [bit] NOT NULL CONSTRAINT [DF_ClassificationPeriods_AllowSurg] DEFAULT ((0)),
[BeginDays] [smallint] NOT NULL CONSTRAINT [DF_ClassificationPeriods_BeginDays] DEFAULT ((0)),
[BeginMonths] [smallint] NOT NULL CONSTRAINT [DF_ClassificationPeriods_BeginMonths] DEFAULT ((0)),
[ClassPeriodID] [tinyint] NOT NULL,
[EndDays] [smallint] NOT NULL CONSTRAINT [DF_ClassificationPeriods_EndDays] DEFAULT ((0)),
[EndMonths] [smallint] NOT NULL CONSTRAINT [DF_ClassificationPeriods_EndMonths] DEFAULT ((0)),
[IsIESD] [bit] NOT NULL CONSTRAINT [DF_ClassificationPeriods_IsIESD] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [Risk].[ClassificationPeriods] ADD CONSTRAINT [CK_Risk_ClassificationPeriods_AllowPrimary] CHECK (([AllowPrimary]=(1) OR [IsIESD]=(1)))
GO
ALTER TABLE [Risk].[ClassificationPeriods] ADD CONSTRAINT [PK_ClassificationPeriods] PRIMARY KEY CLUSTERED  ([ClassPeriodID]) ON [PRIMARY]
GO
