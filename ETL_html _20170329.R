# author: leongkaon
# date: 20170222
#--------------

library(dplyr)
library(xml2)
library(xmlview)
#--------------------

# 本次內容
## 1.計算.html每年檔案數
## 2.每篇報導一個檔案,輸出.txt, 不要標題及「本報訊」,只要內文
##    計算每個檔案約花時間
#-------------------

# 1.計算.html每年檔案數
# wd = "/Text_mining/new_data_html"
# lf_full_true = list.files(wd, full.names = TRUE, pattern = ".html$")
# lf_full_false = list.files(wd, full.names = FALSE, pattern = ".html$")

# 刪除所有字串長度奇奇怪怪的檔案
# 主要因為某些檔案的版數太奇怪，有百幾版，處理也不方便，但資料量少，所以刪除
## 刪除路徑字元長度不等於中位數的檔案
# file.remove(
#         lf_full_true[nchar(lf_full_true) != 
#                              median(nchar(lf_full_true))]
#         )
# 
# lf_full_true = list.files(wd, full.names = TRUE, pattern = ".html$")
# lf_full_false = list.files(wd, full.names = FALSE, pattern = ".html$")
# 
# file_count = table(substr(lf_full_false,1,4))
# print(file_count)  # .html每年檔案數

#-------

# 2.每篇報導一個檔案,輸出.txt
### 刪除內文的\r\n\t及空白
### 刪除內文的標題
### 刪除內文【新华社延安十日电】

# 順序:
# 0.列出所有html檔案
# 1.讀取某個html檔案
# 2.刪除檔案的regex符號
# 3.搜尋html檔中所有報導標題
# 4.逐篇刪除報導一開始至標題
# 5.刪除不相關內容，如【新华社延安十日电】

############################################
## 20170329                               ##
## 由於111事故不明，我決定沿用自己電腦... ##
## 不是明智的決定，但這是短期內的可行方案 ##
## 只選取頭版                             ##
############################################
# file input
wd = "/home/leongkaon/Documents/Text_mining/new_data_html/"
lf_full_true = list.files(wd, full.names = TRUE, pattern = ".html$")
lf_full_false = list.files(wd, full.names = FALSE, pattern = ".html$")

# file input pattern YYYYMMDDPP
pattern = "01.html$" # 是否只用特定年月日的檔案?(regex pattern, example: "^1993" is for year 1993)
file_path = lf_full_true[grepl(pattern,lf_full_false)]
write_names = sub(".html","",lf_full_false[grepl(pattern,lf_full_false)]) # 輸出檔案前段名稱

# file output
file_output = "/home/leongkaon/Documents/Text_mining/people_daily_front_page_txt/"

library(xml2)
library(xmlview)

## START ##
errorFile = NULL
t1 = Sys.time()
loop_times = 0
for (i in 154:length(file_path)){
        loop_times = loop_times + 1
        if ((loop_times %% 10000)==0){
                message(loop_times/130000,"%")
        }
        doc = read_html(file_path[i])
        xpath = "//*[@class='article']" # 內文
        text = xml_text(xml_find_all(doc,xpath))
        
        ### 刪除內文的\r\n\t及空白
        text_no_space = gsub("\r|\t|\n| ","",text)
        
        ### 刪除內文的標題及「專欄:」
        ## 尋找內文中是否有標題,標題起始字元+標題長度 為需刪去內容
        xpath2 = "//*[@class='box']/h2" #標題
        title = xml_text(xml_find_all(doc,xpath2))
        title_no_space = gsub(" ","",title)
        
        for (j in 1:length(text_no_space)){
                # 刪除內文一開始至標題
                loc = tryCatch(
                        regexpr(title_no_space[j], text_no_space[j]),
                        error = function(e) {
                                cat(file_path[i])
                                NULL
                        }
                )
                if (is.null(loc)){
                        errorFile = c(errorFile, file_path[i]);
                        next
                }
                        
                text_no_title =
                        tryCatch(
                                substr(
                                        text_no_space[j],
                                        as.numeric(loc) + attr(loc, "match.length"),
                                        nchar(text_no_space[j])
                                ),
                                error = function(e) {
                                        cat(file_path[i])
                                        NULL
                                }
                        )
                if (is.null(text_no_title)){
                        errorFile = c(errorFile, file_path[i]);
                        next
                }
                        
                
                ### 刪除內文【新华社延安十日电】# 暫不考慮到"【"可能出現兩次,因資料只有極少量此情況,無謂浪費效能
                loc1 = regexpr("【", text_no_title)
                loc2 = regexpr("】", text_no_title)
                
                text_clear = sub(substr(text_no_title, loc1, loc2),"",
                                 text_no_title)
                
                writeLines(text_clear,
                           paste0(file_output,
                                  write_names[i],
                                  sprintf("%02d", j),
                                  ".txt"
                           )
                           # encoding problem
                )
        }
}
Sys.time() - t1

