USE vncsim;

START TRANSACTION;

-- 1. Fax
-- -- 1. 조회
SELECT IDX, DAT_TXT
	, sum(CASE WHEN 1 THEN 1 END) OVER() AS "SUM"	
FROM url_scrap_txt_from_20230920  
-- WHERE DAT_TXT REGEXP 'Fax';	-- 16
WHERE DAT_TXT REGEXP 'Fax[:]?[[:blank:]]*[0-9]+';	-- 12

/* 양식 
	Fax 04.62732207
	Fax: 024.62732027
	Fax: 0243 942 4285	
*/

-- -- 2. REGEXP 확인
SELECT IDX, DAT_TXT
	, CASE 
			WHEN DAT_TXT REGEXP 'Fax[:]?[[:blank:]]*[0-9]+[\\.][0-9]+' THEN REGEXP_REPLACE(DAT_TXT, '(Fax[:]?[[:blank:]]*)([0-9]+)([\\.])([0-9]+)', '\\1***\\3********')
			WHEN DAT_TXT REGEXP 'Fax[:]?[[:blank:]]*[0-9]+([[:blank:]][0-9]+)+' THEN REGEXP_REPLACE(DAT_TXT, '(Fax[:]?[[:blank:]]*)([0-9]+)([[:blank:]][0-9]+)+', '\\1**** *** ****')
			ELSE DAT_TXT 
		END AS "ANONYM_TXT"
	, sum(CASE WHEN 1 THEN 1 END) OVER() AS "SUM"	
FROM url_scrap_txt_from_20230920  
WHERE DAT_TXT REGEXP 'Fax[:]?[[:blank:]]*[0-9]+';	-- 12

-- -- 3. UPDATE
SAVEPOINT s1_3;

UPDATE url_scrap_txt_from_20230920
SET DAT_TXT = 
			CASE 
				WHEN DAT_TXT REGEXP 'Fax[:]?[[:blank:]]*[0-9]+[\\.][0-9]+' THEN REGEXP_REPLACE(DAT_TXT, '(Fax[:]?[[:blank:]]*)([0-9]+)([\\.])([0-9]+)', '\\1***\\3********')
				WHEN DAT_TXT REGEXP 'Fax[:]?[[:blank:]]*[0-9]+([[:blank:]][0-9]+)+' THEN REGEXP_REPLACE(DAT_TXT, '(Fax[:]?[[:blank:]]*)([0-9]+)([[:blank:]][0-9]+)+', '\\1**** *** ****')
				ELSE DAT_TXT 
			END 
WHERE DAT_TXT REGEXP 'Fax[:]?[[:blank:]]*[0-9]+';	-- 12

-- -- 4. Fax 확인
SELECT IDX, DAT_TXT
	, sum(CASE WHEN 1 THEN 1 END) OVER() AS "SUM"	
FROM url_scrap_txt_from_20230920  
WHERE DAT_TXT REGEXP 'Fax'												-- Fax이고
AND DAT_TXT REGEXP 'Fax[:]?[[:blank:]]*[0-9]+'					-- Fax뒤에 숫자가 오는데
AND DAT_TXT NOT REGEXP 'Fax[:]?[[:blank:]]*[\\*]+';			-- 비식별화가 안된..


-- 2. Hotline 
-- -- 1. 조회
SELECT IDX, DAT_TXT
	, sum(CASE WHEN 1 THEN 1 END) OVER() AS "SUM"	
FROM url_scrap_txt_from_20230920  
-- WHERE DAT_TXT REGEXP 'Hotline';	-- 101
WHERE DAT_TXT REGEXP 'Hotline[:]?[[:blank:]]*[0-9]+';		-- 74

/* 양식
	hotline 1900888988		1
	hotline 1800 6601			2
	Hotline 091 500 1796		2
	Hotline: 024 23479797	2
	hotline 0243.8461530		3
	hotline 084.342.8888		3
	Hotline: 08.65.56.08		3
	Hotline: 0979043610 - 1900232325				1
	Hotline: 024.6292.6956 – 086.958.7725		3
	Hotline: 0789.05.99.88 – 024. 2240 9025	3
	hotline: 19009095 hoặc 0961434288			1
	Hotline: 0243.39440285/ 0975126566			3
	hotline: 0988558245-0989135802				1
*/

