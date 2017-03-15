SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[LastRevAIN]
AS
select *
from [dbo].[AIN] a
where RevisionId = (select max([RevisionId])
                    from [dbo].[AIN] b 
                    where a.InterchangeId = b.InterchangeId 
                      and a.PositionInInterchange = b.PositionInInterchange
                    )
GO
