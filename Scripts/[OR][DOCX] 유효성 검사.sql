USE vncsim;


-- 1. DAT_SRC 확인
SELECT *
FROM load_vnc_org_lst_sim_20230905
WHERE DAT_SRC NOT LIKE 'http%';


-- 2. TOPIC_KR, TOPIC_VN 설정
SELECT LEFT(FILE_NAME, 2) AS TOPIC_CD
       , TOPIC_KR
       , TOPIC_VN 
       , COUNT(*) AS CNT
       , SUM(COUNT(*)) OVER() AS "SUM"
FROM load_vnc_org_lst_sim_20230905
GROUP BY TOPIC_CD, TOPIC_KR, TOPIC_VN 
-- TOPIC_CD		TOPIC_KR				TOPIC_VN								CNT	SUM
-- 01			사회/정치/일반		XÃ HỘI/CHÍNH TRỊ/THÔNG TIN CHUNG		797	1,389
-- 05			문화/역사/예술		Văn hóa/ lịch sử/ nghệ thuật			592	1,389

UPDATE load_vnc_org_lst_sim_20230905
SET 
    TOPIC_KR = 
        CASE 
            WHEN LEFT(FILE_NAME, 2) = '01' THEN '사회/정치/일반'
            WHEN LEFT(FILE_NAME, 2) = '02' THEN 'IT/과학'
            WHEN LEFT(FILE_NAME, 2) = '03' THEN '지리/자연/국가'
            WHEN LEFT(FILE_NAME, 2) = '04' THEN '건강/의학'
            WHEN LEFT(FILE_NAME, 2) = '05' THEN '문화/역사/예술'
            WHEN LEFT(FILE_NAME, 2) = '06' THEN '경제/산업분야'
            ELSE '관광/생활정보/스포츠'
        END,
    TOPIC_VN = 
        CASE 
            WHEN LEFT(FILE_NAME, 2) = '01' THEN 'Xã hội/Chính trị/Tổng hợp'
            WHEN LEFT(FILE_NAME, 2) = '02' THEN 'CNTT/Khoa học'
            WHEN LEFT(FILE_NAME, 2) = '03' THEN 'Địa lý/Thiên nhiên/Quốc gia'
            WHEN LEFT(FILE_NAME, 2) = '04' THEN 'Sức khỏe/Y học'
            WHEN LEFT(FILE_NAME, 2) = '05' THEN 'Văn hóa/Lịch sử/Nghệ thuật'
            WHEN LEFT(FILE_NAME, 2) = '06' THEN 'Kinh tế/Lĩnh vực công nghiệp'
            ELSE 'Du lịch/Thông tin cuộc sống/Thể thao'
        END;
-- 1389


-- 3. WTR_KR, WTR_VN, CTR_KR , CTR_VN 설정
SELECT trim(substring_index(DAT_SRC, '/', 3)), WTR_KR , WTR_VN , CTR_KR , CTR_VN, COUNT(*)
FROM load_vnc_org_lst_sim_20230905
GROUP BY trim(substring_index(DAT_SRC, '/', 3)), WTR_KR, WTR_VN, CTR_KR , CTR_VN;
-- https://doanhnhantrevietnam.vn
-- https://tuoitre.vn
-- https://vanhoavaphattrien.vn