-- -- 2. REGEXP 확인
SELECT IDX , DAT_TXT
	, CASE 
			WHEN DAT_TXT REGEXP 'Hotline[:]?[[:blank:]]*[0-9]{6,}' THEN REGEXP_REPLACE(DAT_TXT, '(Hotline[:]?[[:blank:]]*)([0-9]{6,})', '\\1********')
			WHEN DAT_TXT REGEXP 'Hotline[:]?[[:blank:]]*[0-9]+([[:blank:]][0-9]+)+' THEN REGEXP_REPLACE(DAT_TXT, '(Hotline[:]?[[:blank:]]*)([0-9]+)([[:blank:]][0-9]+)+', '\\1*** *** ****')
			WHEN DAT_TXT REGEXP 'Hotline[:]?[[:blank:]]*[0-9]+(\\.[0-9]+)+' THEN REGEXP_REPLACE(DAT_TXT, '(Hotline[:]?[[:blank:]]*)([0-9]+)(\\.[0-9]+)+', '\\1***.***.****')
			ELSE DAT_TXT 
		END AS "ANONYM_TXT"
	, sum(CASE WHEN 1 THEN 1 END) OVER() AS "SUM"	
FROM url_scrap_txt_from_20230920  
WHERE DAT_TXT REGEXP 'Hotline[:]?[[:blank:]]*[0-9]+';		

-- -- 3. UPDATE
SAVEPOINT s2_3;

UPDATE url_scrap_txt_from_20230920
SET DAT_TXT = 
		CASE 
			WHEN DAT_TXT REGEXP 'Hotline[:]?[[:blank:]]*[0-9]{6,}' THEN REGEXP_REPLACE(DAT_TXT, '(Hotline[:]?[[:blank:]]*)([0-9]{6,})', '\\1********')
			WHEN DAT_TXT REGEXP 'Hotline[:]?[[:blank:]]*[0-9]+([[:blank:]][0-9]+)+' THEN REGEXP_REPLACE(DAT_TXT, '(Hotline[:]?[[:blank:]]*)([0-9]+)([[:blank:]][0-9]+)+', '\\1*** *** ****')
			WHEN DAT_TXT REGEXP 'Hotline[:]?[[:blank:]]*[0-9]+(\\.[0-9]+)+' THEN REGEXP_REPLACE(DAT_TXT, '(Hotline[:]?[[:blank:]]*)([0-9]+)(\\.[0-9]+)+', '\\1***.***.****')
			ELSE DAT_TXT 
		END
WHERE DAT_TXT REGEXP 'Hotline[:]?[[:blank:]]*[0-9]+';	
-- 74

-- -- 4. Hotline 재조회
/* Hotline 뒤에 비식별화가 되었지만 -, hoặc, /가 있는 경우(010.0000.0000 - 010.0000.0002)
* Hotline: ******** - 1900232325					1
* Hotline: ***.***.**** – 086.958.7725			3
* Hotline: ***.***.**** – 024. 2240 9025		3
* hotline: ******** hoặc 0961434288				1
* Hotline: ***.***.**** / 0975126566			3
* hotline: ********-0989135802					1 */
SELECT IDX, DAT_TXT
	, REGEXP_REPLACE(DAT_TXT, '(Hotline[:]?[[:blank:]]*)([\\*]{1,})([[:blank:]|\\.][\\*]+)*([[:blank:]]*(\\-|hoặc|/)[[:blank:]]*)([0-9\\.[:blank:]]+)', '\\1\\2\\3\\4********')
			AS "ANONYM_TXT"
	, sum(CASE WHEN 1 THEN 1 END) OVER() AS "SUM"	-- 7
FROM url_scrap_txt_from_20230920  
WHERE DAT_TXT REGEXP 'Hotline[:]?[[:blank:]]*[\\*]{1,}([[:blank:]|\\.][\\*]+)*[[:blank:]]*(-|hoặc|/)[[:blank:]]*[0-9]+'		

-- -- 5. 4번 UPDATE
SAVEPOINT s2_5;

UPDATE url_scrap_txt_from_20230920
SET DAT_TXT = REGEXP_REPLACE(DAT_TXT, '(Hotline[:]?[[:blank:]]*)([\\*]{1,})([[:blank:]|\\.][\\*]+)*([[:blank:]]*(\\-|hoặc|/)[[:blank:]]*)([0-9\\.[:blank:]]+)', '\\1\\2\\3\\4********')
WHERE DAT_TXT REGEXP 'Hotline[:]?[[:blank:]]*[\\*]{1,}([[:blank:]|\\.][\\*]+)*[[:blank:]]*(-|hoặc|/)[[:blank:]]*[0-9]+';

-- -- 6. Hotline 확인
SELECT IDX, DAT_TXT
	, sum(CASE WHEN 1 THEN 1 END) OVER() AS "SUM"	
FROM url_scrap_txt_from_20230920  												
WHERE DAT_TXT REGEXP 'Hotline[:]?[[:blank:]]*[0-9]+'				-- Hotline 뒤에 숫자가 오는데
AND DAT_TXT NOT REGEXP 'Hotline[:]?[[:blank:]]*[\\*]+';			-- 비식별화가 안된..
-- X


