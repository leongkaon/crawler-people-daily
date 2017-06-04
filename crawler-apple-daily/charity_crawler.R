# 爬蘋果日報的捐款文章

#############
## library ##
#############
library(xml2)

################
## target url ##
################

# Setting
start_page = 1
end_page = 3
bigTable = matrix(NA, ncol = 5, nrow = 20 * (end_page - start_page + 1)) # 因為一頁最多顯示二十筆資料 # 以填格方式寫入資料,速度較快。
end_ind = 0

for (i in (start_page:end_page)){
        url = paste0("http://www.appledaily.com.tw/charity/projlist/Page/", i)
        doc = read_html(url)
        
        xpath = "//*[@class='donabox']//table//tr//td" # 也可以xpath = "//*[@class='donabox']//table//tr//td[2]" 逐欄選取
        a1 = xml_text(xml_find_all(doc, xpath))
        data = matrix(a1, byrow = TRUE, ncol = 6) # row1 會是header
        
        xpath = "//*[@class='donabox']//table//tr/td[2]/h2/a"
        a1 = xml_find_all(doc, xpath)
        url2 = xml_attr(a1, "href")
        
        content = vector(length = length(url2))
        for (j in 1:length(url2)){
                doc2 = read_html(url2[j])
                xpath2 = "//*[@id='introid']"
                a2 = xml_find_all(doc2, xpath2)
                content[j] = xml_text(a2)
                
                cat('page',i,'article',j,'\n')
                
        }
        
        start_ind = end_ind + 1
        end_ind = start_ind + length(title) - 2 # 因為length(title)==21
        
        bigTable[c(start_ind:end_ind),1:4] = data[-1,-c(1,6)] # 不要header，不要編號及明細
        bigTable[c(start_ind:end_ind),5] = content
        
}

colnames(bigTable) = c(data[1,-c(1,6)], '內容')

write.csv(bigTable, 'testing.csv', row.names = FALSE)












