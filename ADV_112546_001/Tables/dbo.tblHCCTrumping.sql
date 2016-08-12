CREATE TABLE [dbo].[tblHCCTrumping]
(
[HCC] [tinyint] NOT NULL,
[PaymentModel] [tinyint] NOT NULL,
[TrumpedHCC] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblHCCTrumping] ADD CONSTRAINT [PK_tblHCCTrumping] PRIMARY KEY CLUSTERED  ([HCC], [PaymentModel]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
