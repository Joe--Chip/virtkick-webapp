class Wvm::Disk < Wvm::Base
  def self.array_of disks
    disks ||= []
    array = disks.map do |disk|
      local_pool = Wvm::StoragePool.to_local disk.storage
      Infra::Disk.new \
          used: disk.allocation,
          size: disk.capacity,
          device: disk.dev,
          path: disk.path,
          name: disk.image,
          format: disk.format,
          type: local_pool[:name],
          pool: disk.storage
    end

    Infra::Disks.new array
  end

  def self.create disk, uuid
    raise unless disk.pool =~ /\A[a-zA-Z-]+\Z/

    add_missing_fields disk, uuid

    gigabytes = disk.size / 1.gigabytes
    meta_prealloc = disk.format == 'qcow2'

    call :post, "/1/storage/#{disk.pool}", add_volume: '',
        name: disk.name, size: gigabytes, format: disk.format, meta_prealloc: meta_prealloc
  end

  def self.delete disk
    call :post, "/1/storage/#{disk.pool}", del_volume: '',
        volname: disk.name
  end

  def self.add_missing_fields disk, uuid
    disk.format ||= 'qcow2'
    disk.name = uuid + '_' + disk.device + '.' + disk.format # TODO: introduce subdirectory per VM
    pool = Wvm::StoragePool.find disk.pool
    disk.path = pool.path + '/' + disk.name
  end
end
