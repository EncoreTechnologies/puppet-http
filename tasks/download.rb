#!/usr/bin/env ruby
require_relative '../../ruby_task_helper/files/task_helper.rb'

# Bolt task for sending an HTTP GET request
class HttpDownloadTask < TaskHelper
  def add_module_lib_paths(install_dir)
    Dir.glob(File.join([install_dir, '*'])).each do |mod|
      $LOAD_PATH << File.join([mod, 'lib'])
    end
  end

  def task(url: nil,
           body: nil,
           headers: {},
           **kwargs)
    add_module_lib_paths(kwargs[:_installdir])
    require 'puppet_x/encore/http/client'

    ssl_verify = if kwargs.fetch(:ssl_verify, true)
                   OpenSSL::SSL::VERIFY_PEER
                 else
                   OpenSSL::SSL::VERIFY_NONE
                 end
    http = PuppetX::Http::Client.new(username: kwargs[:username],
                                     password: kwargs[:password],
                                     ssl: kwargs.fetch(:ssl, true),
                                     ssl_verify: ssl_verify,
                                     redirect_limit: kwargs.fetch(:redirect_limit, 10))

    resp = http.get(url, body: body, headers: headers)
    file_opts = 'w'
    file_opts += 'b' if kwargs[:binary]
    open(kwargs[:path], file_opts) do |file|
      file.write(resp.body)
    end
  end
end

HttpDownloadTask.run if $PROGRAM_NAME == __FILE__
