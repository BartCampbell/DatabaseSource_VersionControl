SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[LastRevDSB]
AS
select *
from [dbo].[DSB] a
where RevisionId = (select max([RevisionId])
                    from [dbo].[DSB] b 
                    where a.InterchangeId = b.InterchangeId 
                      and a.PositionInInterchange = b.PositionInInterchange
                    )
GO
