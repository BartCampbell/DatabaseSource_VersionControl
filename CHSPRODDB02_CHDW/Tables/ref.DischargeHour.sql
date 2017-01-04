CREATE TABLE [ref].[DischargeHour]
(
[DischargeHourID] [int] NOT NULL IDENTITY(1, 1),
[DischargeHourCode] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DischargeHour] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[EffectiveStartDate] [datetime] NOT NULL,
[EffectiveEndDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [ref].[DischargeHour] ADD CONSTRAINT [PK_DischargeHour] PRIMARY KEY CLUSTERED  ([DischargeHourID]) ON [PRIMARY]
GO
