
# This syphons down specs rather than wait for indexing
require 'fileutils'

# Update internal gem mirror.
$gem_repo_path = "/data/rubygems/gems/"
$gem_url = 'https://rubygems.org'

def fetch_gems_for gem_entry
  r = /^(\S+) \((.*)\)/.match  gem_entry
  r[2].split(", ").each do |ver_n_platforms|
    version, *platforms = ver_n_platforms.split(" ")
    retrieve_gem r[1], version, platforms
  end
end

def retrieve_gem name, version, platforms
  platforms = ['ruby'] if platforms.empty? || platforms.nil?
  platforms.each do |p|
    wget_unless_exists fq_gem_name(name, version, p)   # fq = "fully qualified"
  end
end

def wget_unless_exists fqname
  FileUtils.cd $gem_repo_path do
    puts `ls -la #{fqname}`
    return if File.exists?("../quick/Marshal.4.8/#{fqname}spec.rz")
    puts "http://rubygems.org/quick/Marshal.4.8/#{fqname}spec.rz"
    puts `wget -q http://rubygems.org/quick/Marshal.4.8/#{fqname}spec.rz -O ../quick/Marshal.4.8/#{fqname}spec.rz`
    return if File.exists?(fqname)
    puts `wget #{$gem_url}/gems/#{fqname}`
  end
end

def fq_gem_name name, version, platform=nil
  platform_string = (platform=='ruby' || platform.nil?) ? "" : "-#{platform}"
  "#{name}-#{version}#{platform_string}.gem"
end

### Use gem to find all latest sources. See gem docs for options
`gem list --remote --source #{$gem_url}/`.lines.each do |gem_entry|
  fetch_gems_for gem_entry
end
