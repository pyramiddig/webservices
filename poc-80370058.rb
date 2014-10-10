#!/usr/bin/env ruby
server = 'bin/rails s thin -d -e=production'
`pkill -f "#{server}"`
sleep 1
`#{server}`
sleep 1

if ARGV[0] == 'fail'
  puts "Canada: "+`curl -s localhost:3000/canada_leads/search`
end
%w( dpl dtc el isn plc sdn fse ssi uvl ).each {|x|
  puts "#{x}: "+`curl -s localhost:3000/consolidated_screening_list/#{x}/search`
}


__END__
carlos@trade ~/webservices (carlos/poc)> bin/rails --version
Rails 4.0.1
carlos@trade ~/webservices (carlos/poc)> ruby -v
ruby 2.1.2p95 (2014-05-08 revision 45877) [x86_64-linux]

carlos@trade:~/webservices$ ./poc-80370058.rb
config.eager_load is set to nil. Please update your config/environments/*.rb files accordingly:

  * development - set it to false
  * test - set it to false (unless you use a tool that preloads your test environment)
  * production - set it to true

dpl: {"total":0,"offset":0,"results":[]}
dtc: {"total":0,"offset":0,"results":[]}
el: {"total":0,"offset":0,"results":[]}
isn: {"total":0,"offset":0,"results":[]}
plc: {"total":0,"offset":0,"results":[]}
sdn: {"total":0,"offset":0,"results":[]}
fse: {"total":0,"offset":0,"results":[]}
ssi: {"total":0,"offset":0,"results":[]}
uvl: {"total":0,"offset":0,"results":[]}
carlos@trade:~/webservices$ ./poc-80370058.rb fail
config.eager_load is set to nil. Please update your config/environments/*.rb files accordingly:

  * development - set it to false
  * test - set it to false (unless you use a tool that preloads your test environment)
  * production - set it to true

Canada: {"total":0,"offset":0,"results":[]}
dpl: {"status":"500","error":"Internal Server Error"}
dtc: {"status":"500","error":"Internal Server Error"}
el: {"status":"500","error":"Internal Server Error"}
isn: {"status":"500","error":"Internal Server Error"}
plc: {"status":"500","error":"Internal Server Error"}
sdn: {"status":"500","error":"Internal Server Error"}
fse: {"total":0,"offset":0,"results":[]}
ssi: {"total":0,"offset":0,"results":[]}
uvl: {"total":0,"offset":0,"results":[]}
carlos@trade:~/webservices$ exit

Something wrong about eager_load, possibly on my environment only.
Which explains why I can trigger or not trigger the failure by calling the canada_leads endpoint.

carlos@trade ~/webservices (carlos/poc)> git diff config
diff --git a/config/application.rb b/config/application.rb
index 075bb71..55cd7d2 100644
--- a/config/application.rb
+++ b/config/application.rb
@@ -36,5 +36,7 @@ module Webservices
     # This is a default secret_key_base for development that will be overridden if you place
     # a similar entry in config/initializers/secret_token.rb
     config.secret_key_base = '2874915d5abc3ca7314fa1d903ec6a1b2874915d5abc3ca7314fa1d903ec6a1b2874915d5abc3ca7314fa1
+
+    config.eager_load = true
   end
 end
carlos@trade ~/webservices (carlos/poc)>

carlos@trade:~/webservices$ ./poc-80370058.rb
dpl: {"status":"500","error":"Internal Server Error"}
dtc: {"status":"500","error":"Internal Server Error"}
el: {"status":"500","error":"Internal Server Error"}
isn: {"total":0,"offset":0,"results":[]}
plc: {"total":0,"offset":0,"results":[]}
sdn: {"total":0,"offset":0,"results":[]}
fse: {"total":0,"offset":0,"results":[]}
ssi: {"total":0,"offset":0,"results":[]}
uvl: {"total":0,"offset":0,"results":[]}

carlos@trade:~/webservices$ ./poc-80370058.rb fail
Canada: {"total":0,"offset":0,"results":[]}
dpl: {"status":"500","error":"Internal Server Error"}
dtc: {"status":"500","error":"Internal Server Error"}
el: {"status":"500","error":"Internal Server Error"}
isn: {"total":0,"offset":0,"results":[]}
plc: {"total":0,"offset":0,"results":[]}
sdn: {"total":0,"offset":0,"results":[]}
fse: {"total":0,"offset":0,"results":[]}
ssi: {"total":0,"offset":0,"results":[]}
uvl: {"total":0,"offset":0,"results":[]}
carlos@trade:~/webservices$


When it loads Query (lib/query.rb) first which I emulated by calling canada_leads
then loading one of the screening_list classes will cause it to resolve the inheritance to
the wrong class.
If for any reason we somehow manage to load ScreeningList::Query, which I emulated by explicitly
loading it only on ScreeningList::FseQuery, then loading of screning_list classes afterwards
works as expected.

Since those are loaded only once, whatever order you trigger them first, you will be stuck with it :-)
Like what happends when I fixed the eager_load.

