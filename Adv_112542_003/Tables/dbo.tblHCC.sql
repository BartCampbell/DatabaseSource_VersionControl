CREATE TABLE [dbo].[tblHCC]
(
[HCC] [tinyint] NOT NULL,
[PaymentModel] [tinyint] NOT NULL,
[HCC_Desc] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MaxTrump] [smallint] NULL,
[HccCategory_PK] [tinyint] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblHCC] ADD CONSTRAINT [PK__tblHCC] PRIMARY KEY CLUSTERED  ([HCC], [PaymentModel]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
