CREATE TABLE [fact].[Claim]
(
[ClaimID] [bigint] NOT NULL IDENTITY(1, 1),
[Claim_Number] [int] NOT NULL,
[ClientMemberID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MemberFirstName] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MemberLastName] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DOB] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Gender] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClaimStatus] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Client] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RenderingProviderID] [int] NULL,
[RenderingProviderLastName] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RenderingProviderFirstName] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RenderingNPI] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RenderingSpecialtyCode] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RenderingSpecialty] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TaxID] [varchar] (9) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ServiceLocation] [char] (35) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ServiceLocationAddr1] [char] (55) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ServiceLocationAddr2] [char] (55) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ServiceLocationCity] [char] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ServiceLocationState] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ServiceLocationZip] [char] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PayeeProviderID] [int] NULL,
[PayeeProviderLastName] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PayeeProviderFirstName] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PayeeProviderNPI] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PayeeProviderAddr1] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PayeeProviderAddr2] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PayeeProviderCity] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PayeeProviderState] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PayeeProviderZip] [varchar] (11) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PCPID] [int] NULL,
[PCPLastName] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PCPFirstName] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LineItemControlNumber] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ICDNumber] [char] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ICDType] [char] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ICDLineNumber] [tinyint] NULL,
[HI_Position] [tinyint] NULL,
[ICDSequenceNumber] [int] NOT NULL,
[PresentOnAdmission] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MemberID] [int] NULL,
[ProviderID] [int] NULL,
[PayProviderID] [int] NULL,
[ClientID] [int] NULL,
[ServiceFromDate] [int] NULL,
[ServiceToDate] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [fact].[Claim] ADD CONSTRAINT [PK_Claim] PRIMARY KEY CLUSTERED  ([ClaimID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_Claim_10_1966630049__K2_1] ON [fact].[Claim] ([Claim_Number]) INCLUDE ([ClaimID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_Client_ProviderID_MemberID_PayProviderID] ON [fact].[Claim] ([Client], [ProviderID], [MemberID], [PayProviderID]) INCLUDE ([Claim_Number], [ClaimStatus], [ICDLineNumber], [ICDNumber], [ICDType], [ServiceFromDate], [ServiceToDate]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_RenderingNPI] ON [fact].[Claim] ([RenderingNPI]) ON [PRIMARY]
GO
CREATE STATISTICS [stat_1966630049_9_44] ON [fact].[Claim] ([Client], [MemberID])
GO
CREATE STATISTICS [stat_1966630049_9_45_47_44] ON [fact].[Claim] ([Client], [ProviderID], [PayProviderID], [MemberID])
GO
CREATE STATISTICS [stat_1966630049_45_44_47] ON [fact].[Claim] ([PayProviderID], [ProviderID], [MemberID])
GO
CREATE STATISTICS [stat_1966630049_45_47] ON [fact].[Claim] ([ProviderID], [PayProviderID])
GO
ALTER TABLE [fact].[Claim] ADD CONSTRAINT [FK_Claim_Client] FOREIGN KEY ([ClientID]) REFERENCES [dim].[Client] ([ClientID])
GO
ALTER TABLE [fact].[Claim] ADD CONSTRAINT [FK_Claim_Member] FOREIGN KEY ([MemberID]) REFERENCES [dim].[Member] ([MemberID])
GO
ALTER TABLE [fact].[Claim] ADD CONSTRAINT [FK_Claim_Provider] FOREIGN KEY ([ProviderID]) REFERENCES [dim].[Provider] ([ProviderID])
GO
