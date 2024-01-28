USE vncsim;

START TRANSACTION;

-- 1. 문자가 없는 행에서의 특수문자 처리
-- WHERE절 차례차례 처리

SAVEPOINT P1;

-- 전체적으로 특수문자 대략 파악
SELECT FILE_TXT , COUNT(FILE_TXT), SUM(COUNT(FILE_TXT)) OVER() "SUM"		-- 44
FROM load_vnc_file_docx_sim_20230905	-- UPDATE load_vnc_file_docx_sim_20230905 SET FILE_TXT = ''
WHERE FILE_TXT <> ''
AND TRIM(FILE_TXT) <> '.'
AND FILE_TXT NOT REGEXP '[[:alnum:]]' 
GROUP BY FILE_TXT;

-- SELECT *
SELECT FILE_TXT , COUNT(FILE_TXT), SUM(COUNT(FILE_TXT)) OVER() "SUM"
-- SELECT FILE_TXT , regexp_replace(FILE_TXT, '^(\\. \\. \\.)([[:blank:]]*)([[:alnum:]]+)', '\\3') 
FROM load_vnc_file_docx_sim_20230905	
	-- UPDATE load_vnc_file_docx_sim_20230905 SET FILE_TXT = regexp_replace(FILE_TXT, '^(\\. \\. \\.)([[:blank:]]*)([[:alnum:]]+)', '\\3') 
-- 	UPDATE load_vnc_file_docx_sim_20230905 SET FILE_TXT = ''
-- WHERE FILE_TXT REGEXP '^([\\.|\\_|\\-|\\*]{2})+([\\.|\\_|\\-|\\*])*$'	-- 21		
-- WHERE FILE_TXT REGEXP '^(\\.[[:blank:]]+){2,}(\\.)*$'			
-- WHERE FILE_TXT REGEXP '^(\\.   \\.   )+(\\.)*$'			-- 필요 X
-- WHERE FILE_TXT REGEXP '^(\\*[[:blank:]]*\\*[[:blank:]]*)+(\\*)*$'			
-- WHERE FILE_TXT REGEXP '^(=[[:blank:]]*=[[:blank:]]*)+(=)*$'						
-- WHERE FILE_TXT REGEXP '^\\+(\\-)+\\+$'				-- 보류(아래에서 이상한 표 제거 후 확인)
-- WHERE FILE_TXT REGEXP '^(\\-)+\\+'				-- 보류(아래에서 이상한 표 제거 후 확인)
-- WHERE FILE_TXT REGEXP '^(\\. \\. \\.)([[:blank:]]*)([[:alnum:]]+)'	
-- 아래부터는 특수문자 확인 후 변형해서 제거
-- WHERE FILE_TXT NOT REGEXP '[[:alnum:]|\\"|\\“|\\<|\\(|\'|\\{|\\$|\\[|\\*|\\~|\\!|\\?|\\!|\\;|\\)|”|\\]]'	-- 특수문자 확인용
-- WHERE FILE_TXT LIKE '-%' AND FILE_TXT NOT REGEXP '[[:alnum:]|\\"|\'|\\,|\\*|\\+|\\!|\\?]'
-- WHERE FILE_TXT LIKE '—%' AND FILE_TXT NOT REGEXP '[[:alnum:]|\\"|\'|\\,|\\*|\\+|\\!|\\?]'	
-- WHERE FILE_TXT LIKE '- -%%' AND FILE_TXT NOT REGEXP '[[:alnum:]]'							
-- WHERE FILE_TXT LIKE '- : - : - : -.%' AND FILE_TXT NOT REGEXP '[[:alnum:]]'						
-- WHERE FILE_TXT LIKE '-- %' AND FILE_TXT NOT REGEXP '[[:alnum:]]'					
-- WHERE FILE_TXT LIKE '. %' AND (FILE_TXT NOT REGEXP '[[:alnum:]|\\"|\'|\\,|\\*\\]\\”|\\)|\\]|\\”|\\?|’|“]')		
-- WHERE FILE_TXT LIKE '. .%' AND (FILE_TXT NOT REGEXP '[[:alnum:]|\\"|\'|\\,|\\*\\]\\”|\\)|\\]|\\?|’|“]')		
-- WHERE FILE_TXT LIKE '.  .%' AND (FILE_TXT NOT REGEXP '[[:alnum:]|\\"|\'|\\,|\\*\\]\\”|\\)|\\]|\\?|’|“]')	
-- WHERE FILE_TXT LIKE '.    .%' AND (FILE_TXT NOT REGEXP '[[:alnum:]|\\"|\'|\\,|\\*\\]\\”|\\)|\\]|\\?|’|“]')	
-- WHERE FILE_TXT LIKE '..%' AND (FILE_TXT NOT REGEXP '[[:alnum:]|\\"|\'|\\,|\\*\\]\\”|\\)|\\]|\\!|\\;|\\?|’|“]')	
-- WHERE FILE_TXT LIKE '\\\%' AND (FILE_TXT NOT REGEXP '[[:alnum:]|\\"|\'|\\,|\\*\\]\\”|\\)|\\]]')	-- \ 삭제
-- WHERE FILE_TXT LIKE '=====%' AND (FILE_TXT NOT REGEXP '[[:alnum:]|\\"|\'|\\,|\\*\\]\\”|\\)|\\]]')		
-- WHERE FILE_TXT LIKE '........%' AND (FILE_TXT NOT REGEXP '[[:alnum:]|\\"|\'|\\,|\\*\\]\\”]')
-- WHERE FILE_TXT REGEXP '^[_]+[[:blank:]]?' AND (FILE_TXT NOT REGEXP '[[:alnum:]|\\"|\'|\\,|\\*\\]\\”]')	
-- WHERE FILE_TXT REGEXP '^[—]+[[:blank:]]?' AND (FILE_TXT NOT REGEXP '[[:alnum:]|\\"|\'|\\,|\\*\\]\\”]')	
-- WHERE FILE_TXT REGEXP '^«(\\.[[:blank:]]?)+' AND FILE_TXT NOT REGEXP '[[:alnum:]]' 
-- WHERE FILE_TXT = '――――'
AND FILE_TXT <> ''
AND FILE_TXT NOT REGEXP '[[:alnum:]]' 
GROUP BY FILE_TXT	-- 확인용


