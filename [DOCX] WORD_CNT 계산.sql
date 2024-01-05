USE vncsim;

-- truncate TABLE load_vnc_file_docx_sim_20231207_05_cnt;
-- DROP TABLE load_vnc_file_docx_sim_20231207_05_cnt;
CREATE TABLE load_vnc_file_docx_sim_20231207_05_cnt
LIKE vnc.load_vnc_file_docx_sim;

ALTER TABLE load_vnc_file_docx_sim_20231207_05_cnt ADD WORD_CNT INT(5) DEFAULT 0;
ALTER TABLE load_vnc_file_docx_sim_20231207_05_cnt ADD N_CNT INT(2) DEFAULT 0;

CREATE INDEX load_vnc_file_docx_sim_20231207_05_cnt_FILE_TXT_IDX USING BTREE ON load_vnc_file_docx_sim_20231207_05_cnt (FILE_TXT);

TRUNCATE TABLE load_vnc_file_docx_sim_20231207_05_cnt;
INSERT INTO load_vnc_file_docx_sim_20231207_05_cnt
(IDX, FILE_NAME, SEQ, FILE_TXT, INS_DATE)
SELECT IDX, FILE_NAME, SEQ, FILE_TXT, INS_DATE 
FROM load_vnc_file_docx_sim_20231207_05;
-- 


-- 0. 데이터 확인
-- SELECT *	
SELECT count(*)	-- 0
FROM load_vnc_file_docx_sim_20231207_05_cnt
WHERE  FILE_TXT  LIKE '%\n%';


-- 1. '_x000D_' 제거
-- SELECT *	
SELECT count(*)	-- 744
-- SELECT count(DISTINCT file_name)	
FROM load_vnc_file_docx_sim_20231207_05_cnt
WHERE file_txt LIKE '%_x000D_%'

UPDATE load_vnc_file_docx_sim_20231115_1640_cnt
SET FILE_TXT = REPLACE(file_txt, '_x000D_', ' ')
WHERE file_txt LIKE '%_x000D_%'


-- 2. LIKE '%  %' 로는 지워지지 않는 &nbsp 제거(load_vnc_file_docx_sim에 해당)
-- SELECT FILE_NAME , SEQ , FILE_TXT, REPLACE(FILE_TXT, UNHEX('C2A0'), ' ')	
SELECT count(*)	-- 0
FROM load_vnc_file_docx_sim_20231207_05_cnt
WHERE FILE_TXT LIKE concat('%', UNHEX('C2A0'),  '%')

UPDATE load_vnc_file_docx_sim_20231115_1640_cnt
SET FILE_TXT = REPLACE(FILE_TXT, UNHEX('C2A0'), ' ')
WHERE FILE_TXT LIKE concat('%', UNHEX('C2A0'),  '%')



-- 3. 앞 뒤 공백 제거(줄바꿈 또는 탭은 제거 X)
SELECT FILE_TXT , trim(FILE_TXT)
FROM load_vnc_file_docx_sim_20231207_05_cnt
WHERE FILE_TXT LIKE ' %'

UPDATE load_vnc_file_docx_sim_20231207_05_cnt
SET file_txt = trim(file_txt)


-- -- 1. trim()으로 안되는 앞 빈칸 제거(있으면 여러 번 반복)

-- Space : 공백 문자. ASCII코드 32
-- SELECT FILE_TXT 
-- -- SELECT COUNT(*)	-- 0
-- FROM load_vnc_file_docx_sim_20231115_1640_cnt
-- WHERE FILE_TXT REGEXP '^( )'
-- 
-- UPDATE load_vnc_file_docx_sim_20231115_1640_cnt
-- SET FILE_TXT = regexp_replace(FILE_TXT, '^( )', '')
-- WHERE FILE_TXT REGEXP '^( )'

-- UPDATE load_vnc_file_docx_sim_20231107_1632_cnt
-- SET FILE_TXT = regexp_replace(FILE_TXT, '^\t', '')
-- WHERE FILE_TXT LIKE '\t%'


