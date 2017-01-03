CREATE TABLE [dbo].[tblMORHeader]
(
[MORHeader_PK] [bigint] NOT NULL IDENTITY(1, 1),
[Member_PK] [bigint] NULL,
[PaymentYear] [smallint] NULL,
[PaymentMonth] [smallint] NULL,
[RunDate] [date] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblMORHeader] ADD CONSTRAINT [PK_MORHeader] PRIMARY KEY CLUSTERED  ([MORHeader_PK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_MORHeader] ON [dbo].[tblMORHeader] ([Member_PK], [PaymentYear], [PaymentMonth]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
