import tkinter as tk
from tkinter import filedialog
import pymysql
from pymysql import MySQLError
import os
import pandas as pd
from datetime import datetime
import re

#DB
#############################################################################
#host = '118.39.125.131'
host = '172.30.1.36'
port = 13333
user = "vnc"
passwd = "vnc"
db_name = "vncsim"
db = pymysql.connect(host=host,port=port,user=user,passwd=passwd,db=db_name)
#############################################################################

# 예외 처리 경우
## 1. 엑셀명이 옳지 않은 경우
## 2. 데이터를 못 읽어오는 경우
## 3. 데이터를 읽을 때
##      3-1. 각 행의 값이 없는 경우(nan)
##      3-2. 전체 데이터 수와 파일명에 적힌 수가 다른 경우(데이터 카운팅 오류)
##      3-3. 각 열의 작업자명이 파일명과 다른 경우
##      3-4. 작업날짜가 파일명과 다른 경우 
## 모든 에러는 마지막에 출력되게끔 처리

class UnCorrectFileNameException(Exception):
    def __init__(self, message):
        super().__init__(message)

class DataReadException(Exception):
    def __init__(self, message):
        super().__init__(message)

def validate_filename(filename):
    # 파일명에 해당하는 정규 표현식 패턴
    pattern = r'\d{8}_CW\d{3}_\d{1,4}_URL.xlsx'

    if re.match(pattern, filename):
        return True
    else:
        print(f"Rename the file '{filename}' to match the file name format.")
        return True
        # raise UnCorrectFileNameException(f"Rename the file '{filename}' to match the file name format.")

def checkValues(index, row, worker_id, job_ymd):
    # print(job_ymd, worker_id)
    
    fill_in = False
    datas = [str(row.iloc[i]) for i in [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 16]]
    # print(index-2, str(row.iloc[0]).strip())
    # print(index, datas)
    
    if any(data == 'nan' for data in datas):
        print(f"Make sure the {index+2} row contains all your input values!")
        # raise DataReadException(f"Make sure the {index+2} row contains all your input values!")
    else:
        fill_in = True
        
    if fill_in:
        id = str(row.iloc[1]).split()[0]
        ymd = str(row.iloc[2]).split()[0]
        
        # 유효성 검사(번호, 작업자명, 작업날짜, 발행 일자 길이, 주제코드 길이)
        if str(index-2) == str(row.iloc[0]).strip() and id == worker_id and ymd == job_ymd and len(str(row.iloc[3])) == 8 and len(str(row.iloc[16])) == 2:
            return True
        else:
            print(f"Check the idx, worker name or work date and publication date or topic code in the {index+2} line!")
            return True
            # raise DataReadException(f"Check the worker name or work date and publication date or topic code in the {index+2} line!")
    else:
        return True

# 수정해야 할 파일명 앞에 'X_' 붙여서 저장
def rename_xlsx_path(xlsx_path):
    rename_xlsx_name = 'X_' + os.path.basename(xlsx_path)
    # print(os.path.dirname(xlsx_path))   # 전체 경로 중 디렉토리명만 GET
    rename_xlsx_path = os.path.join(os.path.dirname(xlsx_path), rename_xlsx_name)
    os.rename(xlsx_path, rename_xlsx_path)
    return rename_xlsx_path

def browse_folder():
    xlsx_path = filedialog.askopenfilename(filetypes=[("xlsx files", "*.xlsx")])  # 파일 선택 대화 상자 열기
    if xlsx_path:
        entry_path.delete(0, tk.END)  # 입력 필드 초기화
        entry_path.insert(0, xlsx_path)  # 선택한 경로 입력 필드에 설정

