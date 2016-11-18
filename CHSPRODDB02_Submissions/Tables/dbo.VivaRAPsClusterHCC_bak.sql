CREATE TABLE [dbo].[VivaRAPsClusterHCC_bak]
(
[MemberHICN] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PatientControlNo] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DXCode] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClusterSource] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[V12HCC] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[V21HCC] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[V22HCC] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[VivaRAPsClusterHCCID] [int] NOT NULL IDENTITY(1, 1)
) ON [PRIMARY]
GO