# 個人電腦上運行，初步實驗26個html經整理輸出共300個txt檔，需時0.1836627 secs
0.1836627/26*130000 # 需時約15分鐘
300/26 * 130000 # 估計約1,500,000個txt檔
(812.3 - 509.9) / 812.3 # html檔案共812.3KB,輸出txt後為509.9KB,減少約三成七

# 輸出txt未完全準確，有少數刪除比標題稍長，亦有少數標題與內文標題些許差異,但整體為可接受

length(errorFile); head(errorFile)  #662
# writeLines(errorFile,'htmlToTxtFail.txt')

a1 = regexpr("01.html$", errorFile)  #616 個txt檔消失，原因最可能為regex字眼
n_distinct(substr(errorFile, a1 - 8, a1))


## BUGs:
nchar('\U3e34653cº')    # Error
nchar('U3e34653cº')

## Solve: Ignore

#################################################
## 有曬頭版堆txt檔，你知架啦，又開始漫長的旅程 ##
#################################################





##############
## Appendix ##
##############

国民党当局破坏荷泽协议    蓄意放水淹我解放区    不顾七百万人民生命图逞内战阴谋    中共中央发言人表示坚决反对

国民党当局破坏荷泽协议  蓄意放水淹我解放区  不顾七百万人民生命图逞内战阴谋  中共中央发言人表示坚决反对


# 2.每篇報導一個檔案,輸出.txt

## 拎1946測試,.html檔案數為495個
### 刪除內文的\r\n\t及空白
### 刪除內文的標題
### 刪除內文【新华社延安十日电】

file_path = lf_full_true[grepl("^1946",lf_full_false)]

doc = read_html(file_path[1])
xpath = "//*[@class='article']" # 內文
text = xml_text(xml_find_all(doc,xpath))

### 刪除內文的\r\n\t及空白
text_no_space = gsub("\r|\t|\n| ","",text)

### 刪除內文的標題及「專欄:」
## 尋找內文中是否有標題,標題起始字元+標題長度 為需刪去內容
xpath2 = "//*[@class='box']/h2" #標題
title = xml_text(xml_find_all(doc,xpath2))
title_no_space = gsub(" ","",title)

# 是否找到內文的標題?
for (i in 1:length(title)){
        cat(grepl(title_no_space[i], text_no_space[i]), sep="\n")
}

# 刪除內文一開始至標題
loc = regexpr(title_no_space[1], text_no_space[1])
text_no_title =
        substr(
                text_no_space[1],
                as.numeric(loc) + attr(loc, "match.length"),
                nchar(text_no_space[1])
        )

### 刪除內文【新华社延安十日电】# 暫不考慮到【可能出現兩次,因資料只有極少量此情況,無謂浪費效能
loc1 = regexpr("【", text_no_title)
loc2 = regexpr("】", text_no_title)

text_clear = sub(substr(text_no_title, loc1, loc2),"",
                 text_no_title)

writeLines(text_clear,"")

##########


sub("》","】","AAA》AA")















