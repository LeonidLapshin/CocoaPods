module Pod
  class Installer
    class ProjectCache
      # Represents the cache stored at Pods/.project/installation_cache
      #
      class ProjectInstallationCache

        require 'cocoapods/installer/project_cache/target_cache_key'

        # @return [Hash{String => TargetCacheKey}]
        #         Stored hash of target cache key objects for every pod target.
        #
        attr_reader :cache_key_by_target_label

        # @return [Hash{String => Symbol}]
        #         Build configurations stored in the cache.
        #
        attr_reader :build_configurations

        # @return [String]
        #         Project object stored in the cache.
        #
        attr_reader :project_object_version

        # Initializes a new instance.
        #
        # @param [Hash{String => TargetCacheKey}] cache_key_by_target_label @see #cache_key_by_target_label
        # @param [Hash{String => Symbol}] build_configurations @see #build_configurations
        # @param [String] project_object_version @see #project_object_version
        #
        def initialize(cache_key_by_target_label = {}, build_configurations = nil, project_object_version = nil)
          @cache_key_by_target_label = cache_key_by_target_label
          @build_configurations = build_configurations
          @project_object_version = project_object_version
        end

        def cache_key_by_target_label=(cache_key_by_target_label)
          @cache_key_by_target_label = cache_key_by_target_label
        end

        def build_configurations=(build_configurations)
          @build_configurations = build_configurations
        end

        def project_object_version=(project_object_version)
          @project_object_version = project_object_version
        end

        def save_as(path)
          Pathname(path).dirname.mkpath
          cache_key_contents = Hash[cache_key_by_target_label.map do |label, key|
            [label, key.to_h]
          end]
          contents = { 'CACHE_KEYS' => cache_key_contents }
          contents['BUILD_CONFIGURATIONS'] = build_configurations if build_configurations
          contents['OBJECT_VERSION'] = project_object_version if project_object_version
          path.open('w') { |f| f.puts YAMLHelper.convert_hash(contents, nil) }
        end

        def self.from_file(path)
          return ProjectInstallationCache.new if !File.exist?(path)
          contents = YAMLHelper.load_file(path)
          cache_key_by_target_label = Hash[contents['CACHE_KEYS'].map do |name, key_hash|
            [name, TargetCacheKey.from_cache_hash(key_hash)]
          end]
          project_object_version = contents['OBJECT_VERSION']
          build_configurations = contents['BUILD_CONFIGURATIONS']
          ProjectInstallationCache.new(cache_key_by_target_label, build_configurations, project_object_version)
        end
      end
    end
  end
end
