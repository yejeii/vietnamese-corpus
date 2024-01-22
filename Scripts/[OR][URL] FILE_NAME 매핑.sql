USE vncsim;

-- SET @job_ymd = '20230920';

CREATE TABLE url_excel_list_from_20230920 LIKE url_excel_list_from_20230901;
CREATE TABLE url_scrap_list_from_20230920 LIKE url_scrap_list_from_20230901;
CREATE TABLE url_scrap_txt_from_20230920 LIKE url_scrap_txt_from_20230901;


-- 파이썬 작업 후 -------------------------------

-- 1. 각 테이블 인서트 현황 파악
-- 작업자, 주제분류, 작업날짜로 그룹핑하여 3T 전체 확인
-- 확인 대상 : 작업자 파일과 크롤링된 파일의 url 개수 비교
SELECT "엑셀 T" AS "TABLE"
	, WORKER_ID
	, JOB_YMD
	, TOPIC_CD
	, count(*) "행 수"
FROM url_excel_list_from_20230920 
GROUP BY WORKER_ID, JOB_YMD, TOPIC_CD 
UNION 
SELECT "파일 T"
	, WORKER_ID
	, JOB_YMD
	, ''
	, count(*)
FROM url_scrap_list_from_20230920 
GROUP BY WORKER_ID, JOB_YMD
UNION 
SELECT "문서 T"
	, SUBSTR(FILE_NAME, 10, 5) 
	, SUBSTR(FILE_NAME, 1, 8)
	, ''
	, count(*)
FROM vncsim.url_scrap_txt_from_20230920 
GROUP BY SUBSTR(FILE_NAME, 1, 8), SUBSTR(FILE_NAME, 10, 5)
ORDER BY 2, 4 DESC, 1 DESC;


-- 2. 각 테이블 COUNT(*) 및 COUNT(DISTINCT DAT_SRC) 확인
SELECT "엑셀 T" AS "TABLE", COUNT(*), COUNT(DISTINCT DAT_SRC)		
FROM url_excel_list_from_20230920
UNION 
SELECT "파일 T", COUNT(*), COUNT(DISTINCT DAT_SRC)					
FROM url_scrap_list_from_20230920
UNION
SELECT "문서 T", COUNT(*), COUNT(DISTINCT DAT_SRC)					
FROM url_scrap_txt_from_20230920;
-- TABLE	COUNT(*)	COUNT(DISTINCT DAT_SRC)
-- 엑셀 T	12,199	12,051
-- 파일 T	11,655	11,631
-- 문서 T	396,233	11,631


-- 3. 중복 URL 제거: 기준 - 엑셀 파일 COL_PK. 각각의 임시 테이블에 추가한 후 삭제 처리
-- -- 1. 엑셀 파일 COL_PK 중복 확인
SELECT COL_PK
FROM url_excel_list_from_20230920
GROUP BY COL_PK 
HAVING COUNT(COL_PK) <> 1;
-- X

-- -- 2. 엑셀 테이블에서 중복되는 URL 확인
SELECT DAT_SRC
	, COUNT(*)	"그룹마다 중복 개수"
	, SUM(COUNT(DISTINCT DAT_SRC)) OVER () AS "URL 수"		-- 147(하나가 중복이 3)
	, SUM(COUNT(*)) OVER () AS "중복 건수" 					-- 295
FROM url_excel_list_from_20230920 
GROUP BY DAT_SRC 
HAVING count(DAT_SRC) > 1;

-- -- 3. 중복 url만 모은 임시 excel 테이블 생성
-- DROP TABLE IF EXISTS temp_excel_20230920_dupli_url;
CREATE TABLE IF NOT EXISTS temp_excel_20230920_dupli_url 
	(
		SELECT uslf.IDX, uslf.COL_PK, uslf.DAT_SRC, uslf.WORKER_ID, uslf.JOB_YMD, uslf.SEQ, uslf.TITLE, uslf.PUB_YMD, 	
			ROW_NUMBER () OVER (PARTITION BY uslf.DAT_SRC ORDER BY uslf.WORKER_ID, uslf.JOB_YMD, uslf.IDX) AS "DUPLI_RANK"	
		-- SELECT count(*)	-- 295(중복 행 모두 포함)
		FROM url_excel_list_from_20230920  uslf,
			( 
				SELECT DAT_SRC	
				FROM url_excel_list_from_20230920 
				GROUP BY DAT_SRC
				HAVING count(DAT_SRC) > 1 
			) a
		WHERE uslf.DAT_SRC = a.DAT_SRC	
	);