COMMIT;

-- 이상한 표 확인 후 제거	: 한 파일에 3개 이상 있으면 삭제.
-- |
-- +-----
-- +======
SELECT FILE_NAME, COUNT(FILE_TXT), min(SEQ)
FROM load_vnc_file_docx_sim_20230905	
WHERE ( FILE_TXT LIKE '|%' 
	OR FILE_TXT LIKE '│%'
-- 	OR FILE_TXT LIKE '%|%'	-- 2차로
-- 	OR FILE_TXT LIKE '%│%'	-- 2차로
	OR FILE_TXT LIKE '+----%' 
	OR FILE_TXT LIKE '+======%'
	OR FILE_TXT LIKE '----+%' )
GROUP BY FILE_NAME 
ORDER BY 2 DESC;

-- SELECT *
-- SELECT count(*) 	-- 20921
SELECT count(DISTINCT FILE_NAME)	-- 10	-- DELETE 
-- FROM load_vnc_org_lst_sim_20231207_05
-- FROM load_vnc_file_list_sim_20231207_05
FROM load_vnc_file_docx_sim_20230905		-- 가장 마지막에 DELETE!		
WHERE FILE_NAME IN (	SELECT FILE_NAME	
						FROM load_vnc_file_docx_sim_20230905		
						WHERE ( FILE_TXT LIKE '|%' 
								OR FILE_TXT LIKE '│%'
-- 								OR FILE_TXT LIKE '%|%'	-- 2차로
-- 								OR FILE_TXT LIKE '%│%'	-- 2차로
								OR FILE_TXT LIKE '+----%' 
								OR FILE_TXT LIKE '+======%'
								OR FILE_TXT LIKE '----+%' )
						GROUP BY FILE_NAME 	
						HAVING COUNT(FILE_TXT) >= 3	)

-- COUNT(FILE_TXT) 3 미만 확인
SELECT *
-- SELECT  FILE_TXT , REPLACE(FILE_TXT, ' | ', ', ')	-- DELETE 
FROM load_vnc_file_docx_sim_20230905	-- UPDATE load_vnc_file_docx_sim_20230905 SET FILE_TXT = REPLACE(FILE_TXT, ' | ', ', ')
WHERE FILE_NAME = '01_CW001_20230905_0131'
-- AND SEQ BETWEEN 1120 AND 1133
AND SEQ >= 110
-- AND ( FILE_TXT LIKE '|%' 
-- 	OR FILE_TXT LIKE '│%'
-- 	OR FILE_TXT LIKE '%|%'	-- 2차로
-- 	OR FILE_TXT LIKE '%│%' )
-- AND FILE_TXT = 'KẾT THÚC'