SELECT	*
FROM	RM20101
WHERE	--BACHNUMB = 'CH070519120000' AND CURTRXAM <> 0
		--AND DOCNUMBR <> '001448'
		DOCNUMBR IN ('224497','16-52192','16-52193')

SELECT	*
FROM	RM20201
WHERE	APTODCNM IN ('224497','16-52192','16-52193')
		OR APFRDCNM IN ('224497','16-52192','16-52193')
/*
UPDATE	RM20101
SET		CURTRXAM = ORTRXAMT
WHERE	DOCNUMBR = '4-91436'

UPDATE	RM20101
SET		CURTRXAM = 0
WHERE	DOCNUMBR IN ('028606','39-146843','39-146844')
*/