UPDATE load_vnc_org_lst_sim_20230905
SET WTR_KR = 
		CASE 
			WHEN trim(substring_index(DAT_SRC, '/', 3)) = 'http://dosm.gov.vn' THEN '베트남 측정, 지도 및 지리 정보부 - 자원환경부'
			WHEN trim(substring_index(DAT_SRC, '/', 3)) = 'https://baotintuc.vn' THEN '베트남통신사'
			WHEN trim(substring_index(DAT_SRC, '/', 3)) = 'https://kinhtedothi.vn' THEN '마이아잉'
			WHEN trim(substring_index(DAT_SRC, '/', 3)) = 'http://kinhtetrunguong.vn' THEN '중앙경제위원회'
			WHEN trim(substring_index(DAT_SRC, '/', 3)) = 'https://kinhtemoitruong.vn' THEN '환경경제'
			WHEN trim(substring_index(DAT_SRC, '/', 3)) = 'http://vietlao.vietnam.vn' THEN '베트남라오스'
			WHEN trim(substring_index(DAT_SRC, '/', 3)) = 'http://www.gioivan.net' THEN '문학을 잘함'
			WHEN trim(substring_index(DAT_SRC, '/', 3)) = 'https://bientap.vbpl.vn' THEN '법률 문서'
			WHEN trim(substring_index(DAT_SRC, '/', 3)) = 'https://bvhttdl.gov.vn' THEN '문화체육관광부'
			WHEN trim(substring_index(DAT_SRC, '/', 3)) = 'https://cotich.net' THEN '베트남 동화'
			WHEN trim(substring_index(DAT_SRC, '/', 3)) = 'https://doanhnhantrevietnam.vn' THEN '요안냔째신문'
			WHEN trim(substring_index(DAT_SRC, '/', 3)) = 'https://moh.gov.vn' THEN '보건부'
			WHEN trim(substring_index(DAT_SRC, '/', 3)) = 'https://www.moh.gov.vn' THEN '보건부'
			WHEN trim(substring_index(DAT_SRC, '/', 3)) = 'https://moit.gov.vn' THEN '산업통상부'
			WHEN trim(substring_index(DAT_SRC, '/', 3)) = 'https://nghiencuulichsu.com' THEN '역사 연구'
			WHEN trim(substring_index(DAT_SRC, '/', 3)) = 'https://tapchicongthuong.vn' THEN '꽁트엉 산업 및 무역 잡지'
			WHEN trim(substring_index(DAT_SRC, '/', 3)) = 'https://truyencotich.vn' THEN '베트남 동화'
			WHEN trim(substring_index(DAT_SRC, '/', 3)) = 'https://tuoitre.vn' THEN '베트남 뚜오이째 신문사'
			WHEN trim(substring_index(DAT_SRC, '/', 3)) = 'https://www.mard.gov.vn' THEN '농업 및 농촌 개발부'
			WHEN trim(substring_index(DAT_SRC, '/', 3)) = 'https://www.most.gov.vn' THEN '과학기술부'
			WHEN trim(substring_index(DAT_SRC, '/', 3)) = 'https://www.mpi.gov.vn' THEN '계획투자부'
			WHEN trim(substring_index(DAT_SRC, '/', 3)) = 'https://suckhoedoisong.vn' THEN '건강 및 생활 신문'
			WHEN trim(substring_index(DAT_SRC, '/', 3)) = 'https://vietnamnet.vn' THEN '베트남넷 신문'
			WHEN trim(substring_index(DAT_SRC, '/', 3)) = 'https://tdtt.gov.vn' THEN '체육국'
			WHEN trim(substring_index(DAT_SRC, '/', 3)) = 'https://vietnamtourism.gov.vn' THEN '베트남 관광청 신문'
			WHEN trim(substring_index(DAT_SRC, '/', 3)) = 'https://thethaovanhoa.vn' THEN '스포츠 및 문화'
			WHEN trim(substring_index(DAT_SRC, '/', 3)) = 'https://truyen.tangthuvien.vn' THEN '도서관.Vn'
			WHEN trim(substring_index(DAT_SRC, '/', 3)) = 'https://thethaovietnamplus.vn' THEN '베트남 스포츠 플러스'
			WHEN trim(substring_index(DAT_SRC, '/', 3)) = 'https://vanhoavaphattrien.vn' THEN '문화&개발신문'
			ELSE WTR_KR
		END,
	WTR_VN = 
		CASE 
			WHEN trim(substring_index(DAT_SRC, '/', 3)) = 'http://dosm.gov.vn' THEN 'CỤC ĐO ĐẠC, BẢN ĐỒ VÀ THÔNG TIN ĐỊA LÝ VIỆT NAM - BỘ TÀI NGUYÊN VÀ MÔI TRƯỜNG'
			WHEN trim(substring_index(DAT_SRC, '/', 3)) = 'https://baotintuc.vn' THEN 'TIN TỨC'
			WHEN trim(substring_index(DAT_SRC, '/', 3)) = 'https://kinhtedothi.vn' THEN 'MAI ANH'
			WHEN trim(substring_index(DAT_SRC, '/', 3)) = 'http://kinhtetrunguong.vn' THEN 'BAN KINH TẾ TRUNG ƯƠNG'
			WHEN trim(substring_index(DAT_SRC, '/', 3)) = 'https://kinhtemoitruong.vn' THEN 'KINH TẾ MÔI TRƯỜNG'
			WHEN trim(substring_index(DAT_SRC, '/', 3)) = 'http://vietlao.vietnam.vn' THEN 'VIỆT LÀO'
			WHEN trim(substring_index(DAT_SRC, '/', 3)) = 'http://www.gioivan.net' THEN 'GIỎI VĂN'
			WHEN trim(substring_index(DAT_SRC, '/', 3)) = 'https://bientap.vbpl.vn' THEN 'VĂN BẢN PHÁP QUY'
			WHEN trim(substring_index(DAT_SRC, '/', 3)) = 'https://bvhttdl.gov.vn' THEN 'BỘ VĂN HÓA, THỂ THAO VÀ DU LỊCH'
			WHEN trim(substring_index(DAT_SRC, '/', 3)) = 'https://cotich.net' THEN 'TRUYỆN CỔ TÍCH'
			WHEN trim(substring_index(DAT_SRC, '/', 3)) = 'https://doanhnhantrevietnam.vn' THEN 'DOANH NHÂN TRẺ VIỆT NAM'
			WHEN trim(substring_index(DAT_SRC, '/', 3)) = 'https://moh.gov.vn' THEN 'BỘ Y TẾ'
			WHEN trim(substring_index(DAT_SRC, '/', 3)) = 'https://www.moh.gov.vn' THEN 'BỘ Y TẾ'
			WHEN trim(substring_index(DAT_SRC, '/', 3)) = 'https://moit.gov.vn' THEN 'BỘ CÔNG THƯƠNG'
			WHEN trim(substring_index(DAT_SRC, '/', 3)) = 'https://nghiencuulichsu.com' THEN 'NGHIÊN CỨU LỊCH SỬ'
			WHEN trim(substring_index(DAT_SRC, '/', 3)) = 'https://tapchicongthuong.vn' THEN 'TẠP CHÍ CÔNG THƯƠNG'
			WHEN trim(substring_index(DAT_SRC, '/', 3)) = 'https://truyencotich.vn' THEN 'TRUYỆN CỔ TÍCH'
			WHEN trim(substring_index(DAT_SRC, '/', 3)) = 'https://tuoitre.vn' THEN 'TUỔI TRẺ'
			WHEN trim(substring_index(DAT_SRC, '/', 3)) = 'https://www.mard.gov.vn' THEN 'BỘ NÔNG NGHIỆP VÀ PHÁT TRIỂN NÔNG THÔN'
			WHEN trim(substring_index(DAT_SRC, '/', 3)) = 'https://www.most.gov.vn' THEN 'BỘ KHOA HỌC VÀ CÔNG NGHỆ'
			WHEN trim(substring_index(DAT_SRC, '/', 3)) = 'https://www.mpi.gov.vn' THEN 'BỘ KẾ HOẠCH VÀ ĐẦU TƯ'
			WHEN trim(substring_index(DAT_SRC, '/', 3)) = 'https://suckhoedoisong.vn' THEN 'SỨC KHỎE &  ĐỜI SỐNG'
			WHEN trim(substring_index(DAT_SRC, '/', 3)) = 'https://vietnamnet.vn' THEN '베트남넷 신문'
			WHEN trim(substring_index(DAT_SRC, '/', 3)) = 'https://tdtt.gov.vn' THEN 'CỤC THỂ DỤC THỂ THAO'
			WHEN trim(substring_index(DAT_SRC, '/', 3)) = 'https://vietnamtourism.gov.vn' THEN 'BÁO TỔNG CỤC DU LỊCH VIỆT NAM'
			WHEN trim(substring_index(DAT_SRC, '/', 3)) = 'https://thethaovanhoa.vn' THEN 'THỂ THAO & VĂN HÓA'
			WHEN trim(substring_index(DAT_SRC, '/', 3)) = 'https://truyen.tangthuvien.vn' THEN 'truyen.tangthuvien.Vn'
			WHEN trim(substring_index(DAT_SRC, '/', 3)) = 'https://thethaovietnamplus.vn' THEN 'THỂ THAO VIỆT NAM PLUS'
			WHEN trim(substring_index(DAT_SRC, '/', 3)) = 'https://vanhoavaphattrien.vn' THEN 'TAP CHI VAN HOA & PHAT TRIEN'
			ELSE WTR_VN
		END,
	CTR_KR = WTR_KR,
	CTR_VN = WTR_VN;

