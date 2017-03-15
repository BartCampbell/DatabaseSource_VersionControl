SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[LastRevHLH]
AS
select *
from [dbo].[HLH] a
where RevisionId = (select max([RevisionId])
                    from [dbo].[HLH] b 
                    where a.InterchangeId = b.InterchangeId 
                      and a.PositionInInterchange = b.PositionInInterchange
                    )
GO
