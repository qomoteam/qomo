class AddCachedVotesToPipelines < ActiveRecord::Migration[5.0]
  def change
    add_column :pipelines, :cached_votes_total, :integer, :default => 0
    add_column :pipelines, :cached_votes_score, :integer, :default => 0
    add_column :pipelines, :cached_votes_up, :integer, :default => 0
    add_column :pipelines, :cached_votes_down, :integer, :default => 0
    add_column :pipelines, :cached_weighted_score, :integer, :default => 0
    add_column :pipelines, :cached_weighted_total, :integer, :default => 0
    add_column :pipelines, :cached_weighted_average, :float, :default => 0.0
    add_index  :pipelines, :cached_votes_total
    add_index  :pipelines, :cached_votes_score
    add_index  :pipelines, :cached_votes_up
    add_index  :pipelines, :cached_votes_down
    add_index  :pipelines, :cached_weighted_score
    add_index  :pipelines, :cached_weighted_total
    add_index  :pipelines, :cached_weighted_average

    # Force caching of existing votes
    Pipeline.find_each(&:update_cached_votes)
  end
end
