CREATE TABLE [dbo].[tblHCCRate]
(
[HCC] [tinyint] NOT NULL,
[PaymentModel] [tinyint] NOT NULL,
[RateYear] [smallint] NOT NULL,
[Community] [float] NULL,
[Institutional] [float] NULL,
[ESRD] [float] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblHCCRate] ADD CONSTRAINT [PK__tblHCCRate] PRIMARY KEY CLUSTERED  ([HCC], [PaymentModel], [RateYear]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
