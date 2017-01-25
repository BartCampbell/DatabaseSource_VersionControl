CREATE TABLE [dbo].[Calendar]
(
[D] [datetime] NOT NULL,
[N] [int] NULL,
[Q] [int] NULL,
[WD] [int] NULL,
[WK] [int] NULL,
[YD] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Calendar] ADD CONSTRAINT [PK_Calendar] PRIMARY KEY CLUSTERED  ([D]) WITH (FILLFACTOR=100) ON [PRIMARY]
GO
