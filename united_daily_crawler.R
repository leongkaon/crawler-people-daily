# dir.create('/home/leongkaon/textmining/united_daily_txt/key_word_chinese')
library(xml2)
# Setting
path_output = '/home/leongkaon/textmining/united_daily_txt/key_word_chinese/'

# i = 89143
# Start
system.time(
        for (i in 1:74350){
                doc = read_html(
                        paste0('http://disa.csie.org/~yihsuan/udn/article.php?keyword=%E5%8F%B0%E7%81%A3&year=1951&name=',
                               sprintf("%05d", i)
                        )
                )

                xpath = "//*[@class='col-sm-9 col-sm-offset-3 col-md-10 col-md-offset-2 main']//p"
                text = xml_text(xml_find_all(doc,xpath))
                # print(text)
                # 若空白頁，則跳至下個迴圈
                if (sum(nchar(text))<=6) {
                        next
                }
                txt = c(text[1], text[length(text)], paste0(text[3:(length(text)-1)], collapse = ""))
                txt = gsub(" ","",txt)
                # print(txt)
                txt_name = gsub("[[:punct:]]","",txt[2])
                txt_name = gsub("[^0-9]","",txt_name)
                txt_name = paste0(txt_name,sprintf("%05d", i))
                # output
                writeLines(txt, paste0(path_output,txt_name,'.txt'))
                # 不要爬太快,避免以為我在攻擊
                Sys.sleep(rgamma(1,shape = 3,scale = 1))

        }
)

Sys.time()
