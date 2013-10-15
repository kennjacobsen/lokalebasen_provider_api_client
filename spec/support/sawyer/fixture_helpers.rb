module FixtureHelpers
  # Removes "_links"-keys
  # E.g. transforms
  #
  # {
  #   :_links => { :self => { :href => "http://something.dk" }},
  #   :entity => {
  #     :_links => { :self => { :href => "http://something.dk" }},
  #     :external_key => "my-external-key",
  #     :photos => [
  #       :_links => { :self => { :href => "http://somethingelse.dk/photo "}},
  #       :external_key => "my-photo-ext-key"
  #     ]
  #   }
  # }
  #
  # into
  #
  # {
  #   :external_key => "my-external-key",
  #   :photo => [
  #     { :external_key => "my-photo-ext-key"}
  #   ]
  # }
  #
  def fixture_to_response(fixture)
    fixture.delete(:_links)
    entity_key = fixture.keys.first
    fixture[entity_key].delete(:_links)
    remove_links_from_entity(fixture[entity_key])
  end

  private

  def remove_links_from_entity(entity)
    if entity.is_a?(Array)
      entity.map do |e|
        remove_links_from_entity(e)
      end
    elsif entity.is_a?(Hash)
      entity.delete(:_links)
      entity.tap do |hash_entity|
        hash_entity.keys.each do |key|
          hash_entity[key] = remove_links_from_entity(hash_entity[key])
        end
        hash_entity
      end
    else
      entity
    end
  end
end
