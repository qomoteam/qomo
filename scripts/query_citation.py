#! /usr/bin/env python

import scholar

from bottle import route, run, request, response, template

@route('/')
def query():
    doi = request.query['doi']
    response.content_type = 'text/plain'

    querier = scholar.ScholarQuerier()
    settings = scholar.ScholarSettings()
    querier.apply_settings(settings)

    query = scholar.SearchScholarQuery()
    query.set_num_page_results(1)
    query.set_phrase(doi)

    querier.send_query(query)
    scholar.txt(querier, with_globals=False)
    citation = querier.articles[0]['num_citations']
    return template('{{citation}}', citation=citation)

run(host='0.0.0.0', port=8000)
