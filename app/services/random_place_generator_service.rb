class RandomPlaceGeneratorService
  def initialize(user, options = {})
    @user, @city = user, options[:city]
  end

  def run
    # ask the user to work on any pending assignments, he has.
    return @user.pending_workables.sample if @user.has_pending_workable?

    # lock the resource so no other user is trying to complete this place
    populate_new_places_for_city if @city.requires_new_places?

    @resource = @city.pending_places.reload.order(ref_rating: :desc).first
    @resource.locked_via @user
    @resource
  end

  private

  def populate_new_places_for_city
    options = @city.bounds.merge(page: @city.places_count / 30)
    places  = ZomatoScraperService.new(options).run
    places.each{|place| @city.places.create place }
  end
end
