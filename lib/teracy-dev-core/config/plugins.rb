require 'teracy-dev/plugin'
require 'teracy-dev/config/configurator'

module TeracyDevCore
  module Config
    class Plugins < TeracyDev::Config::Configurator

      def configure(settings, config, type:)
        case type
        when 'common'
          plugins_settings = settings['vagrant']['plugins']
        when 'node'
          plugins_settings = settings['plugins']
        end
        plugins_settings ||= []
        @logger.debug("configure #{type}: #{plugins_settings}")
        TeracyDev::Plugin.sync(plugins_settings)
        set_options(plugins_settings, config)
      end

      private

      def set_options(plugins_settings, config)
        plugins_settings.each do |plugin|
          next if !can_proceed(plugin)
          if plugin.key?('config_key')
            config_key = plugin['config_key']
            options = plugin['options']
            @logger.debug("configuring `#{plugin['name']}` with options: #{options}")
            pluginConfig = config.send(config_key.to_sym)
            pluginConfig.set_options(options)
          end
        end
      end

      # check if plugin is installed and enabled to proceed
      def can_proceed(plugin)
          plugin_name = plugin['name']

          if !TeracyDev::Plugin.installed?(plugin_name)
            @logger.debug("#{plugin_name} is not installed")
            return false
          end

          if plugin['enabled'] != true
            @logger.debug("#{plugin_name} is installed but not enabled so its settings is ignored")
            return false
          end
          return true
      end
    end
  end
end
