class EntriesController < ApplicationController
  def index
    entries = Entry.where(format: params[:format]).order('created_at DESC')
    render json: entries
  end

  def update
    entry = Entry.find_or_initialize_by(content_id: params[:id])
    status = if entry.update_attributes(request_data)
      (entry.created_at == entry.updated_at) ? :created : :ok
    else
      :unprocessable_entity
    end

    render json: entry, status: status
  end

  private

  def request_data
    @request_data ||= JSON.parse(request.body.read).except('content_id')
  rescue JSON::ParserError
    head :bad_request
  end

end
