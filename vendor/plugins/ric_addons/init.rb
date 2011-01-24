# Include hook code here

$RIC_ADDONS_HISTORY = [ # Array of Hash style
  { :ver => '0.4.1',  :date =>'20110122', :desc => 'Compiles!' } ,
  { :ver => '0.3.2',  :date =>'20110122', :desc => 'Moved jeweler in right place. Added skel/ wonderful dir' } ,
  { :ver => '0.3.1',  :date =>'20110122', :desc => 'Jeweled. Made app/ dir with also metal/. Preparing Thor script to deploy' } ,
  { :ver => '0.2.2',  :date =>'20110122', :desc => 'Great changes ahead. Still I have the bad symlink though :(' } ,
  { :ver => '0.2.1a', :date =>'20110121', :desc => 'Corrected typo' } ,
  { :ver => '0.2.1',  :date =>'20110121', :desc => 'Copied from ric_plugin v0.1b (as it deserved to be copied!)' } ,
]

$RIC_ADDONS_VER  =  $RIC_ADDONS_HISTORY.first[:ver]  # version
$RIC_ADDONS_DATE =  $RIC_ADDONS_HISTORY.first[:date] # version

require File.dirname(__FILE__) + '/lib/acts_as_carlesso'
require 'ric_addons'
require File.dirname(__FILE__) + '/lib/searchable'
#require 'searchable'

### Deprecated...
#require "routing"
#ActionController::Routing::RouteSet::Mapper.send :include, RicAddons::Routing::MapperExtensions

#### controllrs/helpers/views:
# NON VA!
### %w{ models controllers helpers }.each do |dir|
###   path = File.join(RAILS_ROOT, 'vendor' 'plugin', 'ric_addons' 'skel', 'app', dir)
###   $LOAD_PATH << path
###   Dependencies.load_paths << path
###   Dependencies.load_once_paths.delete(path)
### end

# copied from Chad Fowler book pag.239
puts IO.read( File.join(directory, 'README') ) rescue "Some error"
puts RicAddons.yellow("Riccardo plugin hook v.#{$RIC_ADDONS_VER} on #{$RIC_ADDONS_DATE}, yay!") rescue "ric_addons v#{$RIC_ADDONS_VER}: Errors with yellow :-("
