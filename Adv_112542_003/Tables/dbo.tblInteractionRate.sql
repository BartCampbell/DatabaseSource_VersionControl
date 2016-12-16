CREATE TABLE [dbo].[tblInteractionRate]
(
[Interaction_PK] [tinyint] NOT NULL,
[PaymentModel] [tinyint] NOT NULL,
[RateYear] [smallint] NOT NULL,
[Community] [float] NULL,
[Institutional] [float] NULL,
[ESRD] [float] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblInteractionRate] ADD CONSTRAINT [PK__tblInteractionRate] PRIMARY KEY CLUSTERED  ([Interaction_PK], [PaymentModel], [RateYear]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
