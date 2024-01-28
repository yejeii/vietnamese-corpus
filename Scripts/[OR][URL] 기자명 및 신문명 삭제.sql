USE vncsim;

START TRANSACTION;

-- 1. 대상 확인 - DAT_SRC
-- 05(문학) 제외
SELECT substring_index(DAT_SRC, '/', 3) "DAT_SRC", TOPIC_CD
FROM url_excel_list_from_20230920 
GROUP BY substring_index(DAT_SRC, '/', 3), TOPIC_CD 
-- DAT_SRC						TOPIC_CD
-- http://www.gioivan.net	05
-- https://bvhttdl.gov.vn	05
-- https://bvhttdl.gov.vn	07
-- https://moh.gov.vn	04
-- https://suckhoedoisong.vn	04
-- https://www.moh.gov.vn	04


-- 2. 파일의 마지막 SEQ DAT_TXT에서의 기자명/신문사 삭제
-- -- 1. TOPIC_CD = 05 확인
-- 중복인 데이터 확인
SELECT DAT_TXT 
	, char_length(DAT_TXT) - char_length(REPLACE(DAT_TXT,' ','')) + 1 AS "WORD_CNT"
	, count(*) , sum(count(*)) over() AS "SUM"	
FROM url_scrap_txt_from_20230920		
WHERE (FILE_NAME, SEQ) IN (	
										SELECT t.FILE_NAME , max(t.SEQ) 
										FROM url_scrap_txt_from_20230920 t
										JOIN url_excel_list_from_20230920 e
											ON t.FILE_NAME = e.COL_PK
										AND e.TOPIC_CD = '05'
										AND substring_index(t.DAT_SRC, '/', 3) = 'http://www.gioivan.net'	-- X
-- 										AND substring_index(t.DAT_SRC, '/', 3) = 'https://bvhttdl.gov.vn'	-- X
										GROUP BY t.FILE_NAME	
									)
-- AND BINARY DAT_TXT REGEXP '(Nguồn|Ảnh|Theo|Hotline|(Điện )?[tT]hoại|Email|http)'
AND DAT_TXT <> ''
GROUP BY DAT_TXT
HAVING COUNT(*) > 1;

-- -- 2. TOPIC_CD <> 05 확인
-- -- -- 1. 조회용 임시 T 생성
CREATE TABLE temp_20230920_lstxt AS 
SELECT ROW_NUMBER () OVER(ORDER BY t.FILE_NAME) AS "ROWNUM"
	, t.FILE_NAME 
	, substring_index(t.DAT_SRC, '/', 3) AS "DAT_SRC"
	, e.TOPIC_CD, max(t.SEQ) AS "MAX_SEQ"	
FROM url_scrap_txt_from_20230920 t
JOIN url_excel_list_from_20230920 e
	ON t.FILE_NAME = e.COL_PK
AND e.TOPIC_CD <> '05'
GROUP BY t.FILE_NAME;
-- 9240

ALTER TABLE vncsim.temp_20230920_lstxt ADD CONSTRAINT temp_20230920_lstxt_pk PRIMARY KEY (FILE_NAME);

START TRANSACTION;

-- -- -- 2. 단어 수 10 이하 '' 처리
/* 1. CTE(HAVING절 주석) 조회 -> 확인 후 바로 UPDATE
 * 2. 1번의 경우에 일반 텍스트가 많이 있는 경우, HAVING절 해제하여 UPDATE 
 * 3. UPDATE시, SELECT COUNT(*) 확인 후 처리 */

SAVEPOINT s2_2;

-- UPDATE url_scrap_txt_from_20230920 t 
SELECT count(*) FROM url_scrap_txt_from_20230920 t
JOIN temp_20230920_lstxt e	
	ON t.FILE_NAME = e.FILE_NAME
