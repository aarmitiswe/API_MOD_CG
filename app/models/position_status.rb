class PositionStatus < ActiveRecord::Base
    def self.update_position_status_names
        PositionStatus.find_by(name:"Budgeted").update(name:"Planned", ar_name:"ضمن الميزانية")
        PositionStatus.find_by(name:"Not Budgeted").update(name:"Unplanned", ar_name:"خارج الميزانية")
    end
end
  