-- 3. Điện thoại
-- -- 1. 조회
SELECT IDX, DAT_TXT
	, sum(CASE WHEN 1 THEN 1 END) OVER() AS "SUM"	
FROM url_scrap_txt_from_20230920
-- WHERE DAT_TXT REGEXP 'Điện thoại';	-- 883
WHERE DAT_TXT REGEXP 'Điện thoại[:]?[[:blank:]]*[0-9]+'	-- 63

/* 양식
 * Điện thoại: 18001700										-- 1
 * điện thoại: 0462 628 628								-- 2
 * điện thoại: 024.38456255								-- 3
 * điện thoại 0989.133.999									-- 3
 * điện thoại: (04) 3629 1207
 * 
 * điện thoại: 024.3935.1071, 0979.820.162,			-- 3
 * Điện thoại: 0975569056 - 097548363					-- 1
 * điện thoại:024 3821 4954 - 024 3997 4964			-- 2
 * Điện thoại: 024.38461530 – 028.62647169			-- 3
 * điện thoại: 0989671115 hoặc 0963851919				-- 1
 * điện thoại 05113 509 808 hoặc 05113 652 883		-- 2
 * điện thoại 028.39309967 hoặc 0907.574.269			-- 3
 * điện thoại 02133.876.867; 0975.099.487				-- 3
 * điện thoại 024.62732027; 0912792579; 0913085959 -- 3 */

-- -- 2. REGEXP 확인
SELECT IDX , DAT_TXT
	, CASE 
			WHEN DAT_TXT REGEXP 'Điện thoại[:]?[[:blank:]]*[0-9]{6,}' THEN REGEXP_REPLACE(DAT_TXT, '(Điện thoại[:]?[[:blank:]]*)([0-9]{6,})', '\\1********')
			WHEN DAT_TXT REGEXP 'Điện thoại[:]?[[:blank:]]*[0-9]+([[:blank:]][0-9]+)+' THEN REGEXP_REPLACE(DAT_TXT, '(Điện thoại[:]?[[:blank:]]*)([0-9]+)([[:blank:]][0-9]+)+', '\\1*** *** ****')
			WHEN DAT_TXT REGEXP 'Điện thoại[:]?[[:blank:]]*[0-9]+(\\.[0-9]+)+' THEN REGEXP_REPLACE(DAT_TXT, '(Điện thoại[:]?[[:blank:]]*)([0-9]+)(\\.[0-9]+)+', '\\1***.***.****')
			ELSE DAT_TXT 
		END AS "ANONYM_TXT"
	, sum(CASE WHEN 1 THEN 1 END) OVER() AS "SUM"	
FROM url_scrap_txt_from_20230920  
WHERE DAT_TXT REGEXP 'Điện thoại[:]?[[:blank:]]*[0-9]+';	

-- -- 3. UPDATE
SAVEPOINT s3_3;

UPDATE url_scrap_txt_from_20230920
SET DAT_TXT = 
	CASE 
		WHEN DAT_TXT REGEXP 'Điện thoại[:]?[[:blank:]]*[0-9]{6,}' THEN REGEXP_REPLACE(DAT_TXT, '(Điện thoại[:]?[[:blank:]]*)([0-9]{6,})', '\\1********')
		WHEN DAT_TXT REGEXP 'Điện thoại[:]?[[:blank:]]*[0-9]+([[:blank:]][0-9]+)+' THEN REGEXP_REPLACE(DAT_TXT, '(Điện thoại[:]?[[:blank:]]*)([0-9]+)([[:blank:]][0-9]+)+', '\\1*** *** ****')
		WHEN DAT_TXT REGEXP 'Điện thoại[:]?[[:blank:]]*[0-9]+(\\.[0-9]+)+' THEN REGEXP_REPLACE(DAT_TXT, '(Điện thoại[:]?[[:blank:]]*)([0-9]+)(\\.[0-9]+)+', '\\1***.***.****')
		ELSE DAT_TXT 
	END 
WHERE DAT_TXT REGEXP 'Điện thoại[:]?[[:blank:]]*[0-9]+';
-- 63

-- -- 4.  Điện thoại 재조회
/* Điện thoại 뒤에 비식별화가 되었지만 -, hoặc, ;, ','가 있는 경우(010.0000.0000 - 010.0000.0002)
 * 뒤의 연락처를 ********로 수기 변경.
 * điện thoại: ***.***.****, 0979.820.162,			
 * Điện thoại: ******** - 097548363						
 * điện thoại:*** *** **** - 024 3997 4964			 
 * Điện thoại: ***.***.**** – 028.62647169			 
 * điện thoại: ******** hoặc 0963851919				 
 * điện thoại *** *** **** hoặc 05113 652 883		 
 * điện thoại ***.***.**** hoặc 0907.574.269			 
 * điện thoại ***.***.****; 0975.099.487				 
 * điện thoại ***.***.****; 0912792579; 0913085959  
 */
