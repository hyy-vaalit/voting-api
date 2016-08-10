FactoryGirl.define do

  factory :imported_voter do
    name 'Armas Aappa'
    ssn '020486-1234'
    student_number '012617061'
    extent_of_studies 1
    faculty_code 'H55'
    start_year 2014
  end

  factory :faculty do
    sequence(:name) {|n| "Faculty #{n}"}
    sequence(:code) {|n| "#{Faker::Code.imei}#{n}"}
  end

  factory :department do
    sequence(:name) {|n| "Test Department #{n}"}
    sequence(:code) {|n| "#{Faker::Code.imei}#{n}"}

    faculty
  end

  factory :voter do
    sequence(:name) {|n| "Testi Voter #{n}"}
    sequence(:email) {|n| "testi.voter#{n}@example.com"}
    sequence(:student_number, 123456700) {|n| n}
    sequence(:ssn, 1000) {|n| "121280-#{n}"}

    faculty
    department
  end


end
