module Jekyll

  class Post

    if Object.constants.include?(:MATCHER)
      Object.send(:remove_const, :MATCHER)
    end
    MATCHER = /^(.+\/)*(\d+-\d+-\d+-)?(.*)(\.[^.]+)$/

    def <=>(other)
      if self.date.nil? or other.date.nil?
        # USE WEIGHT
        cmp = self.slug <=> other.slug
      else
        cmp = self.date <=> other.date
        if 0 == cmp
          cmp = self.slug <=> other.slug
        end
      end
      return cmp
    end

    def process(name)
      m, cats, date, slug, ext = *name.match(MATCHER)
      self.date = date.nil? ? nil : Time.parse(date)
      self.slug = slug
      self.ext = ext
    rescue ArgumentError
      raise FatalException.new("Post #{name} does not have a valid date.")
    end



    def url_placeholders
      hash = {}
      hash[:year]        = date.strftime("%Y") unless date.nil?
      hash[:month]       = date.strftime("%m") unless date.nil?
      hash[:day]         = date.strftime("%d") unless date.nil?
      hash [:title]      = CGI.escape(slug)
      hash[:i_day]       = date.strftime("%d").to_i.to_s unless date.nil?
      hash[:i_month]     = date.strftime("%m").to_i.to_s unless date.nil?
      hash[:categories]   = (categories || []).map { |c| URI.escape(c.to_s) }.join('/')
      hash[:short_month] = date.strftime("%b") unless date.nil?
      hash[:y_day]       = date.strftime("%j") unless date.nil?
      hash[:output_ext]  = self.output_ext
      hash
    end

    def url
      @url ||= URL.new({
        :template => "/:title.html",
        :placeholders => url_placeholders,
        :permalink => permalink
      }).to_s
    end

  end

  class URL

    def generate_url
     print "Template: "
      puts @template.inspect
      puts "#{'*'*80}"
      puts @placeholders.inspect
      @placeholders.inject(@template) do |result, token|
        result.gsub(/:#{token.first}/, (token.last.nil?? "lol" : token.last))
      end
    end

  end


end