SELECT IDX, DAT_TXT
	, sum(CASE WHEN 1 THEN 1 END) OVER() AS "SUM"	-- 10
FROM url_scrap_txt_from_20230920  
WHERE DAT_TXT REGEXP 'Điện thoại[:]?[[:blank:]]*[\\*]{1,}([[:blank:]|\\.][\\*]+)*[[:blank:]]*(-|hoặc|;|,)[[:blank:]]*[0-9]+';

-- -- 5. Điện thoại 확인
SELECT IDX, DAT_TXT
	, sum(CASE WHEN 1 THEN 1 END) OVER() AS "SUM"	
FROM url_scrap_txt_from_20230920  												
WHERE DAT_TXT REGEXP 'Điện thoại[:]?[[:blank:]]*[0-9]+'				-- Điện thoại 뒤에 숫자가 오는데
AND DAT_TXT NOT REGEXP 'Điện thoại[:]?[[:blank:]]*[\\*]+';			-- 비식별화가 안된..
-- 4 >> 확인완료.


-- 4. Zalo(Diện thoại와 양식 동일)
SELECT IDX, DAT_TXT
	, sum(CASE WHEN 1 THEN 1 END) OVER() AS "SUM"	
FROM url_scrap_txt_from_20230920
-- WHERE DAT_TXT REGEXP 'Zalo';	-- 63
WHERE DAT_TXT REGEXP 'Zalo[:]?[[:blank:]]*[0-9]+'	
OR DAT_TXT REGEXP 'Zalo là[[:blank:]]*[0-9]+'	-- 2


-- 5. SĐT  전화번호
-- -- 1. 조회
SELECT IDX, DAT_TXT
	, sum(CASE WHEN 1 THEN 1 END) OVER() AS "SUM"	
FROM url_scrap_txt_from_20230920
-- WHERE DAT_TXT REGEXP 'S?ĐT';	-- 942
WHERE DAT_TXT REGEXP 'S?ĐT[:]?[[:blank:]]*[0-9]+'	-- 18(대상)

/* 양식
 * ĐT: 38558532		-- 1
 * SĐT: 0798 531 853 -- 2
 * ĐT: 024.62732027	-- 3
 * SĐT: 0243.768.0014 / 0243.993.6118	-- 3
*/

-- -- 2. REGEXP
SELECT IDX , DAT_TXT
	, CASE 
			WHEN DAT_TXT REGEXP 'S?ĐT[:]?[[:blank:]]*[0-9]{6,}' THEN REGEXP_REPLACE(DAT_TXT, '(S?ĐT[:]?[[:blank:]]*)([0-9]{6,})', '\\1********')
			WHEN DAT_TXT REGEXP 'S?ĐT[:]?[[:blank:]]*[0-9]+([[:blank:]][0-9]+)+' THEN REGEXP_REPLACE(DAT_TXT, '(S?ĐT[:]?[[:blank:]]*)([0-9]+)([[:blank:]][0-9]+)+', '\\1*** *** ****')
			WHEN DAT_TXT REGEXP 'S?ĐT[:]?[[:blank:]]*[0-9]+(\\.[0-9]+)+' THEN REGEXP_REPLACE(DAT_TXT, '(S?ĐT[:]?[[:blank:]]*)([0-9]+)(\\.[0-9]+)+', '\\1***.***.****')
			ELSE DAT_TXT 
		END AS "ANONYM_TXT"
	, sum(CASE WHEN 1 THEN 1 END) OVER() AS "SUM"	
FROM url_scrap_txt_from_20230920  
WHERE DAT_TXT REGEXP 'S?ĐT[:]?[[:blank:]]*[0-9]+';		

-- -- 3. UPDATE 
SAVEPOINT s5_3;

UPDATE url_scrap_txt_from_20230920
SET DAT_TXT = 
	CASE 
		WHEN DAT_TXT REGEXP 'S?ĐT[:]?[[:blank:]]*[0-9]{6,}' THEN REGEXP_REPLACE(DAT_TXT, '(S?ĐT[:]?[[:blank:]]*)([0-9]{6,})', '\\1********')
		WHEN DAT_TXT REGEXP 'S?ĐT[:]?[[:blank:]]*[0-9]+([[:blank:]][0-9]+)+' THEN REGEXP_REPLACE(DAT_TXT, '(S?ĐT[:]?[[:blank:]]*)([0-9]+)([[:blank:]][0-9]+)+', '\\1*** *** ****')
		WHEN DAT_TXT REGEXP 'S?ĐT[:]?[[:blank:]]*[0-9]+(\\.[0-9]+)+' THEN REGEXP_REPLACE(DAT_TXT, '(S?ĐT[:]?[[:blank:]]*)([0-9]+)(\\.[0-9]+)+', '\\1***.***.****')
		ELSE DAT_TXT 
	END