-- 확인
SELECT trim(substring_index(DAT_SRC, '/', 3)), WTR_KR , WTR_VN , CTR_KR , CTR_VN, COUNT(*)
FROM load_vnc_org_lst_sim_20230905
GROUP BY trim(substring_index(DAT_SRC, '/', 3)), WTR_KR, WTR_VN, CTR_KR , CTR_VN;


-- 4. WORKER_ID 확인
SELECT *
FROM load_vnc_org_lst_sim_20230905
WHERE WORKER_ID <> MID(FILE_NAME, 4, 5);

SELECT *
FROM load_vnc_file_list_sim_20230905
WHERE WORKER_ID <> MID(FILE_NAME, 4, 5);


-- 5. JOB_YMD 확인
SELECT max(JOB_YMD), min(JOB_YMD)
FROM load_vnc_org_lst_sim_20230905;

SELECT max(WORKYMD), min(WORKYMD)
FROM load_vnc_file_list_sim_20230905;


-- 6. PUB_YMD 확인
-- -- 1. YYYYMMDD 형식 확인
SELECT *
FROM load_vnc_org_lst_sim_20230905
WHERE PUB_YMD NOT REGEXP '^(1[0-9]|20)(\\d{2})(0[1-9]|1[0-2])(0[1-9]|[12]\\d{1}|3[01])' 

