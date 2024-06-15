;for angularjs <script type="text/ng-template">
(script_element
  (start_tag
    (attribute
      (attribute_name) @_attr
      (#eq? @_attr "type")
      (quoted_attribute_value
        (attribute_value) @_type)))
  (raw_text) @injection.content
  (#eq? @_type "text/ng-template")
  (#set! injection.language "html"))
