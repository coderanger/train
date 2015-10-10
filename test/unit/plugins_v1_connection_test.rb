# encoding: utf-8
require 'helper'

describe 'v1 Connection Plugin' do
  describe 'empty v1 connection plugin' do
    let(:connection) { Train::Plugins::Transport::Connection.new({}) }

    it 'provides a close method' do
      connection.close # wont raise
    end

    it 'provides a run_command method' do
      proc { connection.run_command('') }.must_raise Train::ClientError
    end

    it 'provides an os method' do
      proc { connection.os }.must_raise Train::ClientError
    end

    it 'provides a file method' do
      proc { connection.file('') }.must_raise Train::ClientError
    end

    it 'provides a login command method' do
      proc { connection.login_command }.must_raise Train::ClientError
    end

    it 'can wait until ready' do
      connection.wait_until_ready # wont raise
    end

    it 'provides a default logger' do
      connection.method(:log).call
                .must_be_instance_of(Logger)
    end
  end
end