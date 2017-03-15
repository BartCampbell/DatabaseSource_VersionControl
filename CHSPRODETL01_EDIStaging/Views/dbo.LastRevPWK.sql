SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[LastRevPWK]
AS
select *
from [dbo].[PWK] a
where RevisionId = (select max([RevisionId])
                    from [dbo].[PWK] b 
                    where a.InterchangeId = b.InterchangeId 
                      and a.PositionInInterchange = b.PositionInInterchange
                    )
GO
