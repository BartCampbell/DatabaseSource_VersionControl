CREATE TABLE [dbo].[CMSBillTypeAcceptable]
(
[ClaimType] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClaimTypeDesc] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderTypeCode] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderTypeDesc] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BillTypeCode] [char] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BillTypeDesc] [nvarchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ExpectedCheckLength] [smallint] NULL,
[BillTypeCodeCheck] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CMSBillTypeAcceptableID] [int] NOT NULL IDENTITY(1, 1)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CMSBillTypeAcceptable] ADD CONSTRAINT [PK_CMSBillTypeAcceptable] PRIMARY KEY CLUSTERED  ([CMSBillTypeAcceptableID]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
