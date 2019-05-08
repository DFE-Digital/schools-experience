class RenamePhases < ActiveRecord::Migration[5.2]
  def up
    mapping.each { |edubase_id, data| modify(edubase_id, data[:new]) }
  end

  def down
    mapping.each { |edubase_id, data| modify(edubase_id, data[:old]) }
  end

private

  def modify(edubase_id, name)
    Rails.logger.debug("renaming phase with edubase_id #{edubase_id} to '#{name}'")
    Bookings::Phase
      .find_by!(edubase_id: edubase_id)
      .update(name: name)
  end

  # note, we're using the edubase_id field
  # because it's static (wasn't automatically
  # generated) and was set at import
  def mapping
    {
      1 => { old: "Nursery", new: "Early years" },
      2 => { old: "Primary", new: "Primary (4 to 11)" },
      4 => { old: "Secondary", new: "Secondary (11 to 16)" },
      6 => { old: "16 plus", new: "16 to 18" },
    }
  end
end
