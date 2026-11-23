class CreateBrowserSessions < ActiveRecord::Migration[8.1]
  def change
    create_table :browser_sessions do |t|
      # Rack's hashed "private" session id, never the cookie value itself
      t.string :session_id, null: false
      t.binary :session_data, null: false
      t.datetime :expires_at, null: false
      # Whether the browser holds a signed cookie. Rows written before signed
      # cookies were issued stay false so their unsigned cookie can be upgraded
      # once, and is refused for every row after that.
      t.boolean :signed_cookie, null: false, default: false
      t.timestamps
    end

    add_index :browser_sessions, :session_id, unique: true
    add_index :browser_sessions, :expires_at
  end
end
