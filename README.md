# The content register

The register of all content created by publishing applications.

The content register stores following attributes of all content
that is either on GOV.UK already, or is being written for it:

* `content_id`
* `title`
* `format`
* `state`: one of 'draft' or 'live'
* optionally, `base_path`

## Adding content items to the content register

Publishing applications can register content using the content's `content_id`
to make them available for cross-linking. To add or update a piece of content
in the content register, make a PUT request:

``` sh
curl https://content-register.production.alphagov.co.uk/content/<content_id> \
    -X PUT \
    -H 'Content-type: application/json' \
    -d '<content_item_json>'
```

where [`<content_id>`](https://github.com/alphagov/content-store/blob/master/doc/content_item_fields.md#content_id) is the unique identifier for a piece of content,
and is assigned by a publishing application, and `<content_item_json>`
is its JSON representation as outlined in [doc/input_examples](doc/input_examples).

## Querying for content of a particular format

To retrieve content from the content register, make a GET request:

``` sh
  curl https://content-register.production.alphagov.co.uk/content?format=news-article
```

Examples of the JSON response can be found in [doc/output_examples](doc/output_examples).
