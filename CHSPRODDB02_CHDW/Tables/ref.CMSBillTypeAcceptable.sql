CREATE TABLE [ref].[CMSBillTypeAcceptable]
(
[ClaimType] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClaimTypeDesc] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderTypeCode] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderTypeDesc] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BillTypeCode] [char] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BillTypeDesc] [nvarchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ExpectedCheckLength] [smallint] NULL,
[BillTypeCodeCheck] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CMSBillTypeAcceptableID] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [ref].[CMSBillTypeAcceptable] ADD CONSTRAINT [PK_CMSBillTypeAcceptable] PRIMARY KEY CLUSTERED  ([CMSBillTypeAcceptableID]) ON [PRIMARY]
GO
