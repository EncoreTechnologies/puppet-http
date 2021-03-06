#!/usr/bin/env ruby
require_relative '../../ruby_task_helper/files/task_helper.rb'
require 'json'

# Bolt task for sending an HTTP GET request
class HttpTask < TaskHelper
  def add_module_lib_paths(install_dir)
    Dir.glob(File.join([install_dir, '*'])).each do |mod|
      $LOAD_PATH << File.join([mod, 'lib'])
    end
  end

  def task(method: nil,
           url: nil,
           body: nil,
           headers: {},
           **kwargs)
    add_module_lib_paths(kwargs[:_installdir])
    require 'puppet_x/encore/http/client'
    http = PuppetX::Http::Client.new(username: kwargs[:username],
                                     password: kwargs[:password],
                                     ssl: kwargs[:ssl],
                                     ssl_verify: kwargs[:ssl_verify],
                                     redirect_limit: kwargs[:redirect_limit])
    response = http.execute(method, url, body: body, headers: headers)
    http.response_to_h(response)
  end
end

HttpTask.run if $PROGRAM_NAME == __FILE__
