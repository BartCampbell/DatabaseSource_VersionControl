SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE VIEW [dbo].[visit]
AS
SELECT * FROM import.Visits
--where measureset <> 'CMC_B'
--where	measureset in ('ASM_Sample','BCS_Sample','CDC_Sample','PPC_Sample',
--		'CIS_Sample','COL_Sample','GSO_Sample','SPR_Sample','PCE_Sample',
--		'CBP_Sample','PBH_Sample','OMW_Sample','AMM_Sample','FUH_Sample',
--		'MPM_Sample','DDE_Sample','DAE_Sample')
--where	measure in ('IPU','AMB','DDE','RCA','CMC','RCO','SPR','RDI','CDC','RHY','CBP','IET','AWC','CCS','COL','PPC')



GO