AND t.SEQ = e.MAX_SEQ 
JOIN (
	WITH del_lst_cte AS (
		SELECT t.DAT_TXT 
			, count(*) 
			, sum(count(*)) over() AS "SUM"	-- 확인 후 업데이트
		FROM url_scrap_txt_from_20230920	t	
		JOIN temp_20230920_lstxt e	
			ON t.FILE_NAME = e.FILE_NAME
		AND t.SEQ = e.MAX_SEQ 
-- 		AND e.DAT_SRC = 'https://bvhttdl.gov.vn'	
-- 		AND e.DAT_SRC = 'https://moh.gov.vn'	
-- 		AND e.DAT_SRC = 'https://suckhoedoisong.vn'		-- 205
		AND e.DAT_SRC = 'https://www.moh.gov.vn'	
		AND char_length(t.DAT_TXT) - char_length(REPLACE(t.DAT_TXT,' ','')) + 1 <= 10
		AND t.DAT_TXT <> ''
		GROUP BY t.DAT_TXT
-- 		HAVING count(*) > 1
	)
	SELECT * FROM del_lst_cte
) cte 
ON t.DAT_TXT = cte.DAT_TXT
-- SET t.DAT_TXT = '';

-- -- -- 3. 단어 수 10 초과 처리(마지막 문장 길이가 많은 경우)
/* 뒤에서 두번째 '.' 이후로 존재하는 텍스트를 확인, 삭제 처리
 * 1. 마지막 . 뒤로 텍스트가 있는지 확인
 * 2. 1의 경우가 없는 경우, 마지막에서 두번째 '.' 이후의 텍스트 그룹핑하여 확인, 삭제 */

SAVEPOINT s2_3;

-- 1. 마지막 . 뒤로 텍스트가 있는지 확인
SELECT b.DAT_SRC 
	, LENGTH(substring_index(a.DAT_TXT , '.', -1)) AS "LEN"
	, COUNT(*)
FROM url_scrap_txt_from_20230920	a
JOIN temp_20230920_lstxt b
	ON a.FILE_NAME = b.FILE_NAME 		
AND a.SEQ = b.MAX_SEQ 
AND a.DAT_TXT <> ''
AND char_length(a.DAT_TXT) - char_length(REPLACE(a.DAT_TXT,' ','')) + 1 > 10
GROUP BY b.DAT_SRC, LENGTH(substring_index(a.DAT_TXT , '.', -1));
-- X

-- 2. 마지막에서 두번째 '.' 이후의 텍스트 그룹핑하여 삭제
/* lst_txt_cte : 자를 텍스트 그룹핑하여 단어 수 및 소계, 총계 조회
 * 	where 조건 : DAT_SRC , 단어 수 > 10, 자를 단어 수 <= 7
 * lst_txt_cte_2 : 테이블 데이터와 조인하기 위한 cte. lst_txt_cte의 last_txt 대상에 해당하는 실제 데이터를 선별하는 cte.
 * 	로우 수가 lst_txt_cte의 총계와 동일해야 update 가능함! */

