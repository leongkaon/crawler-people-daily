# crawler-people-daily
人民日報爬蟲及整理code

由於第一次寫這麼長的爬蟲，
我分開了兩段，第一段是下載html(crawler.R),第二段才是截取內容(ETL_html _20170329.R)，方便debug。

註：因簡體字問題，Windows將html轉至txt後會顯示亂碼，但Linux顯示正常。


# crawler-united-daily
聯合報爬蟲(united_daily_crawler.R)
輸出為.txt
要設定關鍵字，會有少數重複內容
