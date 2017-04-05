SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE VIEW [dbo].[tblCodeSets]
AS
SELECT * FROM ncqa_rdsm.dbo.tblCodeSets_2011

/*
--tblCodeSets_2007: Production 2007 codesets
--tblCodeSets_2008_manual_modifications:
	-2007 production codesets, manually modified based upon book updates


--tblCodeSets_2008: Not yet available (10/26/2007), anticipate in early November 2007.
*/

GO