WHERE DAT_TXT REGEXP 'S?ĐT[:]?[[:blank:]]*[0-9]+';	

-- -- 4. 재조회
-- SĐT: ***.***.**** / 0243.993.6118 -> ***.***.**** / ********
SELECT IDX, DAT_TXT
	, REGEXP_REPLACE(DAT_TXT, '(S?ĐT[:]?[[:blank:]]*)([\\*]{1,})([[:blank:]|\\.][\\*]+)*([[:blank:]]*(\\-|hoặc|/)[[:blank:]]*)([0-9\\.[:blank:]]+)', '\\1\\2\\3\\4********')
			AS "ANONYM_TXT"
	, sum(CASE WHEN 1 THEN 1 END) OVER() AS "SUM"	-- 1
FROM url_scrap_txt_from_20230920  
WHERE DAT_TXT REGEXP 'S?ĐT[:]?[[:blank:]]*[\\*]{1,}([[:blank:]|\\.][\\*]+)*[[:blank:]]*(-|hoặc|/)[[:blank:]]*[0-9]+'		

-- -- 5. 4번 UPDATE
SAVEPOINT s5_5;

UPDATE url_scrap_txt_from_20230920
SET DAT_TXT = REGEXP_REPLACE(DAT_TXT, '(S?ĐT[:]?[[:blank:]]*)([\\*]{1,})([[:blank:]|\\.][\\*]+)*([[:blank:]]*(\\-|hoặc|/)[[:blank:]]*)([0-9\\.[:blank:]]+)', '\\1\\2\\3\\4********')
WHERE DAT_TXT REGEXP 'S?ĐT[:]?[[:blank:]]*[\\*]{1,}([[:blank:]|\\.][\\*]+)*[[:blank:]]*(-|hoặc|/)[[:blank:]]*[0-9]+';

-- -- 6. S?ĐT 확인
SELECT IDX, DAT_TXT
	, sum(CASE WHEN 1 THEN 1 END) OVER() AS "SUM"	
FROM url_scrap_txt_from_20230920  												
WHERE DAT_TXT REGEXP 'S?ĐT[:]?[[:blank:]]*[0-9]+'				-- S?ĐT 뒤에 숫자가 오는데
AND DAT_TXT NOT REGEXP 'S?ĐT[:]?[[:blank:]]*[\\*]+';			-- 비식별화가 안된..
-- 3 확인완료.


-- 6. Email
-- -- 1. 조회
SELECT IDX, DAT_TXT
	, sum(CASE WHEN 1 THEN 1 END) OVER() AS "SUM"	
FROM url_scrap_txt_from_20230920
-- WHERE DAT_TXT REGEXP 'Email';	-- 80
-- WHERE DAT_TXT REGEXP 'Email[:]?[[:blank:]]*[[:alnum:]]+@'	-- 44(대상)

/* 양식
 * Email: quyvacxincovid19@vst.gov.vn		
 * Email: tiepnhantinvipham@vfa.gov.vn
 * email: baocaobtn@gmail.com
 * Email: bannghiepvu.hnb@gmail.com 
 */

-- -- 2. REGEXP 
-- 비식별화 양식 : '********@*****.***'
SELECT IDX , DAT_TXT
	, REGEXP_REPLACE(DAT_TXT, '(Email[:]?[[:blank:]]*)(\\.?[[:alnum:]]+)+(@)(\\.?[[:alnum:]]+)+', '\\1********\\3*****.***') 
	, sum(CASE WHEN 1 THEN 1 END) OVER() AS "SUM"
FROM url_scrap_txt_from_20230920  
WHERE DAT_TXT REGEXP 'Email[:]?[[:blank:]]*[[:alnum:]]+@';

-- -- 3. UPDATE
SAVEPOINT s6_3;

UPDATE url_scrap_txt_from_20230920
SET DAT_TXT = REGEXP_REPLACE(DAT_TXT, '(Email[:]?[[:blank:]]*)(\\.?[[:alnum:]]+)+(@)(\\.?[[:alnum:]]+)+', '\\1********\\3*****.***') 
WHERE DAT_TXT REGEXP 'Email[:]?[[:blank:]]*[[:alnum:]]+@';

-- -- 4. 확인
SELECT IDX , DAT_TXT
FROM url_scrap_txt_from_20230920  
WHERE DAT_TXT REGEXP 'Email[:]?[[:blank:]]*[[:alnum:]]+@'	-- Email 뒤에 문자가 오는데
AND DAT_TXT NOT REGEXP 'Email[:]?[[:blank:]]*[\\*]+';			-- 비식별화가 안된..
-- X


