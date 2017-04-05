SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE VIEW [dbo].[member_gm]
AS
SELECT * FROM import.Members
where	measureset not in (select measureset from dw_xref_inactive_decks)
--where	measureset in ('ASM_Sample','BCS_Sample','CDC_Sample','PPC_Sample',
--		'CIS_Sample','COL_Sample','GSO_Sample','SPR_Sample','PCE_Sample',
----		'CBP_Sample','PBH_Sample','OMW_Sample','AMM_Sample','FUH_Sample',
--		'MPM_Sample','DDE_Sample','DAE_Sample')
--where	measure in ('IPU','AMB','DDE','RCA','CMC','RCO','SPR','RDI','CDC','RHY','CBP','IET','AWC','CCS','COL','PPC')

--
--insert into dw_xref_inactive_decks
--select	distinct measureset
--from	member_gm_2009
--where	measure not in (
--		'CDC','ASM','CIS','CMC','IET','LBP','ORX','RAS','RCA','RCO','RDI','RHY','RLB','SPR')




GO
