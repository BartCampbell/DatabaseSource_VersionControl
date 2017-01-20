CREATE TABLE [dbo].[tblMORDetailHCC]
(
[MORHeader_PK] [bigint] NOT NULL,
[HCC] [tinyint] NOT NULL,
[PaymentModel] [tinyint] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblMORDetailHCC] ADD CONSTRAINT [PK_MORDetailHCC] PRIMARY KEY CLUSTERED  ([MORHeader_PK], [HCC], [PaymentModel]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
