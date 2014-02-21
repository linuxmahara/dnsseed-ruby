#!/usr/bin/ruby
$LOAD_PATH.unshift File.dirname(__FILE__)
require 'bitcoin-node'
require 'global'

def scan(host = '127.0.0.1', port = 9301, timeout = 30, min_last_seen = 24)
  origNode = BitcoinNode.new(host, port, timeout)
  nodes = origNode.getAddr
  return if nodes.empty?
  t = Time.now.to_i - min_last_seen * 60 * 60
  nodes.each do |node|
    if node[:services][0] == 3 && node[:services][1] == 0
      if node[:timestamp] > t
        yield node
      end
    end
  end
  origNode
end

start_db_transaction
begin
  host = '127.0.0.1'
  port = 9301
  node = scan(host, port) do |node|
p [Time.at(node[:timestamp]), node[:ipv4], node[:port]]
    add_untested_node(node[:ipv4], node[:port])
  end
  add_node_to_dns(host, port, node.getVersion) if node
rescue => x
p x
raise x
  remove_node(host, port)
end
commit_db_transaction