-- -- 2. 길이
SELECT length(PUB_YMD)
FROM load_vnc_org_lst_sim_20230905
GROUP BY length(PUB_YMD)

SELECT *
FROM load_vnc_org_lst_sim_20230905
WHERE LENGTH(PUB_YMD) = 9;

SELECT PUB_YMD, CONCAT(LEFT(PUB_YMD, 6), RIGHT(PUB_YMD, 2))
FROM load_vnc_org_lst_sim_20230905	-- UPDATE load_vnc_org_lst_sim_20230905 SET PUB_YMD = CONCAT(LEFT(PUB_YMD, 6), RIGHT(PUB_YMD, 2))
WHERE LENGTH(PUB_YMD) = 9;

-- -- 3. 월별 최소/최대일 확인
SELECT left(PUB_YMD, 4) "년도별", mid(PUB_YMD, 5, 2) "월별", min(right(PUB_YMD, 2)) "최소일", max(RIGHT(PUB_YMD, 2)) "최대일"
FROM load_vnc_org_lst_sim_20230905
GROUP BY left(PUB_YMD, 4), mid(PUB_YMD, 5, 2)

-- -- 4. 짝수 달의 최대 일이 31일 있는지 확인
SELECT *
FROM load_vnc_org_lst_sim_20230905 uelf
WHERE mid(PUB_YMD, 5, 2) IN ('04', '06', '09', '11')
AND RIGHT(PUB_YMD, 2) = '31'

-- -- 5. 2월의 최대 날짜 확인(윤년 확인)
SELECT left(PUB_YMD, 4) "년도별", mid(PUB_YMD, 5, 2) "월별", min(right(PUB_YMD, 2)) "최소일", max(RIGHT(PUB_YMD, 2)) "최대일"
FROM load_vnc_org_lst_sim_20230905
WHERE mid(PUB_YMD, 5, 2) = '02'
GROUP BY left(PUB_YMD, 4), mid(PUB_YMD, 5, 2)


-- 7. 이외 모든 값이 들어있는지 확인
-- COALESCE() : 열을 순차적으로 확인, 첫 번째로 NULL이 아닌 값 반환
-- -> COALESCE() IS NULL : 하나라도 NULL이면 NULL 반환
SELECT *
FROM load_vnc_org_lst_sim_20230905
WHERE COALESCE(SEQ, ORG_TYP, DAT_TYP, TITLE, DOC_STYLE) IS NULL
OR ORG_TYP IN ('nan', '')
OR DAT_TYP IN ('nan', '')
OR TITLE IN ('nan', '')
OR DOC_STYLE IN ('nan', '');

SELECT *	-- SELECT count(*)	-- DELETE 
FROM load_vnc_file_list_sim_20230905
WHERE COALESCE(WORKCNT, FILE_SIZE, FILE_CREATETIME, FILE_CHANG_TIME, WORD_COUNT) IS NULL 
OR WORKCNT = 0
OR WORD_COUNT = 0;

SELECT *
FROM load_vnc_file_docx_sim_20230905
WHERE seq IS NULL 
OR FILE_TXT IS NULL
OR SEQ = 0
OR FILE_TXT = '';


-- 8. 문서 테이블, 실제 파일 행 개수와 최대 seq 비교
SELECT FILE_NAME , count(FILE_NAME), max(SEQ)
FROM load_vnc_file_docx_sim_20230905
GROUP BY FILE_NAME 
HAVING count(FILE_NAME) <> max(SEQ);

SELECT *
FROM load_vnc_file_docx_sim_20230905
GROUP BY FILE_NAME 
HAVING count(FILE_NAME) < 2;


-- 9. 문서 테이블, 행이 하나 & 4000 미만 삭제(3T)
SELECT COUNT(*)	-- DELETE a
-- FROM load_vnc_org_lst_sim_20230905 a		 
FROM load_vnc_file_list_sim_20230905 a		
JOIN (
			SELECT FILE_NAME, SUM(LENGTH(FILE_TXT))	-- 0	
			FROM load_vnc_file_docx_sim_20230905
			GROUP BY FILE_NAME 
			HAVING count(FILE_NAME) < 2 
			AND SUM(LENGTH(FILE_TXT)) < 4000
		) b
ON a.FILE_NAME = b.FILE_NAME

SELECT count(*)	-- DELETE 
FROM load_vnc_file_docx_sim_20230905
WHERE FILE_NAME NOT IN (SELECT COL_PK FROM load_vnc_org_lst_sim_20230905)

SELECT COUNT(*), COUNT(DISTINCT FILE_NAME)
-- FROM load_vnc_org_lst_sim_20230905 a		
-- FROM load_vnc_file_list_sim_20230905 a		
FROM load_vnc_file_docx_sim_20230905	
