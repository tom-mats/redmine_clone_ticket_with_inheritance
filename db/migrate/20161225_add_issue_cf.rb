class AddIssueCf < ActiveRecord::Migration
  def up
    params = {:field_format => 'string', :searchable => true, :is_filter => true, :text_formatting => true}
    name = 'Latest result'
    unless IssueCustomField.find_by_name(name)
      IssueCustomField.create!(params.merge({:name => name}))
    end
    name = 'Results'
    unless IssueCustomField.find_by_name(name)
      IssueCustomField.create!(params.merge({:name => name}))
    end

  end
  def down

  end
end
