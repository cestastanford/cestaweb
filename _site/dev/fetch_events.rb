module Jekyll
  class eventsIndex < Page
    def initialize(site, base, dir)
      @site = site
      @base = base
      @dir  = dir
      @name = "index.html"

      self.process(@name)
      self.read_yaml(File.join(base, '_events'), 'events.html')
      self.data['events'] = self.get_events(site)
    end

    def get_events(site)
      {}.tap do |events|
        Dir['_events/*.yml'].each do |path|
          name   = File.basename(path, '.yml')
          config = YAML.load(File.read(File.join(@base, path)))
          events[name] = config if config['published']
        end
      end
    end
  end

  class EventIndex < Page
    def initialize(site, base, dir, path)
      @site     = site
      @base     = base
      @dir      = dir
      @name     = "index.html"
      self.data = YAML.load(File.read(File.join(@base, path)))

      self.process(@name) if self.data['published']
    end
  end

  class GenerateEvents < Generator
    safe true
    priority :normal

    def generate(site)
      self.write_events(site)
    end

    # Loops through the list of project pages and processes each one.
    def write_events(site)
      if Dir.exists?('_events')
        Dir.chdir('_events')
        Dir["*.yml"].each do |path|
          name = File.basename(path, '.yml')
          self.write_event_index(site, "_events/#{path}", name)
        end

        Dir.chdir(site.source)
        self.write_event_index(site)
      end
    end

    def write_event_index(site)
      events = eventsIndex.new(site, site.source, "/labs-events")
      events.render(site.layouts, site.site_payload)
      events.write(site.dest)

      site.pages << events
      site.static_files << events
    end

    def write_project_index(site, path, name)
      project = ProjectIndex.new(site, site.source, "/labs-events/#{name}", path)

      if project.data['published']
        project.render(site.layouts, site.site_payload)
        project.write(site.dest)

        site.pages << project
        site.static_files << project
      end
    end
  end
end
