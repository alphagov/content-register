Rails.application.routes.draw do
  with_options :format => false do |r|
    r.get '/entries' => 'entries#index', as: :entries
    r.put '/entry/:id' => 'entries#update', as: :entry

    r.get '/healthcheck' => proc {|env| [200, {}, ["OK"]]}
  end
end
