json.partial! 'shared/queryinfo'
json.results do
  json.array! @search[:hits] do |hit|
    dl_trade_event = hit.deep_symbolize_keys
    json.partial! 'entry', entry: dl_trade_event
  end
end
