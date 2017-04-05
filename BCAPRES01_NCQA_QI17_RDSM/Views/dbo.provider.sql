SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE VIEW [dbo].[provider]
AS
SELECT * FROM import.Providers
WHERE	measureset NOT IN (SELECT measureset FROM dw_xref_inactive_decks)
--where	measureset in ('ASM_Sample','BCS_Sample','CDC_Sample','PPC_Sample',
--		'CIS_Sample','COL_Sample','GSO_Sample','SPR_Sample','PCE_Sample',
--		'CBP_Sample','PBH_Sample','OMW_Sample','AMM_Sample','FUH_Sample',
--		'MPM_Sample','DDE_Sample','DAE_Sample')
--where	measure in ('IPU','AMB','DDE','RCA','CMC','RCO','SPR','RDI','CDC','RHY','CBP','IET','AWC','CCS','COL','PPC')


GO
