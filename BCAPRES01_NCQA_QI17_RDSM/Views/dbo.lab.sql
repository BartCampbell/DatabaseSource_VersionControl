SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE VIEW [dbo].[lab]
AS
SELECT * FROM import.Labs 
WHERE	measureset NOT IN (SELECT measureset FROM dw_xref_inactive_decks)
--		'CIS_Sample','COL_Sample','GSO_Sample','SPR_Sample','PCE_Sample',
--		'CBP_Sample','PBH_Sample','OMW_Sample','AMM_Sample','FUH_Sample',
--		'MPM_Sample','DDE_Sample','DAE_Sample')
--where	measure in ('IPU','AMB','DDE','RCA','CMC','RCO','SPR','RDI','CDC','RHY','CBP','IET','AWC','CCS','COL','PPC')




GO