-- [[:blank:]] (Whitespace) : Space, 공백( ), 탭(\t), 등 의미상 빈칸을 모두 포함(이상한 HTML 용어도 포함함.)
-- 							단, 개행 문자(행을 새로 여는 문자(CR(ASCII 0x0D(\r)) + LF(ASCII 0x0A(\n)), 즉 키보드의 엔터키., 윈도우 - \r\n, 리눅스/맥 - \n)는 인식 X
-- 							마리아DB에서는 일반적으로 개행문자로 "\n"을 사용.

-- [[:space:]] : [[:blank:]] + 개행문자(CRLF) !!!
-- 				 이때, 개행문자(\n)는 두칸으로 인식됨!!!!!!!!!!!!!
-- 				 그래서 만약 'abc \n'에서 [[:space:]]{3,} 을 제거하면 'abc'로 저장된다!!!


-- like '%  %'은 큰 범위에서 [[:blank:]]에 속하고, [[:blank:]]는 [[:space:]]에 속한다
-- [[:blank:]]와 [[:space:]]은 개행문자 포함 여부로 구분!
-- SELECT *	
SELECT COUNT(*)	
-- SELECT FILE_TXT , regexp_replace(FILE_TXT, '[[:space:]]{2, }', ' ') 
FROM load_vnc_file_docx_sim_20231207_05_cnt
-- WHERE FILE_TXT REGEXP '[[:space:]]{2}'		-- 822
-- WHERE FILE_TXT REGEXP '[[:blank:]]{2}'		-- 822
-- WHERE FILE_TXT LIKE '%  %'					-- 822

	


-- SELECT *	
SELECT COUNT(*)	-- 0
-- SELECT FILE_TXT , regexp_replace(FILE_TXT, '^[[:blank:]]{3,}', '')
FROM load_vnc_file_docx_sim_20231207_05_cnt
WHERE FILE_TXT REGEXP '^[[:space:]]{3,}'		

UPDATE load_vnc_file_docx_sim_20231115_05_cnt
SET FILE_TXT = regexp_replace(FILE_TXT, '^[[:space:]]{3,}', '')
WHERE FILE_TXT REGEXP '^[[:space:]]{3,}'

select count(*)	-- 0
-- SELECT FILE_TXT , regexp_replace(FILE_TXT, '^[[:blank:]]{2,}', '')
FROM load_vnc_file_docx_sim_20231207_05_cnt
WHERE FILE_TXT REGEXP '^[[:space:]]{2,}'

UPDATE load_vnc_file_docx_sim_20231115_1640_cnt
SET FILE_TXT = regexp_replace(FILE_TXT, '^[[:space:]]{2,}', '')
WHERE FILE_TXT REGEXP '^[[:space:]]{2,}'

SELECT count(*)	-- 0
-- SELECT FILE_TXT , regexp_replace(FILE_TXT, '^[[:space:]]', '')
FROM load_vnc_file_docx_sim_20231207_05_cnt
WHERE FILE_TXT REGEXP '^[[:space:]]'

UPDATE url_scrap_txt_from_20231029_cnt
SET FILE_TXT = regexp_replace(FILE_TXT, '^[[:space:]]', '')
WHERE FILE_TXT REGEXP '^[[:space:]]'

-- SELECT *	
SELECT COUNT(*)	-- 0
-- SELECT FILE_TXT , regexp_replace(FILE_TXT, '^[[:blank:]]{3,}', '')
FROM load_vnc_file_docx_sim_20231207_05_cnt
WHERE FILE_TXT REGEXP '^[[:blank:]]{3,}'		

UPDATE load_vnc_file_docx_sim_20231207_05_cnt
SET FILE_TXT = regexp_replace(FILE_TXT, '^[[:blank:]]{3,}', '')
WHERE FILE_TXT REGEXP '^[[:blank:]]{3,}'

select count(*)	-- 0
-- SELECT FILE_TXT , regexp_replace(FILE_TXT, '^[[:blank:]]{2,}', '')
FROM load_vnc_file_docx_sim_20231207_05_cnt
WHERE FILE_TXT REGEXP '^[[:blank:]]{2,}'

UPDATE load_vnc_file_docx_sim_20231207_05_cnt
SET FILE_TXT = regexp_replace(FILE_TXT, '^[[:blank:]]{2,}', '')
WHERE FILE_TXT REGEXP '^[[:blank:]]{2,}'

SELECT count(*)	-- 0
-- SELECT FILE_TXT , regexp_replace(FILE_TXT, '^[[:blank:]]', '')
FROM load_vnc_file_docx_sim_20231207_05_cnt
WHERE FILE_TXT REGEXP '^[[:blank:]]'

UPDATE load_vnc_file_docx_sim_20231207_05_cnt
SET FILE_TXT = regexp_replace(FILE_TXT, '^[[:blank:]]', '')
WHERE FILE_TXT REGEXP '^[[:blank:]]'



-- -- 2. 단순 스페이스 포함한 연이은 빈칸 제거('%': 0개 이상) 
-- *** 주의. 개행문자(\n)를 삭제하는 게 카운트에 편하므로 먼저 [[blank]]로 지운후 [[:space:]]로 확인하여 지운다!!

-- SELECT *	
-- SELECT COUNT(*)	
SELECT FILE_TXT , regexp_replace(FILE_TXT, '[[:blank:]]{8,}', ' ') 
FROM load_vnc_file_docx_sim_20231207_05_cnt
WHERE FILE_TXT REGEXP '[[:blank:]]{8,}'	-- 60	
-- WHERE FILE_TXT REGEXP '[[:space:]]{8,}'		-- 60	
-- WHERE FILE_TXT LIKE '%        %'			-- 

UPDATE load_vnc_file_docx_sim_20231207_05_cnt
SET FILE_TXT = regexp_replace(FILE_TXT, '[[:blank:]]{8,}', ' ') 
WHERE FILE_TXT REGEXP '[[:blank:]]{8,}'					

-- SELECT *	
-- SELECT COUNT(*)
SELECT FILE_TXT , regexp_replace(FILE_TXT, '[[:blank:]]{7,}', ' ') 
FROM load_vnc_file_docx_sim_20231207_05_cnt
WHERE FILE_TXT REGEXP '[[:blank:]]{7,}'	-- 750
-- WHERE FILE_TXT REGEXP '[[:space:]]{7,}'	-- 750
-- WHERE FILE_TXT LIKE '%       %'			-- 			

UPDATE load_vnc_file_docx_sim_20231207_05_cnt
SET FILE_TXT = regexp_replace(FILE_TXT, '[[:blank:]]{7,}', ' ') 
WHERE FILE_TXT REGEXP '[[:blank:]]{7,}'		

-- SELECT *	
-- SELECT COUNT(*)
SELECT FILE_TXT , regexp_replace(FILE_TXT, '[[:blank:]]{6,}', ' ') 
FROM load_vnc_file_docx_sim_20231207_05_cnt
WHERE FILE_TXT REGEXP '[[:blank:]]{6,}'	-- 19
-- WHERE FILE_TXT REGEXP '[[:space:]]{6,}'	-- 19	
-- WHERE FILE_TXT LIKE '%      %'			-- 			

UPDATE load_vnc_file_docx_sim_20231207_05_cnt
SET FILE_TXT = regexp_replace(FILE_TXT, '[[:blank:]]{6,}', ' ') 
WHERE FILE_TXT REGEXP '[[:blank:]]{6,}'		

-- SELECT *	
-- SELECT COUNT(*)	
SELECT FILE_TXT , regexp_replace(FILE_TXT, '[[:blank:]]{5,}', ' ') 
FROM load_vnc_file_docx_sim_20231207_05_cnt
WHERE FILE_TXT REGEXP '[[:blank:]]{5,}'	-- 5
-- WHERE FILE_TXT REGEXP '[[:space:]]{5,}'	-- 5	
-- WHERE FILE_TXT LIKE '%     %'			-- 

UPDATE load_vnc_file_docx_sim_20231207_05_cnt
SET FILE_TXT = regexp_replace(FILE_TXT, '[[:blank:]]{5,}', ' ') 
WHERE FILE_TXT REGEXP '[[:blank:]]{5,}'		

-- SELECT *	
SELECT COUNT(*)	
-- SELECT FILE_TXT , regexp_replace(FILE_TXT, '[[:blank:]]{4,}', ' ') 
FROM load_vnc_file_docx_sim_20231207_05_cnt
WHERE FILE_TXT REGEXP '[[:blank:]]{4,}'	-- 9	
-- WHERE FILE_TXT REGEXP '[[:space:]]{4,}'	-- 9	
-- WHERE FILE_TXT LIKE '%    %'				-- 

UPDATE load_vnc_file_docx_sim_20231207_05_cnt
SET FILE_TXT = regexp_replace(FILE_TXT, '[[:blank:]]{4,}', ' ') 
WHERE FILE_TXT REGEXP '[[:blank:]]{4,}'		

-- SELECT *	
-- SELECT COUNT(*)
SELECT FILE_TXT , regexp_replace(FILE_TXT, '[[:blank:]]{3,}', ' ') 
FROM load_vnc_file_docx_sim_20231207_05_cnt
WHERE FILE_TXT REGEXP '[[:blank:]]{3,}'	-- 0
-- WHERE FILE_TXT REGEXP '[[:space:]]{3,}'	-- 0	-- 개행문자까지 포함하기 떄문.	
-- WHERE FILE_TXT LIKE '%   %'				-- 

UPDATE load_vnc_file_docx_sim_20231207_05_cnt
SET FILE_TXT = regexp_replace(FILE_TXT, '[[:blank:]]{3,}', ' ') 
WHERE FILE_TXT REGEXP '[[:blank:]]{3,}'			

-- SELECT *	
-- SELECT COUNT(*)
SELECT FILE_TXT , regexp_replace(FILE_TXT, '[[:blank:]]{2,}', ' ') 
FROM load_vnc_file_docx_sim_20231207_05_cnt
WHERE FILE_TXT REGEXP '[[:blank:]]{2,}'	-- 12		
-- WHERE FILE_TXT REGEXP '[[:space:]]{2,}'	-- 12	-- 개행문자까지 포함하기 떄문.	
-- WHERE FILE_TXT LIKE '%  %'				-- 

UPDATE load_vnc_file_docx_sim_20231207_05_cnt
SET FILE_TXT = regexp_replace(FILE_TXT, '[[:blank:]]{2,}', ' ') 
WHERE FILE_TXT REGEXP '[[:blank:]]{2,}'	


-- 위에서 [[:blank:]]{2,}이 0이 될 때까지 업데이트 후 아래 쿼리 실행
-- SELECT *	
SELECT COUNT(*)		-- 0
-- SELECT FILE_TXT , regexp_replace(FILE_TXT, '[[:space:]]{3,}', ' ') 
FROM load_vnc_file_docx_sim_20231207_05_cnt
WHERE FILE_TXT REGEXP '[[:space:]]{3,}'		-- ' \n' 확인

UPDATE load_vnc_file_docx_sim_20231207_05_cnt
SET FILE_TXT = regexp_replace(FILE_TXT, '[[:space:]]{3,}', ' ') 
WHERE FILE_TXT REGEXP '[[:space:]]{3,}'

-- SELECT *	
SELECT COUNT(*)	-- 0
-- SELECT FILE_TXT , regexp_replace(FILE_TXT, '[[:space:]]{2,}', ' ') 
FROM load_vnc_file_docx_sim_20231207_05_cnt
WHERE FILE_TXT REGEXP '[[:space:]]{2,}'	-- 2482	-

-- 개행문자 제거
UPDATE load_vnc_file_docx_sim_20231207_05_cnt
SET FILE_TXT = regexp_replace(FILE_TXT, '[[:space:]]{2,}', ' ') 
WHERE FILE_TXT REGEXP '[[:space:]]{2,}'	


-- 마지막으로 '  '로 바꿔서 2개 이상 있는지 확인
-- SELECT *	
SELECT COUNT(*)	-- 0
FROM load_vnc_file_docx_sim_20231207_05_cnt
WHERE FILE_TXT LIKE '%  %';						

UPDATE load_vnc_file_docx_sim_20231207_05_cnt
SET FILE_TXT = REPLACE(FILE_TXT, '  ', ' ')
WHERE FILE_TXT LIKE '%  %';						


-- 3. 중간에 존재하는 탭 제거
-- SELECT *	
SELECT COUNT(*)	-- 0
-- SELECT FILE_TXT, REPLACE(FILE_TXT, '\t', ' ')
FROM load_vnc_file_docx_sim_20231207_05_cnt
WHERE FILE_TXT LIKE '%\t%'

UPDATE load_vnc_file_docx_sim_20231207_05_cnt
SET FILE_TXT = REPLACE(FILE_TXT, '\t', ' ')
WHERE FILE_TXT LIKE '%\t%'		





-- 4. \n 제거

-- -- 1. 줄바꿈만 있는 행 처리
-- SELECT *	
SELECT count(*)	-- 0
FROM load_vnc_file_docx_sim_20231207_05_cnt
-- WHERE FILE_TXT LIKE '\n';
WHERE FILE_TXT REGEXP '^(\n)+$';

UPDATE load_vnc_file_docx_sim_20231207_05_cnt
SET file_txt =  ''
WHERE FILE_TXT REGEXP '^(\n)+$';

-- -- 2. '\n' 줄바꿈으로 시작하는 행에서 줄바꿈만 삭제처리(빈칸이 있을 수 잇음)
-- select *
SELECT count(*)	-- 3850
-- select FILE_TXT , regexp_replace(FILE_TXT, '^(\n)+', '')	
FROM load_vnc_file_docx_sim_20231207_05_cnt
-- WHERE FILE_TXT LIKE '\n%';
WHERE FILE_TXT REGEXP '^[\n]+';

UPDATE load_vnc_file_docx_sim_20231207_05_cnt
SET file_txt =  regexp_replace(FILE_TXT, '^(\n)+', '')	
WHERE FILE_TXT REGEXP '^(\n)+';

-- -- 3. 텍스트 중간에 '\n\n\n' 단순 줄바꿈이 2번 있는 데이터 처리(기본 2번이상 반복하고 \n\n으로 내려가기)
-- select *
SELECT count(*)	-- 0
-- select FILE_TXT , REPLACE(FILE_TXT, '\n\n\n', '\n')	
FROM load_vnc_file_docx_sim_20231207_05_cnt
WHERE FILE_TXT LIKE '%\n\n\n%';

UPDATE load_vnc_file_docx_sim_20231207_05_cnt
SET file_txt =  REPLACE(FILE_TXT, '\n\n\n', '\n')
WHERE FILE_TXT LIKE '%\n\n\n%'

SELECT count(*)
-- select FILE_TXT , REPLACE(FILE_TXT, '\n\n', '\n')	
FROM load_vnc_file_docx_sim_20231207_05_cnt
WHERE FILE_TXT LIKE '%\n\n%';

UPDATE load_vnc_file_docx_sim_20231207_05_cnt
SET file_txt =  REPLACE(FILE_TXT, '\n\n', '\n')
WHERE FILE_TXT LIKE '%\n\n%'


-- -- 4. 문장 사이의 \n\s\s\s를 단순 줄바꿈으로 변경(2번 이상 반복)
-- UPDATE 한 후에 다시 3번 update -> 5번 trim() 처리 -> 2번 update -> 아래로 쭉

-- 3개
-- select *
SELECT count(*)	-- 0
-- select FILE_TXT , REPLACE(FILE_TXT, '\n   ', '\n')	
FROM load_vnc_file_docx_sim_20231207_05_cnt
WHERE FILE_TXT LIKE '%\n   %';

UPDATE load_vnc_file_docx_sim_20231207_05_cnt
SET file_txt =  REPLACE(FILE_TXT, '\n   ', '\n')
WHERE FILE_TXT LIKE '%\n   %'

-- 2개
SELECT count(*)	-- 0
-- select FILE_TXT , REPLACE(FILE_TXT, '\n  ', '\n')	
FROM load_vnc_file_docx_sim_20231207_05_cnt
WHERE FILE_TXT LIKE '%\n  %';

UPDATE load_vnc_file_docx_sim_20231207_05_cnt
SET file_txt =  REPLACE(FILE_TXT, '\n  ', '\n')
WHERE FILE_TXT LIKE '%\n  %'

-- 1개
SELECT count(*)
-- select FILE_TXT , REPLACE(FILE_TXT, '\n ', '\n')	
FROM load_vnc_file_docx_sim_20231207_05_cnt
WHERE FILE_TXT LIKE '%\n %';

UPDATE load_vnc_file_docx_sim_20231207_05_cnt
SET file_txt =  REPLACE(FILE_TXT, '\n ', '\n')
WHERE FILE_TXT LIKE '%\n %'


-- 빈칸 + \n 확인 -- 3개의 조건문 모두 한번씩 실행하여 확인
SELECT *
-- SELECT count(*)	-- 0
-- select FILE_TXT , regexp_replace(FILE_TXT, '[[:blank:]]{1,}\n', '\n')	
FROM load_vnc_file_docx_sim_20231207_05_cnt
-- WHERE FILE_TXT REGEXP '[[:blank:]]{1,}\n';
-- WHERE FILE_TXT REGEXP '[[:blank:]][[:space:]]+';
WHERE FILE_TXT LIKE '% \n%'


UPDATE url_scrap_txt_from_20231029_cnt
SET file_txt =  regexp_replace(FILE_TXT, '[[:blank:]]{1,}\n', '\n')	
WHERE FILE_TXT REGEXP '[[:blank:]]{1,}\n';

-- 다시 확인(세 개의 조건문 모두 실행)
-- SELECT *	
SELECT COUNT(*)	
-- SELECT FILE_TXT , regexp_replace(FILE_TXT, '[[:blank:]]{2,}', ' ') 
FROM url_scrap_txt_from_20231029_cnt
-- WHERE FILE_TXT REGEXP '[[:blank:]]{2,}'	-- 0		
-- WHERE FILE_TXT REGEXP '[[:space:]]{2,}'	
WHERE FILE_TXT LIKE '%  %'					-- 0	

UPDATE url_scrap_txt_from_20231029_cnt
SET FILE_TXT = regexp_replace(FILE_TXT, '[[:blank:]]{2,}', ' ') 
WHERE FILE_TXT REGEXP '[[:blank:]]{2,}'




-- -- 5. trim() 다시 걸어주기
SELECT file_txt, trim(file_txt)
FROM load_vnc_file_docx_sim_20231207_05_cnt
WHERE FILE_TXT REGEXP '^[[:blank:]]+'
OR FILE_TXT REGEXP '[[:blank:]]+$';


UPDATE load_vnc_file_docx_sim_20231207_05_cnt
SET file_txt = trim(file_txt)
-- WHERE FILE_TXT REGEXP '^[[:blank:]]+'
-- OR FILE_TXT REGEXP '[[:blank:]]+$';





-- 5. 처리한 스페이스 두개 이상 재처리(updated rows 0이 나올 떄까지 반복)
SELECT *	
-- SELECT COUNT(*)	-- 22131
FROM load_vnc_file_docx_sim_20231207_05_cnt
WHERE FILE_TXT LIKE '%  %'	

UPDATE load_vnc_file_docx_sim_20231207_05_cnt
SET FILE_TXT = REPLACE(FILE_TXT, '  ', ' ')
WHERE FILE_TXT LIKE '%  %'	




-- 6. 마지막 확인
SELECT file_txt	-- 0
FROM load_vnc_file_docx_sim_20231207_05_cnt
-- WHERE FILE_TXT REGEXP '^[[:blank:]]+'
WHERE FILE_TXT REGEXP '[[:blank:]]+$';

SELECT *
-- SELECT file_txt, regexp_replace(FILE_TXT, '[[:blank:]]{2,}', ' ') 
FROM load_vnc_file_docx_sim_20231207_05_cnt
-- WHERE FILE_TXT REGEXP '[[:blank:]]{2,}';
WHERE FILE_TXT REGEXP '[[:space:]]{2,}';


UPDATE load_vnc_file_docx_sim_20231115_1640_cnt	
SET FILE_TXT= regexp_replace(FILE_TXT, '[[:blank:]]{2,}', ' ') 
WHERE FILE_TXT REGEXP '[[:blank:]]{2,}';

UPDATE load_vnc_file_docx_sim_20231115_1640_cnt
SET FILE_TXT = REPLACE(FILE_TXT, '  ', ' ')
WHERE FILE_TXT LIKE '%  %'	



	
-- 7. 마지막 trim()
-- SELECT *
SELECT count(*)
FROM load_vnc_file_docx_sim_20231207_05_cnt
WHERE file_txt LIKE ' %'
OR file_txt LIKE '% ';

UPDATE load_vnc_file_docx_sim_20231207_05_cnt
SET file_txt = trim(file_txt)
WHERE file_txt LIKE ' %'
OR file_txt LIKE '% '
	
	

-- 8. WORD_CNT 집계
SELECT count(*)	-- 0
-- SELECT FILE_TXT , CHAR_LENGTH(FILE_TXT) - CHAR_LENGTH(REPLACE(FILE_TXT, '\n', '')) "n count"
FROM load_vnc_file_docx_sim_20231207_05_cnt
WHERE FILE_TXT LIKE '%\n%';

-- 8-1. '\n' 집계
UPDATE url_scrap_txt_from_20231029_cnt
SET N_CNT = CHAR_LENGTH(FILE_TXT) - CHAR_LENGTH(REPLACE(FILE_TXT, '\n', ''))
WHERE FILE_TXT <> ''
AND FILE_TXT LIKE '%\n%';


-- 8-2. '\n' 처리한 총 집계
SELECT FILE_TXT, CHAR_LENGTH(FILE_TXT) - CHAR_LENGTH(regexp_replace(FILE_TXT, '[[:blank:]]', '')) + 1 + N_CNT "단어 수"
FROM load_vnc_file_docx_sim_20231207_05_cnt
WHERE N_CNT <> 0

UPDATE load_vnc_file_docx_sim_20231207_05_cnt		
SET WORD_CNT = CHAR_LENGTH(FILE_TXT) - CHAR_LENGTH(regexp_replace(FILE_TXT, '[[:blank:]]', '')) + 1 + N_CNT 
WHERE FILE_TXT <> '';



-- 9. 확인
SELECT *
FROM load_vnc_file_docx_sim_20231207_05_cnt
WHERE WORD_CNT = 1


-- 구어체 제외
SELECT FILE_NAME , count(FILE_NAME)
FROM url_scrap_txt_from_20231029_cnt
WHERE FILE_TXT <> '' AND WORD_CNT = 1
GROUP BY FILE_NAME 
-- 03_CW046_20231024_0094
-- 03_CW046_20231024_0279
-- 07_CW048_20231027_1315
-- 02_CW045_20231024_0316
-- 03_CW046_20231024_0258
-- 02_CW047_20231024_0151
-- 02_CW045_20231024_0032
-- 07_CW048_20231027_1351
-- 02_CW047_20231024_0069
-- 03_CW046_20231024_0257
-- 03_CW040_20231027_0657
-- 03_CW046_20231024_0254
-- 03_CW046_20231024_0205
-- 03_CW046_20231024_0114
-- 03_CW046_20231024_0256
-- 02_CW045_20231024_0447
-- 02_CW045_20231024_0569
-- 03_CW046_20231024_0228

-- 표... 삭제 조치
SELECT count(*)	
-- SELECT count(DISTINCT FILE_NAME)	-- 17	-- delete
FROM url_scrap_txt_from_20231029_cnt
WHERE FILE_NAME IN ( '03_CW046_20231024_0094',
					'03_CW046_20231024_0279',
					'07_CW048_20231027_1315',
					'02_CW045_20231024_0316',
					'03_CW046_20231024_0258',
					'02_CW047_20231024_0151',
					'02_CW045_20231024_0032',
					'07_CW048_20231027_1351',
					'02_CW047_20231024_0069',
					'03_CW046_20231024_0257',
					'03_CW040_20231027_0657',
					'03_CW046_20231024_0254',
					'03_CW046_20231024_0205',
					'03_CW046_20231024_0114',
					'03_CW046_20231024_0256',
					'02_CW045_20231024_0447',
					'02_CW045_20231024_0569',
					'03_CW046_20231024_0228');

SELECT *
FROM url_scrap_txt_from_20231029
WHERE FILE_NAME = '07_CW048_20231027_0271'



-- 구어체의 경우

-- 빈공백 다 잡은 후 특수 문자 확인
SELECT *	
FROM load_vnc_file_docx_sim_20231207_05_cnt	-- UPDATE load_vnc_file_docx_sim_20231207_05 SET FILE_TXT = ''
WHERE idx IN (	
 				select FILE_TXT, COUNT(FILE_TXT)	-- 1차 확안용
-- 				SELECT count(*)	-- GROUP BY 제외해서 실행	-- 4468
-- 				SELECT idx
				FROM load_vnc_file_docx_sim_20231207_05_cnt	-- UPDATE load_vnc_file_docx_sim_20231207_05_cnt SET FILE_TXT = '', WORD_CNT = 0
				WHERE WORD_CNT <= 10000
				AND FILE_TXT <> ''
-- 				AND FILE_TXT NOT REGEXP '[[:alnum:]|\\"|\\“|\\<|\\(|\'|\\{|\\$|\\[|\\,|\\!|\\?|\\.|\\:|\\]|\\”|\\)|\\;|\\…|\\}]'
-- 				AND FILE_TXT <> '='
				AND FILE_TXT NOT REGEXP '[[:alnum:]]'	-- 혹시나 하는 마음에 문자없는 행에서 이상한 문자 있는지 확인(위에꺼 다 실행 후..)
				GROUP BY FILE_TXT	-- 확인용
			)	

SELECT *	
FROM load_vnc_file_docx_sim_20231207_05_CNT
-- WHERE FILE_NAME = '05_CW046_20231207_0011'
-- UPDATE load_vnc_file_docx_sim_20231207_05_cnt SET FILE_TXT = '', WORD_CNT = 0
-- UPDATE load_vnc_file_docx_sim_20231207_05 SET FILE_TXT = ''
WHERE FILE_TXT LIKE '* * * * *.'
-- AND SEQ >= 5760

			
-- word_cnt 3 이하 확인
SELECT FILE_TXT, COUNT(*)
FROM load_vnc_file_docx_sim_20231207_05_cnt
WHERE WORD_CNT <= 3
AND FILE_TXT <> ''
AND FILE_TXT NOT REGEXP '[[:alnum:]|\\"|\\“|\\<|\\(|\'|\\{|\\$|\\[|\\,|\\~|\\!|\\?|\\.|\\:|\\]|\\”|\\)|\\;|\\+|\\-|\\…]'	
GROUP BY FILE_TXT

-- ^( ) 와 ^[[:blank:]] .
-- trim()이 그냥 공백( )만 잡는지 아님 [[:blank:]] (공백으로 포장된 특수문자)도 잡는지 확인.
	


-- 10. WORKER_ID, JOB_YMD 마다 단어 카운트
SELECT MID(FILE_NAME, 4, 5) AS "WORKER_ID", 
	MID(FILE_NAME, 10, 8) AS "JOB_YMD",
	SUM(WORD_CNT)
FROM load_vnc_file_docx_sim_20231207_05_cnt
GROUP BY MID(FILE_NAME, 4, 5), MID(FILE_NAME, 10, 8) 


-- 11. 마지막 count(*) 확인
SELECT count(*)	
FROM load_vnc_org_lst_sim_20231207_05

SELECT count(*)	 
FROM load_vnc_file_list_sim_20231207_05

-- SELECT count(*)	 
SELECT count(DISTINCT FILE_NAME)	
FROM load_vnc_file_docx_sim_20231207_05



-- 11. 기존 docx 테이블에 단어 수 업데이트
ALTER TABLE vncsim.url_scrap_txt_from_20231029 DROP COLUMN DAT_TXT_RE1;
ALTER TABLE vncsim.url_scrap_txt_from_20231029 DROP COLUMN DAT_TXT_RE2;
ALTER TABLE load_vnc_file_docx_sim_20231207_05 ADD WORD_CNT INT(5) DEFAULT 0 COMMENT '단어 수';

SELECT A.*, B.WORD_CNT , B.N_CNT 	
FROM load_vnc_file_docx_sim_20231207_05 A	-- UPDATE load_vnc_file_docx_sim_20231207_05 a
JOIN load_vnc_file_docx_sim_20231207_05_cnt b
ON A.IDX = B.IDX 
SET a.WORD_CNT = b.WORD_CNT 

DROP TABLE IF EXISTS load_vnc_file_docx_sim_20231207_05_cnt;
