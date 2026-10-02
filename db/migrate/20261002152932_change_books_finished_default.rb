class ChangeBooksFinishedDefault < ActiveRecord::Migration[8.1]
  def change
    # A new book starts unfinished (reviewed First Draft gap: book.finished default).
    change_column_default :books, :finished, from: nil, to: false
  end
end
