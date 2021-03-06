require 'schema_test/property'

module SchemaTest
  class Definition < SchemaTest::Property::Object
    def self.reset!
      @definitions = nil
    end

    def self.register(definition)
      @definitions ||= {}
      @definitions[definition.name] ||= {}
      @definitions[definition.name][definition.version] = definition
    end

    def self.find(name, version)
      (@definitions || {}).dig(name, version)
    end

    def self.find!(name, version)
      found = find(name, version)
      raise SchemaTest::Error, "Could not find schema for #{name.inspect} (version: #{version.inspect})" unless found
      found
    end

    attr_reader :location

    def initialize(name, location: nil, **attributes)
      super(name, **attributes)
      self.class.register(self)
      @location = location
    end

    def as_json_schema(domain: SchemaTest.configuration.domain)
      id_part = version ? "v#{version}/#{name}" : name
      {
        '$schema' => SchemaTest::SCHEMA_VERSION,
        '$id' => "http://#{domain}/#{id_part}.json",
        'title' => name.to_s
      }.merge(super(false))
    end
  end
end
