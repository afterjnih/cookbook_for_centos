#
# Cookbook Name:: hello
# Recipe:: default
#
# Copyright 2014, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
log "hello world"

package "zsh" do
 action :install
end

package 'git' do
  action :install
end

git "/usr/local/rbenv" do
  repository "git://github.com/sstephenson/rbenv.git"
  reference "master"
  action :sync
#action :checkout
end

#bash 'add_epel' do
#  user 'root'
#  code <<-EOC
#    rpm -ivh http://ftp-srv2.kddilabs.jp/Linux/distributions/fedora/epel/6/x86_64/epel-release-6-8.noarch.rpm
#    sed -i -e "s/enabled *= *1/enabled=0/g" /etc/yum.repos.d/epel.repo
#  EOC
#  creates "/etc/yum.repos.d/epel.repo"
#end

yum_repository 'epel' do
  description 'Extra Packages for Enterprise Linux'
  mirrorlist 'http://mirrors.fedoraproject.org/mirrorlist?repo=epel-6&arch=$basearch'
#  fastestmirror_enabled true
  gpgkey 'http://dl.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-6'
  action :create
end

%w{/usr/local/rbenv/shims /usr/local/rbenv/versions}.each do |dir|
  directory dir do
    action :create 
  end 
end

git "/usr/local/ruby-build" do  
  repository "git://github.com/sstephenson/ruby-build.git"
  reference "master"
  action :sync
end

bash "install_ruby_build" do
  cwd "/usr/local/ruby-build"
  code <<-EOH
    ./install.sh
  EOH
end

template "rbenv.sh" do
  path "/etc/profile.d/rbenv.sh"
  owner "root"
  group "root"
  mode "0644"
  source "rbenv.sh.erb"
end

%w{make gcc zlib-devel openssl-devel readline-devel ncurses-devel gdbm-devel db4-devel libffi-devel tk-devel libyaml-devel}.each do |pkg|
  yum_package pkg do
    action :install
  end 
end


#execute "rbenv install 2.0.0-p195" do
##  command "/usr/local/rbenv/bin/rbenv rbenv install 2.0.0-p195"
#  command "/usr/local/rbenv/bin/rbenv install 2.0.0-p195"
#  user 'root'
##  not_if { ::File.exists?("/root/.rbenv/versions/2.0.0-p195") }
#  not_if { ::File.exists?("/usr/local/rbenv/versions/2.0.0-p195") }
#
#end
#
#execute "rbenv global 2.0.0-p195" do
##  command "rbenv global 2.0.0-p195"
#  command "/usr/local/rbenv/bin/rbenv global 2.0.0-p195"
#  action :run
#end

execute "rbenv install 2.0.0-p353" do
  not_if { ::File.exists?("/usr/local/rbenv/versions/2.0.0-p353") }
  command "/usr/local/rbenv/bin/rbenv install 2.0.0-p353"
  user 'root'
  

end

execute "rbenv global 2.0.0-p353" do
  command "/usr/local/rbenv/bin/rbenv global 2.0.0-p353"
  action :run
end



#execute "rbenv global 2.0.0-p195" do
#  command "rbenv global 2.0.0-p195"
#  action :run
#end

execute "rbenv rehash" do
#  command "rbenv rehash"
  command "/usr/local/rbenv/bin/rbenv rehash"
  action :run
end

 %w{ gcc make ncurses-devel mercurial perl-devel perl-ExtUtils-Embed ruby-devel python-devel}.each do |pkg|
  yum_package pkg do
   action :install
  end
 end
 
 bash "clone vim" do
#  not_if "vim --version | grep 7.4"
#  cwd /tmp
  cwd "/home/vagrant"
  code <<-EOH
    hg clone https://vim.googlecode.com/hg/ vim
    cd vim/src
    ./configure --with-features=huge --disable-gui --without-x --disable-gpm --disable-nls --enable-multibyte --enable-rubyinterp --enable-pythoninterp --enable-perlinterp --enable-cscope
    make
    make install
  EOH
  creates "/usr/local/bin/vim"
end

# bash "build vim" do
#  not_if "vim --version | grep 7.4"
#  cwd /tmp
#  cwd "~/vim/src"
#  code <<-EOH
#    ./configure --with-features=huge --disable-gui --without-x --disable-gpm --disable-nls --enable-multibyte --enable-rubyinterp --enable-pythoninterp --enable-perlinterp --enable-cscope
#    make
#    make install
#  EOH
#end



# dotfilesの配置
directory '/home/vagrant/dotfiles' do
 owner 'vagrant'
 group 'vagrant'
 mode  '0755'
 action :create
end

git "/home/vagrant/dotfiles" do
 repository "https://github.com/afterjnih/vimrc.git"
# repository "git://github.com/afterjnih/vimrc.git"
 reference "master"
 action :sync
end

bash "ln-dotfiles" do
  cwd "/home/vagrant/dotfiles"
  code <<-EOH
    ln -s /home/vagrant/dotfiles/.vimrc /home/vagrant/.vimrc
  EOH
  creates "/home/vagrant/.vimrc"
end
 
#neobundleのインストール
directory '/home/vagrant/.vim' do
 owner 'vagrant'
 group 'vagrant'
 mode  '0755'
 action :create
end

directory '/home/vagrant/.vim/bundle' do
 owner 'vagrant'
 group 'vagrant'
 mode  '0755'
 action :create
end

directory '/home/vagrant/.vim/bundle/neobundle.vim' do
 owner 'vagrant'
 group 'vagrant'
 mode  '0755'
 action :create
end

#directory '/home/vagrant/tmp' do
# owner 'vagrant'
# group 'vagrant'
# mode  '0755'
# action :create
#end
#

git "/home/vagrant/.vim/bundle/neobundle.vim" do
 repository "https://github.com/Shougo/neobundle.vim.git"
 reference "master"
 action :sync
end

#bash "lnstall NeoBundleInstall" do
#  cwd "/home/vagrant/tmp/bin"
#  code <<-EOH
#    ./install.sh
#  EOH
#  #creates "/home/vagrant/.vimrc"
#end

#bash "lnstall NeoBundleInstall" do
#  cwd "/home/vagrant"
#  environment "HOME" => '/home/vagrant'
#  code <<-EOH
#    curl https://raw.githubusercontent.com/Shougo/neobundle.vim/master/bin/install.sh | sh
#  EOH
#  #creates "/home/vagrant/.vimrc"
#end
#
#bash "lnstall NeoBundleInstall" do
#  cwd "/home/vagrant/tmp"
#  code <<-EOH
#    ./install.sh
#  EOH
#  #creates "/home/vagrant/.vimrc"
#end


#git "/home/vagrant/.vim/bundle" do
# repository "https://github.com/Shougo/neobundle.vim"
# reference "master"
# action :sync
#end
