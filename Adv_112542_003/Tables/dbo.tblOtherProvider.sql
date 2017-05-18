CREATE TABLE [dbo].[tblOtherProvider]
(
[OtherProvider_PK] [bigint] NOT NULL IDENTITY(1, 1),
[Provider_Name] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblOtherProvider] ADD CONSTRAINT [PK_tblOtherProvider] PRIMARY KEY CLUSTERED  ([OtherProvider_PK]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
