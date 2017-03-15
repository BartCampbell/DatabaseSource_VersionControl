SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE VIEW [dbo].[vwCPT_HCPCS]
AS
     SELECT
          [HCPCS CPT Code] AS CPT_HCPCS_Code,
          [2014 Short Description] AS ShortDescription
     FROM Submissions.dbo.[2014 Medicare CPT HCPCS Codes];

GO
