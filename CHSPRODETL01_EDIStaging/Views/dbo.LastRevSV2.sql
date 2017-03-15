SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[LastRevSV2]
AS
select *
from [dbo].[SV2] a
where RevisionId = (select max([RevisionId])
                    from [dbo].[SV2] b 
                    where a.InterchangeId = b.InterchangeId 
                      and a.PositionInInterchange = b.PositionInInterchange
                    )
GO