-- 7. http
-- -- 1. 조회
SELECT IDX, DAT_TXT
	, sum(CASE WHEN 1 THEN 1 END) OVER() AS "SUM"	
FROM url_scrap_txt_from_20230920
-- WHERE DAT_TXT REGEXP 'http';	-- 340
WHERE DAT_TXT REGEXP 'http[s]?://'	-- 340(대상)

/* 양식
 * https://suachinhhang.morinagamilk.com.vn										1
 * https://www.facebook.com/108535927305178/posts/119207856237985			1
 * https://lopy.com.vn/san-pham/sua-canxi-huu-co-healyn-canxi/		: - /
 * https://nutricare.com.vn/nutricare-colos24h-grow-plus.html		: / - .html
 * https://www.smartbibi.vn/tin-tuc/tet-thieu-nhi-ruc-ro-ngan-qua-tang-hap-dan-tu-tho-xanh/	: www / -
 * https://www.youtube.com/channel/UCJ7ptXFutC92As7H311CuBQ
 * https://www.tiktok.com/@seagames31official

 * -- 파라미터 있는 경우 --
 * https://www.facebook.com/eurhovital.vn?mibextid=ZbWKwL
 * https://www.facebook.com/profile.php?id=100086924900114
 * https://thamquannhamay.ajinomoto.com.vn/?utm_source=Fp_Tuoitre&utm_medium=cpc&utm_campaign=media
 * */

SELECT 'Very long long texts' AS "TXT"
	, SUBSTR('Very long long texts', 3, 4)
	, REGEXP_INSTR('Very long long texts', 'ery') 
	, LOCATE('LONG', 'Very long long texts', 3) 
	, REGEXP_SUBSTR('Very long long texts', '[[:blank:]]')
	, REPLACE('Very long long texts', 'long', 'loooong')
FROM DUAL;
/*	REGEXP_REPLACE()와 REPLACE()의 차이
 * REGEXP_REPLACE(subject, pattern, replace) : 한 subject에서 정규식 pattern에 해당하는 모든 데이터를 replace함. 
 * 	-> pattern이 정규식이므로 추출하는 텍스트로 할 때 텍스트 안에 정규식 표현문자가 있는지 유의해야함. 
 * REPLACE(subject, text, replace_txt) : 한 subject에서 text에 해당하는 모든 데이터를 replace_txt로 replace함.
 * 	-> text는 일반 문자열임.
 * */

-- -- 2. http 뒤에 나오는 첫 빈칸을 기준으로 URL 비식별화
SELECT IDX , DAT_TXT 
	, REGEXP_INSTR(DAT_TXT, 'http[s]?://') "HTTP_LOC"		-- 자를 위치 확인
	, LOCATE(' ', DAT_TXT, REGEXP_INSTR(DAT_TXT, 'http[s]?://')) AS "BLANK_LOC"	-- http 이후로 나오는 첫 ' ' 위치 확인 
	, SUBSTR(DAT_TXT
				, REGEXP_INSTR(DAT_TXT, 'http[s]?://')			-- 자를 위치
				, CASE
						WHEN LOCATE(' ', DAT_TXT, REGEXP_INSTR(DAT_TXT, 'http[s]?://')) <> 0
							THEN LOCATE(' ', DAT_TXT, REGEXP_INSTR(DAT_TXT, 'http[s]?://')) - REGEXP_INSTR(DAT_TXT, 'http[s]?://')
						ELSE CHAR_LENGTH(DAT_TXT)
					END												-- 자를 개수
			) AS "URL_TXT"		-- 비식별화할 URL 확인
	, REPLACE(DAT_TXT
				, SUBSTR(DAT_TXT
							, REGEXP_INSTR(DAT_TXT, 'http[s]?://')
							, CASE
									WHEN LOCATE(' ', DAT_TXT, REGEXP_INSTR(DAT_TXT, 'http[s]?://')) <> 0
										THEN LOCATE(' ', DAT_TXT, REGEXP_INSTR(DAT_TXT, 'http[s]?://')) - REGEXP_INSTR(DAT_TXT, 'http[s]?://')
									ELSE CHAR_LENGTH(DAT_TXT)
								END
							)
				, 'http://***.***.**'
				) AS "REPLACE_TXT"	-- 수정 TXT 확인
	, sum(CASE WHEN 1 THEN 1 END) OVER() AS "SUM"	-- 251
FROM url_scrap_txt_from_20230920
WHERE DAT_TXT REGEXP 'http[s]?://'
AND CASE
		WHEN LOCATE(' ', DAT_TXT, REGEXP_INSTR(DAT_TXT, 'http[s]?://')) <> 0
			THEN LOCATE(' ', DAT_TXT, REGEXP_INSTR(DAT_TXT, 'http[s]?://')) - REGEXP_INSTR(DAT_TXT, 'http[s]?://')
		ELSE CHAR_LENGTH(DAT_TXT)
	END >= 15				-- 예외방지(ex.'http://www /~~')
