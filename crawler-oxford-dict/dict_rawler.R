# Find definition and example of english words from oxford dictionary

FindWord = function(x){
        library(xml2)
        url   = paste0("http://www.oxfordlearnersdictionaries.com/definition/english/", as.character(x))
        doc   = read_html(url)
        ### Set the xpath of info needed
        xpath1 = "//*[@class='def']"
        xpath2 = "//*[@class='x']"
        # xpath3 = "//*[@class='hwd']"
        def = xml_text(xml_find_all(doc, xpath1))
        exa = xml_text(xml_find_all(doc, xpath2))
        # nearby = xml_text(xml_find_all(doc, xpath3))
        return(list(Definition = def, Example = exa))#, Nearby_words = nearby))
}

# Example:
FindWord("simplicity")
FindWord("truncate")