def register_path():
    
    job_ymd = ''
    worker_id = ''
    work_cnt = ''
    
    is_error = False
    
    xlsx_path = entry_path.get()  # 입력 필드에서 경로 가져오기
    
    try:
        if xlsx_path:
            xlsx_file = os.path.basename(xlsx_path)  # 마지막 파일명 가져오기
            
            # 1. 파일명 확인
            if validate_filename(xlsx_file):
                
                parts = xlsx_file.split('_')  # 구분자로 분리..
                if len(parts) >= 4:                
                    job_ymd = parts[0].split()[0]
                    worker_id = parts[1].split()[0]
                    work_cnt = parts[2].split()[0]
                print(worker_id, job_ymd)
            
            # DB에 인서트할 배열 설정
            bulk_insert_datas = []
            chunk_size = 300  # DB에 인서트할 배열 크기
            
            # 2. 데이터 read 확인
            datas = []
            read_flag = False
            read_success = False
            
            data_frame = pd.read_excel(xlsx_path, engine='openpyxl')
            datas.append(data_frame)
            
            # 5번째 행 첫번째 열의 값 확인
            # print(datas[0].iloc[3])
            fifth_row_first_col = datas[0].iloc[3, 0]
            
            if str(fifth_row_first_col) == '1':
                read_flag = True    
            else:
                raise DataReadException(f'Double check that your data starts from row 5!')
            
            if read_flag:
                for df in datas:
                    for index, row in df.iloc[3:].iterrows():   # 5행부터 read
                        
                        # 3-1, 3-3, 3-4. 데이터 유무, 작업자코드, 작업날짜 비교
                        if checkValues(index, row, worker_id, job_ymd):
                            TITLE = str(row.iloc[13]).replace("'", "''")  # 작은따옴표를 두 번 사용하여 이스케이프
                            DAT_SRC = str(row.iloc[9]).replace("'", "''")
                            DOC_STYLE = '구어체' if str(row.iloc[15]) == '구어체' else '문어체'
                            COL_PK = DAT_SRC
                                                  
                            # DB에 넣기 위한 배열 추가
                            bulk_insert_datas.append((COL_PK,
                                                    int(row.iloc[0]),
                                                    str(row.iloc[1]),
                                                    str(row.iloc[2]),
                                                    str(row.iloc[3]),
                                                    str(row.iloc[4]),
                                                    str(row.iloc[5]),
                                                    str(row.iloc[6]),
                                                    str(row.iloc[7]),
                                                    str(row.iloc[8]),
                                                    DAT_SRC,
                                                    str(row.iloc[10]),
                                                    str(row.iloc[16]),
                                                    str(row.iloc[11]),
                                                    str(row.iloc[12]),
                                                    TITLE,
                                                    DOC_STYLE))
                    
                    # print(f"{xlsx_file}이 성공적으로 읽혔습니다.")
            
            # 3-2. 데이터 카운팅 오류
            if len(bulk_insert_datas) != int(work_cnt):
                raise DataReadException("Double-check the number of tasks written in the file name and the actual number of tasks!")
            else:
                read_success = True
                # read_success = False    # DB 인서트 전 테스트용
            # 데이터 성공적으로 읽은 경우
            if read_success:
                url_xlsx_tb = 'url_excel_list_from_' + job_ymd
                cursor = db.cursor(pymysql.cursors.DictCursor)
                
                sql = 'savepoint a'
                cursor.execute(sql)
                
                sql = f'CREATE TABLE {url_xlsx_tb} LIKE url_excel_list_from_20230920'
                            
                # 300개씩 url_excel_list_user 테이블에 인서트
                for i in range(0, len(bulk_insert_datas), chunk_size):
                    batch = bulk_insert_datas[i:i+chunk_size]
                    # print(batch)
                
                    sql = ""
                    sql = sql + f" INSERT INTO {url_xlsx_tb} "
                    sql = sql + " (col_pk, seq, worker_id, job_ymd, pub_ymd, wtr_kr, wtr_vn, ctr_kr, ctr_vn, org_typ, dat_src, dat_typ, topic_cd, topic_kr, topic_vn, title, doc_style) "
                    sql = sql + " VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)"
                    cursor.executemany(sql, batch)
                    print(f'{len(batch)}개 저장완료')
                    
                db.commit()
                # print(f'{xlsx_file}이 DB에 성공적으로 저장되었습니다! ')    
                
    except UnCorrectFileNameException as e:
        print(f'Uncorrect FileName Error : {e}')
        is_error = True
    except DataReadException as e:
        print(f'Data Read Error : {e}')
        is_error = True
    except MySQLError as e:
        print(f"DB Error - Contact to Manager : {e}")
        sql = 'rollback to a'
        cursor.execute(sql)
        is_error = True
    except Exception as e:
        print(f'Error occured : {e}')
        is_error = True

    finally:
        if db:
            db.close()
            print("Disconnected from MariaDB database")
        if is_error:
            rename_xlsx_name = rename_xlsx_path(xlsx_path)
            print(f"Please edit {rename_xlsx_name} file again!")
        else:
            print(f'{xlsx_file} has been successfully saved to DB! ')


# 메인 창 생성
root = tk.Tk()
root.title("Data Input Program")

# 라벨 생성
label = tk.Label(root, text="Select the Excel file to submit!")
label.pack()

# 입력 필드 생성
entry_path = tk.Entry(root, width=120)
entry_path.pack()

# "찾아보기" 버튼 생성
browse_button = tk.Button(root, text="Search", command=browse_folder)
browse_button.pack()

# "실행" 버튼 생성
register_button = tk.Button(root, text="Execute", command=register_path)
register_button.pack()

# 프로그램 실행
root.mainloop()