AND SUBSTR(DAT_TXT
				, REGEXP_INSTR(DAT_TXT, 'http[s]?://')
				, CASE
						WHEN LOCATE(' ', DAT_TXT, REGEXP_INSTR(DAT_TXT, 'http[s]?://')) <> 0
							THEN LOCATE(' ', DAT_TXT, REGEXP_INSTR(DAT_TXT, 'http[s]?://')) - REGEXP_INSTR(DAT_TXT, 'http[s]?://')
						ELSE CHAR_LENGTH(DAT_TXT)
					END
			) NOT REGEXP '[[:upper:]]';	-- 예외방지(URL뒤에 바로 텍스트 오는경우)
		
-- -- 3. UPDATE
SAVEPOINT s7_3;

UPDATE url_scrap_txt_from_20230920
SET DAT_TXT = REPLACE(DAT_TXT
							, SUBSTR(DAT_TXT
										, REGEXP_INSTR(DAT_TXT, 'http[s]?://')
										, CASE
												WHEN LOCATE(' ', DAT_TXT, REGEXP_INSTR(DAT_TXT, 'http[s]?://')) <> 0
													THEN LOCATE(' ', DAT_TXT, REGEXP_INSTR(DAT_TXT, 'http[s]?://')) - REGEXP_INSTR(DAT_TXT, 'http[s]?://')
												ELSE CHAR_LENGTH(DAT_TXT)
											END
										)
							, 'http://***.***.**'
							)
WHERE DAT_TXT REGEXP 'http[s]?://'
AND CASE
		WHEN LOCATE(' ', DAT_TXT, REGEXP_INSTR(DAT_TXT, 'http[s]?://')) <> 0
			THEN LOCATE(' ', DAT_TXT, REGEXP_INSTR(DAT_TXT, 'http[s]?://')) - REGEXP_INSTR(DAT_TXT, 'http[s]?://')
		ELSE CHAR_LENGTH(DAT_TXT)
	END >= 15				-- 예외방지1(ex.'http://www /~~')
AND SUBSTR(DAT_TXT
				, REGEXP_INSTR(DAT_TXT, 'http[s]?://')
				, CASE
						WHEN LOCATE(' ', DAT_TXT, REGEXP_INSTR(DAT_TXT, 'http[s]?://')) <> 0
							THEN LOCATE(' ', DAT_TXT, REGEXP_INSTR(DAT_TXT, 'http[s]?://')) - REGEXP_INSTR(DAT_TXT, 'http[s]?://')
						ELSE CHAR_LENGTH(DAT_TXT)
					END
			) NOT REGEXP '[[:upper:]]';	-- 예외방지2(URL뒤에 바로 텍스트 오는경우)
			
-- -- 4. 예외1 확인
SELECT IDX , DAT_TXT 
	, sum(CASE WHEN 1 THEN 1 END) OVER() AS "SUM"
FROM url_scrap_txt_from_20230920
WHERE DAT_TXT REGEXP 'http[s]?://'
AND DAT_TXT NOT REGEXP 'http[s]?://[\\*]+'
AND SUBSTR(DAT_TXT
				, REGEXP_INSTR(DAT_TXT, 'http[s]?://')
				, CASE
						WHEN LOCATE(' ', DAT_TXT, REGEXP_INSTR(DAT_TXT, 'http[s]?://')) <> 0
							THEN LOCATE(' ', DAT_TXT, REGEXP_INSTR(DAT_TXT, 'http[s]?://')) - REGEXP_INSTR(DAT_TXT, 'http[s]?://')
						ELSE CHAR_LENGTH(DAT_TXT)
					END
			) NOT REGEXP '[[:upper:]]';	-- 예외방지2(URL뒤에 바로 텍스트 오는경우)
-- 3	-- 처리 완료.
			
-- -- 5. 예외2 확인
SELECT IDX , DAT_TXT 
	, sum(CASE WHEN 1 THEN 1 END) OVER() AS "SUM"
FROM url_scrap_txt_from_20230920
WHERE DAT_TXT REGEXP 'http[s]?://'
AND DAT_TXT NOT REGEXP 'http[s]?://[\\*]+';	-- 86

