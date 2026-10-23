class EventsController < ApplicationController
  before_action :set_event, only: %i[ edit update destroy ]

  # GET /events
  def index
    @events = Event.chronological
  end

  # GET /events/new
  def new
    @event = Event.new
  end

  # GET /events/1/edit
  def edit
  end

  # POST /events
  def create
    @event = Event.new(event_params)

    if @event.save
      redirect_to events_path, notice: "Event was successfully created."
    else
      render :new, status: :unprocessable_content
    end
  end

  # PATCH/PUT /events/1
  def update
    if @event.update(event_params)
      redirect_to events_path, notice: "Event was successfully updated.", status: :see_other
    else
      render :edit, status: :unprocessable_content
    end
  end

  # DELETE /events/1
  def destroy
    @event.destroy!
    redirect_to events_path, notice: "Event was successfully deleted.", status: :see_other
  end

  private
    def set_event
      @event = Event.find(params.expect(:id))
    end

    # Source is not user-editable: manually entered events always keep the "manual" default.
    def event_params
      params.expect(event: [ :title, :happened_on, :description, :url ])
    end
end
