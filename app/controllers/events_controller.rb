class EventsController < ApplicationController
  before_action :set_event, only: %i[show edit update destroy]

  def index
    @events = Event.chronological
  end

  def show
  end

  def new
    @event = Event.new
  end

  def edit
  end

  def create
    @event = Event.new(event_params)

    respond_to do |format|
      if @event.save
        format.turbo_stream { flash.now[:notice] = "Event was successfully created." } if inline_form?
        format.html { redirect_to @event, notice: "Event was successfully created." }
      else
        format.turbo_stream { render turbo_stream: turbo_stream.replace("event_form", partial: "form", locals: { event: @event, inline: true }), status: :unprocessable_entity } if inline_form?
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def update
    if @event.update(event_params)
      redirect_to @event, notice: "Event was successfully updated.", status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @event.destroy!
    redirect_to events_path, notice: "Event was successfully deleted.", status: :see_other
  end

  private
    def set_event
      @event = Event.find(params.expect(:id))
    end

    # The form in the dialog on the timeline page updates the page in place;
    # the standalone new page keeps the redirect to the event.
    def inline_form?
      params[:inline].present?
    end

    def event_params
      params.expect(event: [ :title, :happened_on, :description, :url ])
    end
end
