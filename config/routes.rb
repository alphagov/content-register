Rails.application.routes.draw do
  with_options :format => false do |r|
    r.get '/entries' => 'entries#index'
    r.put '/entry/:content_id' => 'entries#update', constraints: { content_id: Entry::UUID_REGEX }
  end
end