-- -- 4. 첫 번째가 아닌 중복 행들 확인(엑셀 테이블에서 삭제될 행 개수)
-- SELECT *
SELECT count(*)	-- 148
-- SELECT count(DISTINCT DAT_SRC) -- 147
FROM temp_excel_20230920_dupli_url
WHERE DUPLI_RANK <> 1;

-- -- 5. 중복 엑셀 테이블에서 DUPLI_RANK <> 1 인 행을 이용해 중복 파일 테이블 생성
-- DROP TABLE IF EXISTS temp_scrap_list_20230920_dupli_url;
CREATE TABLE IF NOT EXISTS temp_scrap_list_20230920_dupli_url	
	(
		SELECT uslf.IDX, temp.COL_PK, uslf.SCRAP_FILE_NAME, 
			uslf.WORKER_ID, uslf.JOB_YMD, uslf.SEQ, uslf.DAT_SRC, uslf.TITLE, temp.DUPLI_RANK  	
		-- SELECT count(*)	-- 146 ... 1개 스크롤 안된듯(아래서 확인)
		FROM url_scrap_list_from_20230920 uslf 
		INNER JOIN temp_excel_20230920_dupli_url temp 
			ON uslf.DAT_SRC = temp.DAT_SRC 
		AND temp.dupli_rank <> 1
		AND uslf.WORKER_ID = temp.WORKER_ID 
		AND uslf.JOB_YMD = temp.JOB_YMD 
	);

-- 중복 엑셀 테이블 COUNT() <> 중복 파일 테이블 COUNT()의 경우
-- 정말 없는지 확인
SELECT *
FROM url_scrap_list_from_20230920 c
JOIN 	(	
			SELECT a.WORKER_ID, a.DAT_SRC	-- 146
			FROM temp_excel_20230920_dupli_url a		-- 295
			LEFT JOIN temp_scrap_list_20230920_dupli_url b	-- 146
				ON a.COL_PK = b.COL_PK
			WHERE b.COL_PK IS NULL
			AND a.DUPLI_RANK <> 1
		) d
ON c.DAT_SRC = d.DAT_SRC 
AND c.WORKER_ID = d.WORKER_ID ;
-- X
										
-- -- 6. 중복 파일 테이블에서 문서 테이블 조회하여 중복 문서 테이블 생성
DROP TABLE IF EXISTS temp_scrap_txt_20230920_dupli_url;
CREATE TABLE IF NOT EXISTS temp_scrap_txt_20230920_dupli_url		
	(
		SELECT txt.IDX, temp.COL_PK, 
			txt.FILE_NAME, temp.WORKER_ID, temp.JOB_YMD, 
			txt.DAT_SRC, txt.TITLE , txt.DAT_TXT, temp.DUPLI_RANK
			-- SELECT count(distinct temp.COL_PK)	-- 146(제거할 DISTINCT URL 수)
			-- SELECT count(*)	-- 4241(삭제할 전제 행 수)
		FROM url_scrap_txt_from_20230920 txt 
		JOIN temp_scrap_list_20230920_dupli_url temp
			ON txt.DAT_SRC = temp.DAT_SRC
		AND txt.FILE_NAME = temp.SCRAP_FILE_NAME
		AND txt.TITLE = temp.TITLE
	);

-- 확인
SELECT count(*)	-- 146
FROM temp_scrap_list_20230920_dupli_url;

-- SELECT count(*)	-- 4241
SELECT count(DISTINCT col_pk)	-- 146
FROM temp_scrap_txt_20230920_dupli_url;

-- 중복 파일 테이블에 있는 col_pk가 중복 엑셀 테이블(rank > 1) 에 있는 col_pk인지 확인(삭제대상이 맞는지 확인)
SELECT count(*)
	, count(DISTINCT a.COL_PK)	-- 146
FROM temp_scrap_list_20230920_dupli_url a
INNER JOIN temp_excel_20230920_dupli_url b
ON a.COL_PK = b.COL_PK;

-- 중복 문서 테이블에 있는 col_pk가 중복 엑셀 테이블(rank > 1) 에 있는 col_pk인지 확인(삭제대상이 맞는지 확인)
SELECT count(*)
	, count(DISTINCT a.COL_PK)	-- 146
FROM temp_scrap_txt_20230920_dupli_url a
INNER JOIN temp_excel_20230920_dupli_url b
ON a.COL_PK = b.COL_PK;

