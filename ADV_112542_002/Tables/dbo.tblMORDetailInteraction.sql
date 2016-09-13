CREATE TABLE [dbo].[tblMORDetailInteraction]
(
[MORHeader_PK] [bigint] NOT NULL,
[Interaction_PK] [tinyint] NOT NULL,
[PaymentModel] [tinyint] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblMORDetailInteraction] ADD CONSTRAINT [PK_MORDetailInteraction] PRIMARY KEY CLUSTERED  ([MORHeader_PK], [Interaction_PK], [PaymentModel]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
