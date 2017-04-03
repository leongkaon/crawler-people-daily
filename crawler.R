# 20170208
# 爬網絡資料,補充人民日報資料
#--------------------------------

library(dplyr)
library(ggplot2)
library(xml2)
library(xmlview)

# core function
timesLoop = 0
#! START # 只要將第一個loop後totalDate[1]改totalDate就可執行，祝自己順利
totalDate = as.character(seq(as.Date("2002-01-27"), as.Date("2003-12-31"), by="+1 day"))
system.time(
        for (date in totalDate){
                message(date)
                print(Sys.time())
                timesLoop = timesLoop + 1
                # 尋找該日總共多少頁
                url = paste0("http://www.ziliaoku.org/rmrb/",date)
                doc = read_html(url)
                xpath = "//*[@class='box']/h3"
                a1 = xml_text(xml_find_all(doc,xpath))
                # 若根本沒有頁數，則直接下一次查詢
                if (length(a1)==0){
                        Sys.sleep(rgamma(1,shape = 3, scale = 0.3))
                        next
                }
                pages = as.numeric(gsub("[^0-9]","",a1))
                ## 休息片刻
                Sys.sleep(rgamma(1,shape = 3, scale = 0.3))
                message(pages)
                # 下載每日每版資料
                for (page in pages){
                        message(page)
                        datePage = paste(date,page,sep = "-")
                        tryCatch(download.file(paste0("http://www.ziliaoku.org/rmrb/",datePage),
                                               destfile = paste0("new_data_20170208/",
                                                                 paste0(strsplit(as.character(date),split="-")[[1]],collapse=""),
                                                                 sprintf("%02d",page),".html")
                        ),
                        error = function(e){NULL})
                        ## 休息片刻 ## 但在凌晨四點至五點稍為加速
                        if (substr(Sys.time(),12,13) %in% c("4","5")){
                                Sys.sleep(rgamma(1,shape = 3,scale = 0.6))
                        } else {
                                Sys.sleep(rgamma(1,shape = 4,scale = 1))
                        }
                }
                # 約x次休息約分幾鐘
                if (timesLoop==sample(6:9,1) | timesLoop==10){
                        Sys.sleep(rgamma(1,shape=50,scale=0.5))
                        timesLoop = 0
                }
                ## 每到十三點休息半個鐘
                #if (substr(Sys.time(),12,13) %in% c("13")){
                #        Sys.sleep(3600)
                #}
                # 每日到二十點後可以休息耐d..
                ## 血汗工廠
                if (as.numeric(substr(Sys.time(),12,13)) %in% c(20:23,0:3)){
                        Sys.sleep(rgamma(1,shape=23,scale=0.5)+5)
                }
        }
)

# have run seconds
16488.27 + 5400 + 233941 + 19531.26 + 37011.52 +
        62875.98 + 4523.98 + 5629.49 + 347774.2 + 50773.41 + 45634.59

################################################################

# 20170221
# 終於下載完成...
# 135909個html檔案
# 但有些檔案得個殼,內容空白...

## file size 單位 bytes
## 1024 bytes  = 1 KB
## 1024 KB = 1 MB

file.size("/new_data_20170208/1997062612.html")
file.size("/new_data_20170208/1962012806.html")

lf = list.files("/new_data_20170208", pattern = ".html$", full.names= TRUE)
lf2 = list.files("/new_data_20170208", pattern = ".html$", full.names= FALSE)
# 找出空白檔案
empty_file_full = lf[file.size(lf) < 5000]
empty_file = lf2[file.size(lf) < 5000]
tmp = sub(".html","",empty_file)
empty_date_page = paste(substr(tmp,1,4),substr(tmp,5,6),
                        substr(tmp,7,8),substr(tmp,9,nchar(tmp)),sep = "-")

# core function改
system.time(

                # 下載每日每版資料
                for (i in 1:length(empty_date_page)){
                        cat(empty_date_page[i])
                        tryCatch(download.file(paste0("http://www.ziliaoku.org/rmrb/",empty_date_page[i]),
                                               destfile = empty_file_full[i]),
                        error = function(e){NULL})
                        ## 休息片刻 ## 但在凌晨四點至五點稍為加速
                        if (substr(Sys.time(),12,13) %in% c("4","5")){
                                Sys.sleep(rgamma(1,shape = 3,scale = 0.6))
                        } else {
                                Sys.sleep(rgamma(1,shape = 4,scale = 1))
                        }
                }

)

# run time seconds
15856.61

###################################################

# 1959102202 檔案夠大,但都係唔完整,無尾行









