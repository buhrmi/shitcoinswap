module Groupdate
  class RelationBuilder
    def generate
      relation = @relation.group(group_clause).where(*where_clause)
      
      if relation.select_values.present?
        relation.select(group_clause + ' as period')
      else
        relation
      end
    end
  end
end
