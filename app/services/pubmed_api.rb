class PubmedApi # a very basic Pubmed API
  require "net/http"
  require "uri"
  require "nokogiri"

  def self.find(ids) # can accept an array of ids or a single id or a string of ids separated by commas
    param = ids.class == Array ? ids.join(",") : ids

    uri = URI.parse("https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?db=pubmed&id=#{param}")
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
        #doc[:citation] = query_citation(doc[:doi])
        documents << doc
      end
    end

    documents
  end

  def self.query_citation(doi)
    open("http://xingjianxu.me:8000/?doi=#{doi}")
  end

end
