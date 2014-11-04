# The content register

The register of all content created by publishing applications.

The content register stores following attributes of all content
that is either on GOV.UK already, or is being written for it:

* `content_id`
* `title`
* `format`
* optionally, `base_path`

## Create an entry for a content item in the content register

Publishing applications can create an entry for content using its `content_id`
to make them available for cross-linking. To add or update an entry in the
content register, make a PUT request:

``` sh
curl https://content-register.production.alphagov.co.uk/entry/<content_id> \
    -X PUT \
    -H 'Content-type: application/json' \
    -d '<entry_json>'
```

where [`<content_id>`](https://github.com/alphagov/content-store/blob/master/doc/content_item_fields.md#content_id) is a [UUID](http://tools.ietf.org/html/rfc4122), to uniquely identify a piece of content,
and is assigned by a publishing application, and `<entry_json>`
is its JSON representation as outlined in [doc/input_example.json](doc/input_example.json).

## Querying for entries of a particular format

To retrieve entries from the content register, make a GET request:

``` sh
  curl https://content-register.production.alphagov.co.uk/entries?format=news-article
```

Examples of the JSON response can be found in [doc/output_example.json](doc/output_example.json).