-- -- 7. 3T - 중복되는 URL 삭제(위의 코드와 동일.. 위의 순서 역순으로 진행)
SAVEPOINT P1;

-- scrap_txt
SELECT COUNT(*)	-- 4241(삭제할 전제 행 수)	-- DELETE txt	
FROM url_scrap_txt_from_20230920 txt 
JOIN temp_scrap_txt_20230920_dupli_url dupli
	ON txt.IDX = dupli.IDX;

-- scrap_list
SELECT count(*)	-- 146			-- DELETE scrap
FROM url_scrap_list_from_20230920 scrap
JOIN temp_scrap_list_20230920_dupli_url dupli 
	ON scrap.IDX = dupli.IDX 

-- excel_list
SELECT count(*)	-- 148			-- DELETE excel
FROM url_excel_list_from_20230920 excel
JOIN temp_excel_20230920_dupli_url dupli
	ON excel.IDX = dupli.IDX
AND dupli.dupli_rank <> 1

-- -- 8. 삭제 후 확인(COUNT와 DISTINCT COUNT가 동일해야 함!)
-- SELECT count(*)	-- 12051
SELECT COUNT(DISTINCT DAT_SRC)	-- 12051
FROM url_excel_list_from_20230920

-- SELECT count(*)	-- 11510
SELECT COUNT(DISTINCT DAT_SRC)	-- 11510
FROM url_scrap_list_from_20230920 
-- WHERE JOB_YMD  = @job_ymd

-- SELECT count(*)	-- 392038
SELECT count(DISTINCT DAT_SRC)	-- 11510
FROM url_scrap_txt_from_20230920 
-- WHERE FILE_NAME LIKE concat('%',@job_ymd,'%')

-- 이상 없으면 커밋
COMMIT;


-- 4. excel 테이블 기준으로 FILE_NAME 맞추기
-- -- 1. excel 테이블 FILE_NAME 유효성 확인
-- -- -- 1. 중복 확인(위에서 처리)

-- -- -- 2. COL_PK 길이 확인
SELECT length(COL_PK)
FROM url_excel_list_from_20230920 
GROUP BY length(COL_PK)
-- 22

-- -- 2. 파일 테이블 FILE_NAME 매핑
-- DAT_SRC 인덱스 설정 후 실행, 이후 FILE_NAME 인덱스 설정
SELECT COUNT(*)	-- 11510
FROM url_scrap_list_from_20230920 usl
JOIN url_excel_list_from_20230920 uel
	ON uel.DAT_SRC = usl.DAT_SRC
AND usl.JOB_YMD = uel.JOB_YMD
AND usl.WORKER_ID = uel.WORKER_ID;

UPDATE url_scrap_list_from_20230920 usl		
JOIN url_excel_list_from_20230920 uel
	ON uel.DAT_SRC = usl.DAT_SRC 
AND usl.JOB_YMD = uel.JOB_YMD
AND usl.WORKER_ID = uel.WORKER_ID
SET usl.FILE_NAME = uel.FILE_NAME;
-- 11510

-- -- 3. 문서 테이블 FILE_NAME 매핑
-- SELECT COUNT(*)	-- 392038
SELECT COUNT(DISTINCT ust.DAT_SRC)	-- 11510
FROM url_scrap_txt_from_20230920 ust		
JOIN url_scrap_list_from_20230920 usl
	ON ust.DAT_SRC = usl.DAT_SRC 
AND ust.FILE_NAME = usl.SCRAP_FILE_NAME;

UPDATE url_scrap_txt_from_20230920 ust		
INNER JOIN url_scrap_list_from_20230920 usl
	ON ust.DAT_SRC = usl.DAT_SRC 
AND ust.FILE_NAME = usl.SCRAP_FILE_NAME
SET ust.FILE_NAME = usl.FILE_NAME;
-- 392038

-- -- 4. FILE_NAME 확인(NULL(디폴트값) 확인)
SELECT length(FILE_NAME)
FROM url_scrap_list_from_20230920 
GROUP BY length(FILE_NAME)
-- 22

SELECT length(file_name)
FROM url_scrap_txt_from_20230920 
GROUP BY length(FILE_NAME)
-- 22