-- 최종 실행(그룹핑 주석) ---------------------
-- UPDATE url_scrap_txt_from_20230920 scrap_t
JOIN (
		-- 2차 실행(lst_txt_cte_2에서 그룹핑 주석 해제하여 조회) -----------------------------
		WITH lst_txt_cte AS ( 
			-- 1차 실행 -------------
			SELECT substring_index(a.DAT_TXT , '.', -2) AS "LAST_TXT"	
				, CONVERT(char_length(substring_index(a.DAT_TXT , '.', -2) ), UNSIGNED) 
					- CONVERT(char_length(REPLACE(substring_index(a.DAT_TXT , '.', -2), ' ' , '')), UNSIGNED ) + 1 AS "WORD_CNT"
				, COUNT(*) AS "CNT"
				, SUM(COUNT(*)) OVER() AS "SUM"	
			FROM url_scrap_txt_from_20230920	a
			JOIN temp_20230920_lstxt b
				ON a.FILE_NAME = b.FILE_NAME 		
			AND a.SEQ = b.MAX_SEQ 
			AND b.DAT_SRC = 'https://bvhttdl.gov.vn'	-- WORD_CNT: 7, SUM: 865
-- 			AND b.DAT_SRC = 'https://moh.gov.vn'	-- x
-- 			AND b.DAT_SRC = 'https://suckhoedoisong.vn'	-- 20
-- 			AND b.DAT_SRC = 'https://www.moh.gov.vn'	-- x
			AND a.DAT_TXT <> ''
			AND char_length(a.DAT_TXT) - char_length(REPLACE(a.DAT_TXT,' ','')) + 1 > 10
			AND CONVERT(char_length(substring_index(a.DAT_TXT , '.', -2) ), UNSIGNED) 
					- CONVERT(char_length(REPLACE(substring_index(a.DAT_TXT , '.', -2), ' ' , '')), UNSIGNED ) + 1 BETWEEN 2 AND 7		-- 7 : 임의로 설정
			AND REGEXP_INSTR(substring_index(a.DAT_TXT , '.', -2), '^[^0-9]+') 	-- 숫자 구분점(99.999) 행 제외
			GROUP BY LAST_TXT
			HAVING COUNT(*) > 1
			ORDER BY 2 DESC
			-- --------------------------
		),
		lst_txt_cte_2 AS (
			SELECT a.IDX
				, a.DAT_TXT  
				, substring_index(a.DAT_TXT , '.', -2) AS "LAST_TXT"	
				, CONVERT(char_length(substring_index(a.DAT_TXT , '.', -2) ), UNSIGNED) 
					- CONVERT(char_length(REPLACE(substring_index(a.DAT_TXT , '.', -2), ' ' , '')), UNSIGNED ) + 1 AS "WORD_CNT"
				, LEFT(a.DAT_TXT, CONVERT(char_length(a.DAT_TXT), UNSIGNED ) - CONVERT(char_length(substring_index(a.DAT_TXT , '.', -2) ), UNSIGNED ) ) AS "SAVE_TXT"
-- 				, count(*) AS "CNT"					-- 그룹핑 확인용
-- 				, SUM(COUNT(*)) OVER() AS "SUM"	-- 그룹핑 확인용
				, SUM(CASE WHEN 1 THEN 1 END) OVER() AS "SUM"	-- 3차 실행(그룹핑 주석처리). 위의 그룹핑 확인 SUM과 동일해야함.
			FROM url_scrap_txt_from_20230920	a	
			JOIN temp_20230920_lstxt b
				ON a.FILE_NAME = b.FILE_NAME 		
			AND a.SEQ = b.MAX_SEQ 
			AND b.DAT_SRC = 'https://bvhttdl.gov.vn'	-- 865
-- 			AND b.DAT_SRC = 'https://moh.gov.vn'	-- x
-- 			AND b.DAT_SRC = 'https://suckhoedoisong.vn'	-- 20
-- 			AND a.DAT_TXT <> ''
-- 			AND char_length(a.DAT_TXT) - char_length(REPLACE(a.DAT_TXT,' ','')) + 1 > 10
-- 			AND CONVERT(char_length(substring_index(a.DAT_TXT , '.', -2)), UNSIGNED ) 
-- 					- CONVERT(char_length(REPLACE(substring_index(a.DAT_TXT , '.', -2), ' ', '')), UNSIGNED ) + 1 BETWEEN 2 AND 7
			AND substring_index(a.DAT_TXT , '.', -2) IN ( SELECT LAST_TXT FROM lst_txt_cte )	-- 대소문자 구분 X
-- 			GROUP BY LAST_TXT		-- 그룹핑 확인용											
		)
		SELECT * FROM lst_txt_cte_2
		-- -------------------------------------------------------------------------
	) cte
ON scrap_t.IDX = cte.IDX
SET scrap_t.DAT_TXT = cte.SAVE_TXT;