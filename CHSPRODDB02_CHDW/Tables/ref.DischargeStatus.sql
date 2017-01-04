CREATE TABLE [ref].[DischargeStatus]
(
[DischargeStatusID] [int] NOT NULL IDENTITY(1, 1),
[DischargeStatusCode] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DischargeStatus] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[EffectiveStartDate] [datetime] NOT NULL,
[EffectiveEndDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [ref].[DischargeStatus] ADD CONSTRAINT [PK_DischargeStatus] PRIMARY KEY CLUSTERED  ([DischargeStatusID]) ON [PRIMARY]
GO
