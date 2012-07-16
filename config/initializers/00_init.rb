puts "Loading #{SupportBee::Importer.environment} Environment"
APP_CONFIG = YAML.load_file("#{SupportBee::Importer.root.to_s}/config/config.yml")[SupportBee::Importer.environment.to_s]