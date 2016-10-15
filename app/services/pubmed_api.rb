class PubmedApi # a very basic Pubmed API
  require "net/http"
  require "uri"
  require "nokogiri"

  def self.find(ids) # can accept an array of ids or a single id or a string of ids separated by commas
    param = ids.class == Array ? ids.join(",") : ids

    uri = URI.parse("http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?db=pubmed&id=#{param}")
    response = Net::HTTP.get_response(uri)

    documents = []

    if response.code_type.to_s == "Net::HTTPOK"

      parsed_doc = Nokogiri::XML(response.body)
      parsed_doc = parsed_doc.css("eSummaryResult DocSum")

      parsed_doc.each do |pd|
        doc = {}
        doc[:title] = pd.css("Item[Name=Title]")[0].text
        doc[:pmid] = pd.at_css("Item[Name=ArticleIds] Item[Name=pubmed]").text
        doc[:date] = pd.css("Item[Name=PubDate]")[0].text
        doc[:issue] = pd.css("Item[Name=Issue]")[0].text
        doc[:volume] = pd.css("Item[Name=Volume]")[0].text
        doc[:doi] = pd.at_css("Item[Name=ArticleIds] Item[Name=doi]").text

        doc[:journal] = pd.css("Item[Name=FullJournalName]")[0].text
        doc[:url] = "http://www.ncbi.nlm.nih.gov/pubmed/#{doc[:id]}"
        doc[:db] = "pubmed"

        doc[:authors] = []
        pd.css("Item[Name=AuthorList] Item[Name=Author]").each do |author|
          doc[:authors] << author.text
        end
        doc[:citation] = query_citation(doc[:doi])
        documents << doc
      end
    end

    documents
  end

  def self.query_citation(doi)
    doc = Nokogiri::HTML(open("https://xs.glgoo.com/scholar?hl=en-us&q=#{doi}",
                            'User-Agent' => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/53.0.2785.143 Safari/537.36',
                            'Referer' => 'https://xs.glgoo.com/',
                            'Cookie' => 'NID=84=FBVe58-dCCvIKoqVn0nwNuuy1z7qx96YO_W0dlou-blufSQK-nQYx62_uW8_nUqBM_ZSL4WplsQhjGLu3T7uW4XVl36t4HulQ7Ep_epyJiIOgKcOsrpj-7QdBL3SPLyn; GSP=LM=1470905923:S=oEVc65NwjFtRAhTb; xip=124.16.129.6'
                       ))
    doc.css('.gs_r:first-of-type .gs_fl>a:first-child').text.strip['Cited by '.length..-1]
  end

end
