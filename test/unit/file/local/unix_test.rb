require 'helper'
require 'train/file/local/unix'
require 'train/transports/mock'
require 'train/transports/local'

describe Train::File::Local::Unix do
  let(:cls) { Train::File::Local::Unix }
  
  let(:backend) {
    backend = Train::Transports::Mock.new.connection
    backend.mock_os({ family: 'linux' })
    backend
  }

  it 'checks a mounted path' do
    backend.mock_command("mount | grep -- ' on /mount/path '", rand.to_s)
    cls.new(backend, '/mount/path').mounted?.must_equal true
  end

  describe 'file metadata' do
    let(:transport) { Train::Transports::Local.new }
    let(:connection) { transport.connection }

    let(:stat) { Struct.new(:mode, :size, :mtime, :uid, :gid) }
    let(:uid) { rand }
    let(:gid) { rand }
    let(:statres) { stat.new(00140755, rand, (rand*100).to_i, uid, gid) }

    def meta_stub(method, param, &block)
      pwres = Struct.new(:name)
      Etc.stub :getpwuid, pwres.new('owner') do
        Etc.stub :getgrgid, pwres.new('group') do
          File.stub method, param do; yield; end
        end
      end
    end

    it 'recognizes type' do
      meta_stub :stat, statres do
        connection.file(rand.to_s).stat[:type].must_equal :socket
      end
    end

    it 'recognizes mode' do
      meta_stub :stat, statres do
        connection.file(rand.to_s).stat[:mode].must_equal 00755
      end
    end

    it 'recognizes mtime' do
      meta_stub :stat, statres do
        connection.file(rand.to_s).stat[:mtime].must_equal statres.mtime
      end
    end

    it 'recognizes size' do
      meta_stub :stat, statres do
        connection.file(rand.to_s).stat[:size].must_equal statres.size
      end
    end

    it 'recognizes uid' do
      meta_stub :stat, statres do
        connection.file(rand.to_s).stat[:uid].must_equal uid
      end
    end

    it 'recognizes gid' do
      meta_stub :stat, statres do
        connection.file(rand.to_s).stat[:gid].must_equal gid
      end
    end

    it 'recognizes owner' do
      meta_stub :stat, statres do
        connection.file(rand.to_s).owner.must_equal 'owner'
      end
    end

    it 'recognizes group' do
      meta_stub :stat, statres do
        connection.file(rand.to_s).group.must_equal 'group'
      end
    end

    it 'grouped_into' do
      meta_stub :stat, statres do
        connection.file(rand.to_s).grouped_into?('group').must_equal true
      end  
    end  

    it 'recognizes selinux label' do
      meta_stub :stat, statres do
        label = rand.to_s
        res = Train::Extras::CommandResult.new(label, nil, 0)
        connection.stub :run_command, res do
          connection.file(rand.to_s).selinux_label.must_equal label
        end
      end
    end

    it 'recognizes source selinux label' do
      meta_stub :lstat, statres do
        label = rand.to_s
        res = Train::Extras::CommandResult.new(label, nil, 0)
        connection.stub :run_command, res do
          connection.file(rand.to_s).source.selinux_label.must_equal label
        end
      end
    end
  end
end