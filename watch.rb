watch('^spec/.*_spec\.rb') {|md| system "rspec -c spec/spec_helper.rb #{md[0]}"}
watch('^models/(.*)\.rb') {|md| system "rspec -c spec/spec_helper.rb spec/models/#{md[1].split('/').last}_spec.rb"}
