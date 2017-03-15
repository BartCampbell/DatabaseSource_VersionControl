SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[LastRevIDC]
AS
select *
from [dbo].[IDC] a
where RevisionId = (select max([RevisionId])
                    from [dbo].[IDC] b 
                    where a.InterchangeId = b.InterchangeId 
                      and a.PositionInInterchange = b.PositionInInterchange
                    )
GO
