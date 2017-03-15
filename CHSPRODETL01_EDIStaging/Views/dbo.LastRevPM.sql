SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[LastRevPM]
AS
select *
from [dbo].[PM] a
where RevisionId = (select max([RevisionId])
                    from [dbo].[PM] b 
                    where a.InterchangeId = b.InterchangeId 
                      and a.PositionInInterchange = b.PositionInInterchange
                    )
GO