-- 5. 세 테이블에서 공통된 파일명만 뽑아서 각 테이블 맞추기
-- COL_PK, FILE_NAME 인덱스 설정
DROP TABLE IF EXISTS temp_20230920_3t_match;
CREATE TABLE IF NOT EXISTS temp_20230920_3t_match
SELECT a.COL_PK	-- SELECT count(*)	-- 11510
FROM url_excel_list_from_20230920  a 
JOIN url_scrap_list_from_20230920  b
	ON a.COL_PK = b.FILE_NAME 
JOIN (SELECT DISTINCT FILE_NAME FROM url_scrap_txt_from_20230920 ) c
	ON b.FILE_NAME = c.FILE_NAME;

CREATE INDEX temp_20230920_3t_match_COL_PK_IDX USING BTREE ON vncsim.temp_20230920_3t_match (COL_PK);

-- 공통된 파일명 외의 기타 파일명 확인 후 세 테이블에서 각각 삭제
SELECT count(*)	-- 541	-- DELETE 
FROM url_excel_list_from_20230920 
WHERE COL_PK NOT IN 
	(SELECT COL_PK FROM temp_20230920_3t_match);	

SELECT count(*)	-- 0		-- DELETE 
FROM url_scrap_list_from_20230920 
WHERE FILE_NAME NOT IN 
	(SELECT COL_PK FROM temp_20230920_3t_match);	

SELECT count(DISTINCT FILE_NAME)	-- 0
FROM url_scrap_txt_from_20230920 
WHERE FILE_NAME NOT IN 
	(SELECT COL_PK FROM temp_20230920_3t_match)	


-- 6. 세 개의 테이블 갯수 확인
-- COUNT(*)와 COUNT(DISTINCT FILE_NAME) 개수가 맞아야 함!
-- SELECT COUNT(*)	-- 11510
SELECT "엑셀 T" AS "TABLE", COUNT(*), count(DISTINCT COL_PK)	
FROM url_excel_list_from_20230920 
UNION 
SELECT "파일 T", COUNT(*), count(DISTINCT FILE_NAME)	
FROM url_scrap_list_from_20230920 
UNION 
SELECT "문서 T", COUNT(*), count(distinct FILE_NAME)		
FROM url_scrap_txt_from_20230920 ;
-- TABLE	COUNT(*)	count(DISTINCT COL_PK)
-- 엑셀 T	11,510	11,510
-- 파일 T	11,510	11,510
-- 문서 T	392,038	11,510


-- 7. 납품 테이블과 비교, 존재 URL 제거
-- load_vnc_org_lst_sim과 비교
CREATE TEMPORARY TABLE temp_org_20230920_dupli_url
(
	SELECT COL_PK	-- select count(*) 
	FROM url_excel_list_from_20230920
	WHERE DAT_SRC IN (
								SELECT DAT_SRC
								FROM vnc.load_vnc_org_lst_sim
							)
)

SELECT count(*)		-- DELETE 
FROM url_excel_list_from_20230920
WHERE FILE_NAME IN (SELECT FILE_NAME FROM temp_org_20230920_dupli_url)

SELECT count(*)		-- DELETE 
FROM url_scrap_list_from_20230920
WHERE FILE_NAME IN (SELECT FILE_NAME FROM temp_org_20230920_dupli_url)

SELECT count(*)	
-- SELECT count(DISTINCT FILE_NAME)	-- DELETE 
FROM url_scrap_txt_from_20230920
WHERE FILE_NAME IN (SELECT FILE_NAME FROM temp_org_20230920_dupli_url)


-- 8. 마지막 확인
-- -- 1. 파일명 확인
SELECT *
FROM url_excel_list_from_20230920 
GROUP BY FILE_NAME 
HAVING COUNT(FILE_NAME) > 1

SELECT *
FROM url_scrap_list_from_20230920 
GROUP BY FILE_NAME 
HAVING COUNT(FILE_NAME) > 1

-- -- 2. URL 확인
SELECT *
FROM url_excel_list_from_20230920 
GROUP BY DAT_SRC  
HAVING COUNT(DAT_SRC) > 1

SELECT *
FROM url_scrap_list_from_20230920 
GROUP BY DAT_SRC 
HAVING COUNT(DAT_SRC) > 1


-- 9. 임시 테이블 삭제
-- DROP TABLE IF EXISTS temp_excel_20230920_dupli_url;
-- DROP TABLE IF EXISTS temp_scrap_list_20230920_dupli_url;
-- DROP TABLE IF EXISTS temp_scrap_txt_20230920_dupli_url;
-- DROP TABLE IF EXISTS temp_20230920_3t_match;
-- DROP TABLE IF EXISTS temp_org_20230920_dupli_url;