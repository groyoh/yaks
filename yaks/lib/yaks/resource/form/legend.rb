module Yaks
  class Resource
    class Form
      class Legend
        include Attribs.new(:label, :type)

        def initialize(opts)
          super(opts.merge(type: :legend))
        end

        # Up to 0.9.0 legends were represented as Form::Field
        # instances with the label stored as name, hence this alias
        # for compatibility
        alias_method :name, :label
      end
    end
  end
end
