class JobType < ActiveRecord::Base
    def self.del_type_add_translations
        if JobType.find_by(name:"Freelancer")
            JobType.find_by(name:"Freelancer").destroy
        end
        translations = [{"Internship":"تدريب خريجين"},{"Part-Time":"دوام جزئي"},{"Full-Time":"دوام كامل"},{"Contractual":"تعاقد"}]
        translations.each do |value|
            JobType.find_by(name:value.keys.first.to_s).update(ar_name:value.values.first)
        end
        p "Freelnacer deleted and translations added"
    end
end
