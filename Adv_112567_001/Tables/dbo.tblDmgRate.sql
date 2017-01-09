CREATE TABLE [dbo].[tblDmgRate]
(
[Dmg_PK] [tinyint] NOT NULL,
[PaymentModel] [tinyint] NOT NULL,
[RateYear] [smallint] NOT NULL,
[Community] [float] NULL,
[Institutional] [float] NULL,
[ESRD] [float] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblDmgRate] ADD CONSTRAINT [PK__tblDmgRate] PRIMARY KEY CLUSTERED  ([Dmg_PK], [PaymentModel], [RateYear]) ON [PRIMARY]
GO
