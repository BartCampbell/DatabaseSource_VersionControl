CREATE TABLE [ChartNetImport].[AdditionalMembers]
(
[ProductLine] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Product] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CustomerMemberID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Measure] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[OutputCustomerMemberID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OutputProductLine] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OutputProduct] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [ChartNetImport].[AdditionalMembers] ADD CONSTRAINT [PK_AdditionalMembers] PRIMARY KEY CLUSTERED  ([CustomerMemberID], [Measure]) ON [PRIMARY]
GO