-- -- 6. 끝에서 6자리안에 대문자가 없으면 비식별화.
SELECT IDX , DAT_TXT 
	, REGEXP_INSTR(DAT_TXT, 'http[s]?://') "HTTP_LOC"		-- 자를 위치 확인
	, LOCATE(' ', DAT_TXT, REGEXP_INSTR(DAT_TXT, 'http[s]?://')) AS "BLANK_LOC"	-- http 이후로 나오는 첫 ' ' 위치 확인 
	, SUBSTR(DAT_TXT
				, REGEXP_INSTR(DAT_TXT, 'http[s]?://')			-- 자를 위치
				, CASE
						WHEN LOCATE(' ', DAT_TXT, REGEXP_INSTR(DAT_TXT, 'http[s]?://')) <> 0
							THEN LOCATE(' ', DAT_TXT, REGEXP_INSTR(DAT_TXT, 'http[s]?://')) - REGEXP_INSTR(DAT_TXT, 'http[s]?://')
						ELSE CHAR_LENGTH(DAT_TXT)
					END												-- 자를 개수
			) AS "URL_TXT"		-- 비식별화할 URL 확인
	, REPLACE(DAT_TXT
				, SUBSTR(DAT_TXT
							, REGEXP_INSTR(DAT_TXT, 'http[s]?://')
							, CASE
									WHEN LOCATE(' ', DAT_TXT, REGEXP_INSTR(DAT_TXT, 'http[s]?://')) <> 0
										THEN LOCATE(' ', DAT_TXT, REGEXP_INSTR(DAT_TXT, 'http[s]?://')) - REGEXP_INSTR(DAT_TXT, 'http[s]?://')
									ELSE CHAR_LENGTH(DAT_TXT)
								END
							)
				, 'http://***.***.**'
				) AS "REPLACE_TXT"	-- 수정 TXT 확인
	, sum(CASE WHEN 1 THEN 1 END) OVER() AS "SUM"
FROM url_scrap_txt_from_20230920
WHERE DAT_TXT REGEXP 'http[s]?://'
AND DAT_TXT NOT REGEXP 'http[s]?://[\\*]+'	
AND ( REGEXP_INSTR(SUBSTR(DAT_TXT, LOCATE(' ', DAT_TXT, REGEXP_INSTR(DAT_TXT, 'http[s]?://')) - 6, 6), '[[:upper:]]') = 0
			AND BINARY SUBSTR(DAT_TXT
							, REGEXP_INSTR(DAT_TXT, 'http[s]?://')		
							, CASE
									WHEN LOCATE(' ', DAT_TXT, REGEXP_INSTR(DAT_TXT, 'http[s]?://')) <> 0
										THEN LOCATE(' ', DAT_TXT, REGEXP_INSTR(DAT_TXT, 'http[s]?://')) - REGEXP_INSTR(DAT_TXT, 'http[s]?://')
									ELSE CHAR_LENGTH(DAT_TXT)
								END												
						) NOT REGEXP '(Facebook|Youtube|Website|Fanpage|Hotline)' );	-- 19

-- -- 7. 예외2 UPDATE
SAVEPOINT s7_7;

UPDATE url_scrap_txt_from_20230920
SET DAT_TXT = REPLACE(DAT_TXT
							, SUBSTR(DAT_TXT
										, REGEXP_INSTR(DAT_TXT, 'http[s]?://')
										, CASE
												WHEN LOCATE(' ', DAT_TXT, REGEXP_INSTR(DAT_TXT, 'http[s]?://')) <> 0
													THEN LOCATE(' ', DAT_TXT, REGEXP_INSTR(DAT_TXT, 'http[s]?://')) - REGEXP_INSTR(DAT_TXT, 'http[s]?://')
												ELSE CHAR_LENGTH(DAT_TXT)
											END
										)
							, 'http://***.***.**'
							)
WHERE DAT_TXT REGEXP 'http[s]?://'
AND DAT_TXT NOT REGEXP 'http[s]?://[\\*]+'	
AND ( REGEXP_INSTR(SUBSTR(DAT_TXT, LOCATE(' ', DAT_TXT, REGEXP_INSTR(DAT_TXT, 'http[s]?://')) - 6, 6), '[[:upper:]]') = 0
			AND BINARY SUBSTR(DAT_TXT
							, REGEXP_INSTR(DAT_TXT, 'http[s]?://')		
							, CASE
									WHEN LOCATE(' ', DAT_TXT, REGEXP_INSTR(DAT_TXT, 'http[s]?://')) <> 0
										THEN LOCATE(' ', DAT_TXT, REGEXP_INSTR(DAT_TXT, 'http[s]?://')) - REGEXP_INSTR(DAT_TXT, 'http[s]?://')
									ELSE CHAR_LENGTH(DAT_TXT)
								END												
						) NOT REGEXP '(Facebook|Youtube|Website|Fanpage|Hotline)' );	-- 19

-- -- 8. 예외2 확인
SELECT IDX , DAT_TXT 
	, sum(CASE WHEN 1 THEN 1 END) OVER() AS "SUM"
FROM url_scrap_txt_from_20230920
WHERE DAT_TXT REGEXP 'http[s]?://'
AND DAT_TXT NOT REGEXP 'http[s]?://[\\*]+';	-- 66
-- 확인